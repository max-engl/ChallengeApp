const mongoose = require("mongoose");

const challengeSchema = new mongoose.Schema({
  titel: { type: String, required: true },
  description: { type: String, required: true },
  userId: { type: String, required: true },
  videoCount: { type: Number, default: 0 },
});

module.exports = mongoose.model("Challenge", challengeSchema);
