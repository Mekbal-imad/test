// a .env is needed for the nodemailer to work

const nodemailer = require('nodemailer');
require('dotenv').config();

const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST,
  port: process.env.SMTP_PORT,
  secure: false, 
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
  },
});

const sendPasswordChangeEmail = async (userEmail, username, userRole, ip) => {
  const greeting = userRole === 'entreprise' ? 'Dear Enterprise Partner' : 'Dear User';

  const mailOptions = {
    from: `"JOB-BIT" <${process.env.EMAIL_FROM}>`,
    to: userEmail,
    subject: 'JOBBIT: Password Changed',
    html: `
      <!DOCTYPE html>
      <html>
      <body style="font-family: Arial, sans-serif; color: #002442;">
        <div style="max-width: 600px; margin: 0 auto; border: 1px solid #ddd; border-radius: 8px; overflow: hidden;">
          <div style="background-color: #007bff; padding: 20px; text-align: center;">
            <h2 style="color: white; margin: 0;">Password Updated</h2>
          </div>
          <div style="padding: 20px;">
            <p>Hello <strong>${username}</strong>,</p>
            <p>We noticed that your password was successfully changed on your account.</p>
            
            <div style="background-color: #f8f9fa; padding: 15px; border-radius: 5px; margin: 20px 0;">
              <p style="margin: 5px 0;"><strong>Time:</strong> ${new Date().toLocaleString()}</p>
              <p style="margin: 5px 0;"><strong>Account Role:</strong> ${userRole}</p>
            </div>

            <p>If you made this change, you can safely ignore this email.</p>
            <p><strong>If you did not request this change:</strong></p>
            <ul>
              <li>Your account security may be compromised.</li>
              <li>Please contact support immediately.</li>
            </ul>
          </div>
          <div style="background-color: #f1f1f1; padding: 15px; text-align: center; font-size: 12px; color: #002442;">
            <p>&copy; ${new Date().getFullYear()} From the JOB-BIT Team . All rights reserved.</p>
          </div>
        </div>
      </body>
      </html>
    `,
  };

  try {
    await transporter.sendMail(mailOptions);
    console.log(`Security email sent to ${userEmail}`);
  } catch (error) {
    console.error('Failed to send security email:', error.message);
  }
};

const sendAccountDeletedEmail = async (userEmail, username, userRole) => {
  const mailOptions = {
    from: `"JOB-BIT" <${process.env.EMAIL_FROM}>`,
    to: userEmail,
    subject: 'JOB-BIT: Account Deleted',
    html: `
      <!DOCTYPE html>
      <html>
      <body style="font-family: Arial, sans-serif; color: #002442;">
        <div style="max-width: 600px; margin: 0 auto; border: 1px solid #ddd; border-radius: 8px; overflow: hidden;">
          <div style="background-color: #dc3545; padding: 20px; text-align: center;">
            <h2 style="color: white; margin: 0;">Account Deleted</h2>
          </div>
          <div style="padding: 20px;">
            <p>Hello <strong>${username}</strong>,</p>
            <p>Your JOB-BIT account has been permanently deleted.</p>
            <div style="background-color: #f8f9fa; padding: 15px; border-radius: 5px; margin: 20px 0;">
              <p style="margin: 5px 0;"><strong>Time:</strong> ${new Date().toLocaleString()}</p>
              <p style="margin: 5px 0;"><strong>Account Role:</strong> ${userRole}</p>
            </div>
            <p>All your data has been removed from our system.</p>
            <p><strong>If you did not request this:</strong></p>
            <ul>
              <li>Your account may have been compromised.</li>
              <li>Please contact support immediately.</li>
            </ul>
          </div>
          <div style="background-color: #f1f1f1; padding: 15px; text-align: center; font-size: 12px; color: #002442;">
            <p>&copy; ${new Date().getFullYear()} From the JOB-BIT Team. All rights reserved.</p>
          </div>
        </div>
      </body>
      </html>
    `,
  };
  try {
    await transporter.sendMail(mailOptions);
    console.log(`Account deletion email sent to ${userEmail}`);
  } catch (error) {
    console.error('Failed to send deletion email:', error.message);
  }
};

module.exports = { sendPasswordChangeEmail, sendAccountDeletedEmail };
