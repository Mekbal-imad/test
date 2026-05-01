const bcrypt = require('bcrypt');
const User = require('../model/user.js');
const { sendPasswordChangeEmail } = require('./emailService.js');

async function changePassword(req, res) {
  try {
    const { oldPassword, newPassword } = req.body;

    if (!oldPassword || !newPassword) {
      return res.status(400).json({ message: "Old and new passwords are required" });
    }

    const user = await User.findById(req.user.id).select('+password');
    if (!user) return res.status(404).json({ message: "User not found" });

    const isMatch = await bcrypt.compare(oldPassword, user.password);
    if (!isMatch) return res.status(401).json({ message: "Incorrect current password" });

    if (oldPassword === newPassword) {
      return res.status(400).json({ message: "New password cannot be the same as the old one" });
    }

    user.password = await bcrypt.hash(newPassword, await bcrypt.genSalt(12));
    await user.save();

    sendPasswordChangeEmail(user.email, user.username, user.role, req.ip || 'Unknown');

    res.status(200).json({ message: "Password updated successfully" });
  } catch (error) {
    console.error("Change Password Error:", error);
    res.status(500).json({ message: "Internal server error" });
  }
}

module.exports =  changePassword ;