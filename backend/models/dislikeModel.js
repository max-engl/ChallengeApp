const mongoose = require("mongoose");

const dislikeSchema = new mongoose.Schema({
    userId: { type: String, required: true },
    videoId: { type: String, required: true },

});

module.exports = mongoose.model("Dislike", dislikeSchema);
