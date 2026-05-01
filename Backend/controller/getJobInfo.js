const Post = require('../model/post'); 


const getJobInfo = async (req, res) => {
  try {
    const job = await Post.findById(req.params.id);

    if (!job) {
      return res.status(404).json({ message: "Job not found" });
    }

    res.status(200).json(job);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = getJobInfo;