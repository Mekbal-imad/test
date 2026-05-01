const jobPost = require("../model/post");

async function updateJob(req, res) {
  try {
    const jobId = req.params.id;
    const userId = req.user.id;

    const job = await jobPost.findById(jobId);
    if (!job) {
      return res.status(404).json({ error: "Job not found" });
    }

    // Only the owner can update
    if (job.entrepriseID.toString() !== userId.toString()) {
      return res.status(403).json({ error: "Not authorized to update this job" });
    }

    const {
      jobTitle,
      days,
      time,
      location,
      payment,
      description,
      requirements,
      contactNB,
      contactMail,
      website,
    } = req.body;

    if (
      !jobTitle ||
      !Array.isArray(days) || days.length === 0 ||
      !time?.start ||
      !time?.end ||
      !payment ||
      !description ||
      !Array.isArray(requirements) || requirements.length === 0 ||
      !Array.isArray(contactNB) || contactNB.length === 0 ||
      !Array.isArray(contactMail) || contactMail.length === 0
    ) {
      return res.status(400).json({ error: "All fields are required and must be valid" });
    }

    await jobPost.findByIdAndUpdate(jobId, {
      jobTitle,
      days,
      time: { start: time.start, end: time.end },
      location,
      payment,
      description,
      requirements,
      contactNB,
      contactMail,
      website,
    });

    return res.status(200).json({ message: "Job updated successfully" });
  } catch (err) {
    return res.status(400).json({ message: "Job not updated", error: err.message });
  }
}

module.exports = updateJob;