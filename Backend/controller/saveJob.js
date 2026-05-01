const User = require("../model/user");
const jobPost = require("../model/post");

const saveJob = async (req, res) => {
  try {
    const { jobId } = req.params;
    const  userId = req.user.id

    const post = await jobPost.findById(jobId);
    
    if (!post) {
      return res.status(404).json({ message: "Job not found" });
    }

    const user = await User.findByIdAndUpdate(
      userId,
      { $addToSet: { savedJobs: jobId } },
      { new: true }
    ).select("savedJobs");

    res.status(200).json({
      message: "Job saved successfully",
      savedJobs: user.savedJobs,
    });

  } catch (error) {
    if (error.name === "CastError") {
      return res.status(400).json({ message: "Invalid job ID" });
    }
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

module.exports =  saveJob ;

