const express = require("express");
const router = express.Router();

const controller = require("../controllers/loginController");
const upload = require("../multer");
router.post(
  "/registerUser",
  upload.single("profilePic"),
  controller.registerUser
);
router.post("/loginUser", controller.loginUser);

module.exports = router;
