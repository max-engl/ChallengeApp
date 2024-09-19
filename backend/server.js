const express = require("express");
const dotenv = require("dotenv");
const connectDB = require("./config/db");
const videoRoutes = require("./routes/videoRoutes");
const loginRoutes = require("./routes/loginRoute");
const userRoutes = require("./routes/UserRoute");
const path = require("path");
// Load environment variables
dotenv.config();

// Connect to the database
connectDB();

const app = express();
app.use(express.json());

// Serve video files from the "uploads/videos" directory
app.use(
  "/uploads/videos",
  express.static(path.join(__dirname, "uploads/videos"))
);

app.use(
  "/uploads/profile_pics",
  express.static(path.join(__dirname, "uploads/profile_pics"))
);

// Routes
app.use("/api/videos", videoRoutes);
app.use("/api/login", loginRoutes);
app.use("/api/user", userRoutes);

const PORT = process.env.PORT || 3005;
app.listen(PORT, "192.168.178.88", () => {
  console.log(`Server running on port ${PORT}`);
});
