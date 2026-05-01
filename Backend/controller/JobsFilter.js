const jobPost = require("../model/post");
const User = require("../model/user");

async function filterJobs(req, res) {
    try {
        const {
            jobTitle,
            days,
            payment,
            requirements,
            page = 1,
            limit = 10
        } = req.query;

        const filter = {};

        if (jobTitle) {
            const escaped = jobTitle.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
            filter.jobTitle = { $regex: escaped, $options: "i" };
        }

        if (days) {
            const daysArray = Array.isArray(days) ? days : days.split(",");
            filter.days = { $in: daysArray.map(d => d.trim()).filter(Boolean) };
        }

        if (payment) {
            filter.payment = { $gte: parseInt(payment) };
        }

        if (requirements) {
            const reqArray = Array.isArray(requirements) ? requirements : requirements.split(",");
            filter.requirements = { $in: reqArray.map(r => r.trim()).filter(Boolean) };
        }

        const pageNum = Math.max(1, parseInt(page) || 1);
        const limitNum = Math.min(50, Math.max(1, parseInt(limit) || 10));
        const skip = (pageNum - 1) * limitNum;

        const [jobs, total, user] = await Promise.all([
            jobPost.find(filter).skip(skip).limit(limitNum).sort({ createdAt: -1 }),
            jobPost.countDocuments(filter),
            User.findById(req.user.id).select("savedJobs")
        ]);

        const savedIds = new Set(
            (user?.savedJobs || []).map(id => id.toString())
        );

        const jobsWithSaved = jobs.map(job => ({
            ...job.toObject(),
            isSaved: savedIds.has(job._id.toString())
        }));

        return res.status(200).json({
            total,
            page: pageNum,
            totalPages: Math.ceil(total / limitNum),
            limit: limitNum,
            jobs: jobsWithSaved
        });

    } catch (err) {
        return res.status(500).json({
            message: "Failed to fetch jobs",
            error: err.message
        });
    }
}

module.exports = filterJobs;