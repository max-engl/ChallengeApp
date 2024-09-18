const User = require("../models/userModel");
const upload = require("../multer");
const path = require("path");
const crypto = require("crypto");

exports.getProfilePicture = async (req, res) => {
  try {
    const { userName } = req.params;
    // Find the user by token
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
      "uploads/profile_pics",
      user.profilePicture
    );

    // Send the file
    return res.sendFile(filePath);
  } catch (error) {
    return res.status(500).json({ msg: "Server error" });
  }
};

exports.getUserData = async (req, res) => {
  try {
    const { userName, token, nickname } = req.body;
    var user = null;

    if (userName) {
      user = await User.findOne({ userName }).select("-password -token");
    }
    if (token) {
      user = await User.findOne({ token }).select("-password -token");
    }
    if (nickname) {
      user = await User.findOne({ nickname }).select("-password -token");
    }
    // Find the user by userName, but exclude the password and token fields

    if (!user) {
      return res.status(404).json({ msg: "User not found" });
    }

    // Send the user data without password and token
    return res.status(200).json(user);
  } catch (error) {
    console.error(error);
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
