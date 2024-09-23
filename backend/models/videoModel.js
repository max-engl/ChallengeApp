const mongoose = require("mongoose");

const videoSchema = new mongoose.Schema({
  videoUrl: {
    type: String,
    required: true,
  },
  userToken: {
    type: String,
    required: true,
  },
  description: {
    type: String,
    required: true,
  },
  likes: {
    type: Number,
    required: true,
  },
  dislikes: {
    type: Number,
    required: true,
  },
  challenge: {
    type: String,
    required: true,
  },
});

module.exports = mongoose.model("Video", videoSchema);
