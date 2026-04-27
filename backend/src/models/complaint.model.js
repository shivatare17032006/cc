const mongoose = require('mongoose');

function generateComplaintId() {
  const timePart = Date.now().toString(36).toUpperCase();
  const randPart = Math.random().toString(36).slice(2, 6).toUpperCase();
  return `CMP-${timePart}-${randPart}`;
}

const complaintSchema = new mongoose.Schema(
  {
    complaintId: {
      type: String,
      required: true,
      default: generateComplaintId,
      trim: true,
    },
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    type: { type: String, required: true, trim: true },
    description: { type: String, required: true, trim: true },
    priority: { type: String, enum: ['Low', 'Medium', 'High'], default: 'Medium' },
    contactEmail: { type: String, default: '', trim: true },
    isAnonymous: { type: Boolean, default: false },
    status: { type: String, enum: ['Open', 'Resolved'], default: 'Open' },
    ownerReply: { type: String, default: '', trim: true },
    repliedAt: { type: Date },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('Complaint', complaintSchema);
