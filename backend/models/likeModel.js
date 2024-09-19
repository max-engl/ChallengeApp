const mongoose = require("mongoose");

const likeSchema = new mongoose.Schema({
    userId: { type: String, required: true },
    videoId: { type: String, required: true },

});

module.exports = mongoose.model("Like", likeSchema);
