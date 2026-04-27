const mongoose = require('mongoose');

const userSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    email: { type: String, required: true, unique: true, lowercase: true, trim: true },
    phone: { type: String, default: '', trim: true },
    location: { type: String, default: '', trim: true },
    passwordHash: { type: String, required: true },
    role: { type: String, enum: ['student', 'admin', 'canteen_owner'], default: 'student' },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('User', userSchema);