const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({
  userName: { type: String, required: true },
  nickName: { type: String, default: "" },
  password: { type: String, required: true },
  profilePicture: { type: String },
  token: { type: String, required: true },
});

module.exports = mongoose.model("User", userSchema);
