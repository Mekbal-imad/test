const User = require("../model/user");

async function updateProfile(req, res) {
    try {
        const { username, location, number, dob } = req.body;
        const updateFields = {};
        if (dob) updateFields.dob = dob;
        if (username) updateFields.username = username;
        if (location) updateFields.location = location;
        if (number) updateFields.number = Array.isArray(number) ? number : [number];

        const user = await User.findByIdAndUpdate(
            req.user.id,
            { $set: updateFields },
            { new: true }
        ).select("-password");

        if (!user) {
            return res.status(404).json({ message: "User not found" });
        }

        return res.status(200).json({
            message: "Profile updated successfully",
            user
        });
    } catch (err) {
        return res.status(500).json({ message: err.message });
    }
}

module.exports = updateProfile;