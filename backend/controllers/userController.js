const User = require("../models/userModel");
const upload = require("multer")();
const path = require("path");
const crypto = require("crypto");
const Video = require("../models/videoModel")
exports.getProfilePicture = async (req, res) => {
  try {
    const { userName } = req.params;

    // Find the user by username
    const user = await User.findOne({ userName });

    if (!user) {
      return res.status(404).json({ msg: "User not found" });
    }

    // Check if the user has a profile picture
    if (!user.profilePicture) {
      return res.status(404).json({ msg: "Profile picture not found" });
    }

    // Construct the file path for the profile picture
    const filePath = path.join(
      __dirname,
      "..",
      "uploads",
      "profile_pics",
      user.profilePicture
    );

    // Send the file if it exists
    return res.sendFile(filePath);
  } catch (error) {
    console.error(error);
    return res.status(500).json({ msg: "Server error" });
  }
};


exports.getUserData = async (req, res) => {
  try {
    var { userName, token, nickname } = req.body;
    let user = null;
    console.log(userName, token);
    // Fetch user data based on userName, token, or nickname
    if (userName) {
      user = await User.findOne({ userName }).select("-password -token");
    } else if (token) {
      user = await User.findOne({ token }).select("-password -token");
    } else if (nickname) {
      user = await User.findOne({ nickname }).select("-password -token");
    }

    // If no user is found, return 404
    if (!user) {
      return res.status(404).json({ msg: "User not found" });
    }

    // Fetch only the videos uploaded by the user based on their userToken
    const u = user.userName;
    userToken = User.findOne({ u }).token; // Assuming the user has a 'token' field
    console.log(u)
    const videos = await Video.find({ token }).select("thumbnailUrl");
    // Prepare the response
    console.log(videos)
    const response = {
      user,    // User data (without password and token)
      videos   // List of videos that match the user's userToken
    };

    // Return the user data along with user's video thumbnails
    return res.status(200).json(response);
  } catch (error) {
    console.error("Error fetching user data:", error);
    return res.status(500).json({ msg: "Server error" });
  }
};

exports.deleteAllUsers = async (req, res) => {
  try {
    // Delete all users
    await User.deleteMany({});

    // Respond with a success message
    res.status(200).json({ msg: "All users deleted" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ msg: "Server error" });
  }
};
exports.getAllUsers = async (req, res) => {
  try {
    const users = await User.find();

    res.status(200).json(users);
  } catch (error) {
    console.error(error);
    res.status(500).json({ msg: "Server error" });
  }
};
