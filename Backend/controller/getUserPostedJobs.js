const Post = require('../model/post');

const getUserPostedJobs = async (req, res) => {
  try {
    const jobs = await Post.find({ entrepriseID: req.user.id });

    if (!jobs.length) {
      return res.status(404).json({ message: "No jobs found" });
    }

    res.status(200).json(jobs);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = getUserPostedJobs;