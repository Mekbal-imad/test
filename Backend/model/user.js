const mongoose = require("mongoose");


const userSchema = new mongoose.Schema({
  pdpUrl: String,
  email: { type: String, required: true, unique: true },
  username: { type: String, required: true },
  dob: String,
  number: {
    type: [String],
    default: []
  },
  role: {
    type: String,
    enum: ["user", "entreprise"],
    required: true
  },
  location: String,
  field: String,
  isVerified: {
    type: Boolean,
    default: false
  },
  password: {
    type: String,
    required: true,
    select: false
  },
  savedJobs: {
    type: [{ type: mongoose.Schema.Types.ObjectId, ref: 'jobPost' }],
    default: []
  },
  resetCode: {
    type: String,
    select: false,
    default: null
  },
  resetCodeExpire: {
    type: Date,
    select: false,
    default: null
  }
}, { timestamps: true });


const User = mongoose.model("User", userSchema);


module.exports = User;
