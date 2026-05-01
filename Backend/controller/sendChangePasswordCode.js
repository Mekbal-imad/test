const User = require('../model/user.js');
const nodemailer = require('nodemailer');

async function sendChangePassword (req, res) {
  const { email } = req.body;
  console.log("0")
  if (!email) {
    return res.status(400).json({ message: "Email missing" });
  }
  console.log("0.1");
  try {
    const user = await User.findOne({ email });
    if (!user){
       return res.status(404).json({
          message : "user not found"
        });
      }

    const code = Math.floor(1000 + Math.random() * 9000).toString();
    const expireAt = new Date(Date.now() + 15 * 60 * 1000);

    user.resetCode = code;
    user.resetCodeExpire = expireAt;
    await user.save();
    console.log("1");
    const transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
      }
    });
    console.log("2");
    await transporter.sendMail({
      from: `"Support" <${process.env.EMAIL_USER}>`,
      to: email,
      subject: 'Code de vérification',
      html: `<h2>${code}</h2><p>Expire dans 15 minutes</p>`
    });
     console.log("3");
    return res.status(200).json({
      message: "Email sent successfully"
    });

  } catch (error) {
    return res.status(500).json({ message: "Internal error" });
  }
};
module.exports = sendChangePassword ;