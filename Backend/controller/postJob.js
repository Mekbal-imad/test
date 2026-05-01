const mongoose = require("mongoose");
const jobPost = require("../model/post");

async function jobUpload(req, res) {
    try {
      
        const {
            jobTitle,
            entrepriseName,
            days,
            time,
            location,
            payment,
            description,
            requirements,
            contactNB,
            contactMail,
            website,
            entrepriseID
        } = req.body;

        const { start, end } = time;
        if (
            !jobTitle ||
            !entrepriseName ||
            !Array.isArray(days) || days.length === 0 ||
            !time?.start ||
            !time?.end ||
            !payment ||
            !description ||
            !Array.isArray(requirements) || requirements.length === 0 ||
            !Array.isArray(contactNB) || contactNB.length === 0 ||
            !Array.isArray(contactMail) || contactMail.length === 0
            
        ) {
            return res.status(400).json({
                error: "All fields are required and must be valid"
            });
        }
        const newPost = await jobPost.create({
            jobTitle,
            entrepriseName,
            days,
            time: {
                start,
                end
            },
            location,
            payment,
            description,
            requirements,
            contactNB,
            contactMail,
            website,
            entrepriseID : req.user.id 
        });
        return res.status(201).json({
            "message": "Post added successfully",
            "_id": newPost._id,
        })
    } catch (err) {
        return res.status(400).json({
            "message" : "Post not added" ,
            "error" : err.message
        })
    }
}

module.exports = jobUpload ;