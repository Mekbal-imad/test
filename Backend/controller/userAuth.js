const jwt = require("jsonwebtoken");
const bcrypt = require("bcrypt");
const User = require("../model/user");
const mongoose = require("mongoose");
const { cloudinary } = require("../config/cd");


async function Register(req, res) {
    try {
        const { username, email, password, role, field, number, dob, location } = req.body;
        let pdpUrl = null;
        if (req.file) {
            const result = await new Promise((resolve, reject) => {
                const stream = cloudinary.uploader.upload_stream(
                    { folder: "pdp" },
                    (error, result) => {
                        if (error) reject(error);
                        else resolve(result)
                    }
                )
                stream.end(req.file.buffer);
            });
            pdpUrl = result.secure_url ;
        }

        if (!email || !password || !username || !role) {
            return res.status(400).json({
                error: "Missing required fields"
            });
        }

        if (!["user", "entreprise"].includes(role)) {
            return res.status(400).json({
                error: "Invalid role"
            });
        }

        if (role === "entreprise" && !field) {
            return res.status(400).json({
                error: "Entreprise field is required"
            });
        }

        const existing = await User.findOne({
            $or: [{ email }, { username }]
        });

        if (existing) {
            return res.status(400).json({
                error: "Username or email already exists",
            });
        }

        const hashed = await bcrypt.hash(password, 10);

        const isVerified = role === "user";

        const newUser = await User.create({
            pdpUrl,
            username,
            email,
            password: hashed,
            role,
            isVerified,
            field: role === 'entreprise' ? field : undefined,
            number: role === 'user' && number ? [number] : (role === 'entreprise' && number ? number : undefined),
            dob: role === 'user' && dob ? dob : undefined,
            location: role === 'entreprise' && location ? location : undefined,
        });
        const token = jwt.sign(
            { id: newUser._id, role: role },
            process.env.JWT_SECRET,
            { expiresIn: "1d" }
        );
        return res.status(201).json({
            message: "User created successfully",
            token,
            user: {
                id: newUser._id,
                username: newUser.username,
                role: newUser.role,
                email: newUser.email,
                location: newUser.location,
                number: newUser.number,
                dob: newUser.dob,
                field: newUser.field,
                pdpUrl: newUser.pdpUrl,
            }
        });

    } catch (err) {
        return res.status(500).json({
            error: err.message
        });
    }
}

async function Login(req, res) {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({
                message: "Email and password are required"
            });
        }

        const user = await User
            .findOne({ email })
            .select("+password");

        if (!user) {
            return res.status(404).json({
                message: "User not found",

            });
        }

        const isMatch = await bcrypt.compare(password, user.password);

        if (!isMatch) {
            return res.status(401).json({
                message: "Wrong password"
            });
        }
        const token = jwt.sign(
            { id: user._id, role: user.role },
            process.env.JWT_SECRET,
            { expiresIn: "1d" }
        );
        return res.status(200).json({
    message: "Login successful",
    token,
    user: {
        id: user._id,
        dob: user.dob,
        username: user.username,
        role: user.role,
        email: user.email,
        location: user.location,
        number: user.number,
        field: user.field,
        pdpUrl: user.pdpUrl,
    }
});

    } catch (err) {
        return res.status(500).json({
            message: err.message
        });
    }
}

module.exports = { Register, Login };