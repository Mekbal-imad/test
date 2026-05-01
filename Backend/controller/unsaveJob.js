const User = require("../model/user");
const jobPost = require("../model/post");

const unsaveJob = async (req,res)=>{
  try{
    const { jobId } = req.params;
    const userId = req.user.id
    const user = await User.findByIdAndUpdate(
      userId,
      { $pull: { savedJobs:jobId }},
      { new: true } 
    ).select("savedJobs");

    if(!user){
      return res.status(404).json({message : "User not found"});
    }
    res.status(200).json({
      message: "Job unsaved successfully",
      savedJobs: user.savedJobs,
    });
  }catch(error){
    if (error.name === "CastError") {
      return res.status(400).json({ message: "Invalid job ID" });
    }
    res.status(500).json({ message: "Server error", error: error.message });
  
  }
}

module.exports = unsaveJob;