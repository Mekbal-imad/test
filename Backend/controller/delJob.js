const jobPost = require("../model/post");
const User = require("../model/user");

async function delJob(req, res) {
    try {
        
        const job = await jobPost.findById(req.params.id);
        if (!job) {
            return res.status(404).json({
                message: "Job not found"
            });
        }

        if (job.entrepriseID.toString() !== req.user.id) {
            return res.status(403).json({
                message: "Unauthorized"
            });
        }
                    
        await User.updateMany({ savedJobs: job._id },{ $pull: { savedJobs: job._id } });
        await jobPost.findByIdAndDelete(job.id);

        return res.status(200).json({
            message: "Job post deleted successfully"
        });

    } catch (err) {
        return res.status(400).json({
            message: err.message,
        })
    }
}
module.exports = delJob;