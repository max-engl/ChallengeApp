const express = require('express');
const dotenv = require('dotenv');
const connectDB = require('./config/db');
const videoRoutes = require('./routes/videoRoutes');
const path = require("path");
// Load environment variables
dotenv.config();

// Connect to the database
connectDB();

const app = express();
app.use(express.json());

// Serve video files from the "uploads/videos" directory
app.use("/uploads/videos", express.static(path.join(__dirname, "uploads/videos")));

// Routes
app.use("/api/videos", videoRoutes);

const PORT = process.env.PORT || 3005;
app.listen(PORT, "192.168.178.169", () => {
    console.log(`Server running on port ${PORT}`);
});
