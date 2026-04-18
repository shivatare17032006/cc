const express = require('express');

const Complaint = require('../models/complaint.model');
const { requireAuth } = require('../middleware/auth.middleware');

const router = express.Router();

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

module.exports = router;
