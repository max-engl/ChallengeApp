const User = require("../models/userModel");
const upload = require("multer");
const path = require("path");
const crypto = require("crypto");

exports.loginUser = async (req, res) => {
  try {
    const { userName, nickname, password } = req.body;

    if (!userName) {
      return res.status(400).json({ msg: "User name is required" });
    }

    const existingUser = await User.findOne({ userName, password });
    console.log(res.body);
    if (!existingUser) {
      return res.status(400).json({ msg: "User doesnt Exist" });
    }

    res.status(200).json(existingUser);
  } catch (error) {
    console.error(error);
    res.status(500).json({ msg: "Server error" });
  }
};

exports.uploadProfilePicture = upload().single("profilePic");

// Register user with profile picture
exports.registerUser = async (req, res) => {
  try {
    const { userName, nickname, password } = req.body;

    if (!userName || !password) {
      return res
        .status(400)
        .json({ msg: "User name and password are required" });
    }

    // Check if the user already exists
    const existingUser = await User.findOne({ userName });
    if (existingUser) {
      return res.status(400).json({ msg: "User already exists" });
    }

    // Handle profile picture upload
    let profilePicture = "";
    if (req.file) {
      profilePicture = req.file.filename;
      console.log("GOTFILE " + profilePicture);
    } else {
      console.log("GOT NO FILE");
    }

    const token = crypto.randomBytes(64).toString("hex");
    // Create a new user
    const newUser = new User({
      userName,
      nickname,
      password,
      profilePicture,
      token,
    });
    await newUser.save();

    res.status(200).json(newUser);
  } catch (error) {
    console.error(error);
    res.status(500).json({ msg: "Server error" });
  }
};
