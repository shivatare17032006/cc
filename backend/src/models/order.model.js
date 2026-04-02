const mongoose = require('mongoose');

function generateOrderId() {
  const timePart = Date.now().toString(36).toUpperCase();
  const randPart = Math.random().toString(36).slice(2, 8).toUpperCase();
  return `ORD-${timePart}-${randPart}`;
}

const orderItemSchema = new mongoose.Schema(
  {
    menuItemId: { type: mongoose.Schema.Types.ObjectId, ref: 'MenuItem', required: true },
    name: { type: String, required: true },
    imageIcon: { type: String, default: '' },
    unitPrice: { type: Number, required: true, min: 0 },
    quantity: { type: Number, required: true, min: 1 },
    lineTotal: { type: Number, required: true, min: 0 },
  },
  { _id: false }
);

const orderSchema = new mongoose.Schema(
  {
    orderId: {
      type: String,
      required: true,
      unique: true,
      default: generateOrderId,
      trim: true,
    },
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    items: { type: [orderItemSchema], required: true },
    totalAmount: { type: Number, required: true, min: 0 },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('Order', orderSchema);