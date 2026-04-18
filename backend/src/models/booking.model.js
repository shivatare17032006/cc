const mongoose = require('mongoose');

const bookingSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    bookingDate: { type: String, required: true, trim: true }, // YYYY-MM-DD
    timeSlot: { type: String, required: true, trim: true },
    tableNumber: { type: Number, required: true, min: 1 },
    tableLabel: { type: String, required: true, trim: true },
    partySize: { type: Number, required: true, min: 1 },
    status: { type: String, enum: ['booked', 'released'], default: 'booked' },
    releaseReason: { type: String, default: '', trim: true },
    expiresAt: { type: Date, required: true },
    releasedAt: { type: Date, default: null },
  },
  {
    timestamps: true,
  }
);

bookingSchema.index(
  { bookingDate: 1, timeSlot: 1, tableNumber: 1, status: 1 },
  { unique: true, partialFilterExpression: { status: 'booked' } }
);

module.exports = mongoose.model('Booking', bookingSchema);
