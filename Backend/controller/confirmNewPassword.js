const User = require("../model/user");
const bcrypt = require("bcrypt");


async function confirmNewPassword(req, res) {
  const { code, email, newPassword } = req.body;

  if (!code || !email || !newPassword) {
    return res.status(400).json({ message: "Missing fields" });
  }

  const user = await User.findOne({ email })
    .select('+resetCode +resetCodeExpire');

  if (!user) {
    return res.status(400).json({ message: "User does not exist" });
  }

  if (!user.resetCodeExpire || user.resetCodeExpire < Date.now()) {
    return res.status(400).json({ message: "Expired" });
  }

  if (user.resetCode !== code) {
    console.log(user.resetCode);
    return res.status(400).json({ message: "Wrong code" });
  }

  try {
    
    const hashed = await bcrypt.hash(newPassword, 10);
    
    user.password = hashed;
    user.resetCode = null;
    user.resetCodeExpire = null;
    
    await user.save();

    return res.status(200).json({
      message: "Password changed successfully"
    });
  } catch (err) {
    return res.status(500).json({ message: "Internal error" });
  }
};

module.exports = confirmNewPassword ; 