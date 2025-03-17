const mongoose = require("mongoose");

const MONGO_URI =
    "MONGODBURL";
const connectDB = async () => {
    try {
        await mongoose.connect(MONGO_URI, {

        });
        console.log("MongoDB connected");
    } catch (err) {
        console.error(err.message);
        process.exit(1); // Exit process with failure
    }
};

module.exports = connectDB;
