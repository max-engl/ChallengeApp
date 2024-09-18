const express = require("express");
const router = express.Router();
const path = require("path");
const fs = require("fs");
const controller = require("../controllers/loginController");
const multer = require("multer");

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "uploads/profile_pics");
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  },
});
const upload = multer({ storage });
router.post(
  "/registerUser",
  upload.single("profilePic"),
  controller.registerUser
);
router.post("/loginUser", controller.loginUser);

module.exports = router;
