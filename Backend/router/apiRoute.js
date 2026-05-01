const express = require("express");
const { Register, Login } = require("../controller/userAuth");
const uploadPDP = require("../controller/uploadPdp");
const upload = require("../middleware/pdpMulter");
const authMiddleware = require("../middleware/authVerification");
const JobUpload = require("../controller/postJob") ;
const delJob = require("../controller/delJob");
const  changePassword  = require("../controller/changepassword");
const filterJobs = require("../controller/JobsFilter");
const getJobInfo = require("../controller/getJobInfo");
const saveJob = require("../controller/saveJob");
const testServer = require("../controller/serverTest");
const unsaveJob = require("../controller/unsaveJob");
const getUserPostedJobs = require("../controller/getUserPostedJobs");
const getSavedJobs = require("../controller/getSavedJobs");
const { deleteAccount } = require("../controller/deleteAccount");
const updateProfile = require("../controller/updateProfile");
const updateJob = require("../controller/UpdateJob");
const sendChangePassword = require("../controller/sendChangePasswordCode");
const confirmNewPassword = require("../controller/confirmNewPassword");


const router = express.Router();


router.post("/register", upload.single('pdp') , Register);
router.post("/uploadPDP", upload.single('pdp'), uploadPDP);
router.post("/login", Login);
router.post("/postJob" , authMiddleware, JobUpload ) ;



router.put("/save/:jobId", authMiddleware, saveJob);
router.put("/updateProfile", authMiddleware, updateProfile);
router.put("/updateJob/:id", authMiddleware, updateJob);
router.put("/sendChangePassword" , sendChangePassword);
router.put("/confirmNewPassword" , confirmNewPassword);
router.put("/changePassword", authMiddleware, changePassword);

router.delete("/deleteAccount", authMiddleware, deleteAccount);
router.delete("/delJob/:id" , authMiddleware, delJob);
router.delete("/unsave/:jobId", authMiddleware, unsaveJob);

router.get("/userJobs", authMiddleware, getUserPostedJobs)
router.get("/jobs", authMiddleware, filterJobs);
router.get("/jobs/:id", authMiddleware, getJobInfo);
router.get("/savedJobs", authMiddleware, getSavedJobs);

router.get("/testServer" , testServer);

module.exports = router;