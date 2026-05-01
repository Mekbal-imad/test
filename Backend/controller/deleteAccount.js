const User = require('../model/user.js');
const { sendAccountDeletedEmail } = require('./emailService.js');
const jobPost = require('../model/post.js');

exports.deleteAccount = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user) return res.status(404).json({ message: "User not found" });

    const { email, username, role } = user;
    
    await jobPost.deleteMany({ entrepriseID: req.user.id });
    await User.findByIdAndDelete(req.user.id);

    sendAccountDeletedEmail(email, username, role);

    res.status(200).json({ message: "Account deleted successfully" });
  } catch (error) {
    console.error("Delete Account Error:", error);
    res.status(500).json({ message: "Internal server error" });
  }
};