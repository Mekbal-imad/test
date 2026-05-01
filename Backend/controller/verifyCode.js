const User = require("../model/user");

async function verifyCode(req, res) {
  const { email, code } = req.body;

  if (!email || !code) {
    return res.status(400).json({ message: "Missing fields" });
  }

  const user = await User.findOne({ email })
    .select('+resetCode +resetCodeExpire');

  if (!user) {
    return res.status(400).json({ message: "User does not exist" });
  }

  if (!user.resetCodeExpire || user.resetCodeExpire < Date.now()) {
    return res.status(400).json({ message: "Code has expired" });
  }

  if (user.resetCode !== code) {
    return res.status(400).json({ message: "Wrong code" });
  }

  return res.status(200).json({ message: "Code is valid" });
}

module.exports = verifyCode;