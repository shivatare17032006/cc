const mongoose = require('mongoose');

const menuItemSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    price: { type: Number, required: true, min: 0 },
    description: { type: String, default: '' },
    imageUrl: { type: String, default: '' },
    imageIcon: { type: String, default: '' },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('MenuItem', menuItemSchema);
