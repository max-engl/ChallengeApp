const mongoose = require("mongoose");

const MONGO_URI =
    "mongodb+srv://engldevmail:%40Anphi00008@cluster0.rmg3c.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0";
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
