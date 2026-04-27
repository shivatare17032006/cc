const express = require('express');
const mongoose = require('mongoose');

const Complaint = require('../models/complaint.model');
const { requireAuth, requireRole } = require('../middleware/auth.middleware');

const router = express.Router();

const OWNER_ROLES = ['admin', 'canteen_owner'];

router.get('/', requireAuth, async (req, res, next) => {
  try {
    const complaints = await Complaint.find({ userId: req.user.userId }).sort({ createdAt: -1 });
    return res.json(complaints);
  } catch (error) {
    return next(error);
  }
});

router.post('/', requireAuth, async (req, res, next) => {
  try {
    const { type, description, priority, contactEmail, isAnonymous } = req.body;

    if (!type || typeof type !== 'string' || !description || typeof description !== 'string') {
      return res.status(400).json({ message: 'type and description are required' });
    }

    const complaint = await Complaint.create({
      userId: req.user.userId,
      type: type.trim(),
      description: description.trim(),
      priority: ['Low', 'Medium', 'High'].includes(priority) ? priority : 'Medium',
      contactEmail: typeof contactEmail === 'string' ? contactEmail.trim() : '',
      isAnonymous: Boolean(isAnonymous),
    });

    return res.status(201).json(complaint);
  } catch (error) {
    return next(error);
  }
});

router.patch('/:id/resolve', requireAuth, async (req, res, next) => {
  try {
    const complaint = await Complaint.findOneAndUpdate(
      { _id: req.params.id, userId: req.user.userId },
      { status: 'Resolved' },
      { new: true, runValidators: true }
    );

    if (!complaint) {
      return res.status(404).json({ message: 'Complaint not found' });
    }

    return res.json(complaint);
  } catch (error) {
    return next(error);
  }
});

router.get('/owner', requireAuth, requireRole(OWNER_ROLES), async (req, res, next) => {
  try {
    const complaints = await Complaint.find({})
      .populate('userId', 'name email')
      .sort({ createdAt: -1 });

    const payload = complaints.map((complaint) => ({
      _id: complaint._id,
      complaintId: complaint.complaintId,
      type: complaint.type,
      description: complaint.description,
      priority: complaint.priority,
      status: complaint.status,
      contactEmail: complaint.contactEmail,
      isAnonymous: complaint.isAnonymous,
      ownerReply: complaint.ownerReply,
      repliedAt: complaint.repliedAt,
      createdAt: complaint.createdAt,
      student: {
        id: complaint.userId?._id,
        name: complaint.userId?.name || 'Anonymous',
        email: complaint.userId?.email || '',
      },
    }));

    return res.json(payload);
  } catch (error) {
    return next(error);
  }
});

router.patch('/owner/:id/reply', requireAuth, requireRole(OWNER_ROLES), async (req, res, next) => {
  try {
    const { reply, status } = req.body;

    if (!reply || typeof reply !== 'string' || !reply.trim()) {
      return res.status(400).json({ message: 'reply is required' });
    }

    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({ message: 'Invalid complaint id' });
    }

    const update = {
      ownerReply: reply.trim(),
      repliedAt: new Date(),
    };

    if (status && ['Open', 'Resolved'].includes(status)) {
      update.status = status;
    }

    const complaint = await Complaint.findByIdAndUpdate(
      req.params.id,
      update,
      { new: true, runValidators: true }
    ).populate('userId', 'name email');

    if (!complaint) {
      return res.status(404).json({ message: 'Complaint not found' });
    }

    return res.json({
      _id: complaint._id,
      complaintId: complaint.complaintId,
      type: complaint.type,
      description: complaint.description,
      priority: complaint.priority,
      status: complaint.status,
      contactEmail: complaint.contactEmail,
      isAnonymous: complaint.isAnonymous,
      ownerReply: complaint.ownerReply,
      repliedAt: complaint.repliedAt,
      createdAt: complaint.createdAt,
      student: {
        id: complaint.userId?._id,
        name: complaint.userId?.name || 'Anonymous',
        email: complaint.userId?.email || '',
      },
    });
  } catch (error) {
    return next(error);
  }
});

module.exports = router;
