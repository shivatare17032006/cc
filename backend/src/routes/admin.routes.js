const express = require('express');

const Order = require('../models/order.model');
const Complaint = require('../models/complaint.model');
const User = require('../models/user.model');
const { requireAuth, requireAdmin } = require('../middleware/auth.middleware');

const router = express.Router();

router.use(requireAuth, requireAdmin);

router.get('/dashboard', async (req, res, next) => {
  try {
    const [
      totalOrders,
      totalRevenueAgg,
      openComplaints,
      totalUsers,
      recentOrders,
      recentComplaints,
    ] = await Promise.all([
      Order.countDocuments(),
      Order.aggregate([
        {
          $group: {
            _id: null,
            total: { $sum: '$totalAmount' },
          },
        },
      ]),
      Complaint.countDocuments({ status: 'Open' }),
      User.countDocuments(),
      Order.find()
        .sort({ createdAt: -1 })
        .limit(10)
        .populate('userId', 'name email'),
      Complaint.find()
        .sort({ createdAt: -1 })
        .limit(10)
        .populate('userId', 'name email'),
    ]);

    const statusCounts = await Order.aggregate([
      {
        $group: {
          _id: '$status',
          count: { $sum: 1 },
        },
      },
    ]);

    const orderStatus = {
      Pending: 0,
      Preparing: 0,
      Ready: 0,
      Completed: 0,
    };

    for (const item of statusCounts) {
      if (Object.prototype.hasOwnProperty.call(orderStatus, item._id)) {
        orderStatus[item._id] = item.count;
      }
    }

    return res.json({
      summary: {
        totalOrders,
        totalRevenue: totalRevenueAgg[0]?.total || 0,
        openComplaints,
        totalUsers,
      },
      orderStatus,
      recentOrders,
      recentComplaints,
    });
  } catch (error) {
    return next(error);
  }
});

router.get('/orders', async (req, res, next) => {
  try {
    const orders = await Order.find()
      .sort({ createdAt: -1 })
      .populate('userId', 'name email');
    return res.json(orders);
  } catch (error) {
    return next(error);
  }
});

router.patch('/orders/:id/status', async (req, res, next) => {
  try {
    const { status } = req.body;
    const allowedStatus = ['Pending', 'Preparing', 'Ready', 'Completed'];

    if (!allowedStatus.includes(status)) {
      return res.status(400).json({ message: 'Invalid order status' });
    }

    const order = await Order.findByIdAndUpdate(
      req.params.id,
      { status },
      { new: true, runValidators: true }
    ).populate('userId', 'name email');

    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }

    return res.json(order);
  } catch (error) {
    return next(error);
  }
});

router.get('/complaints', async (req, res, next) => {
  try {
    const complaints = await Complaint.find()
      .sort({ createdAt: -1 })
      .populate('userId', 'name email');
    return res.json(complaints);
  } catch (error) {
    return next(error);
  }
});

router.patch('/complaints/:id/resolve', async (req, res, next) => {
  try {
    const complaint = await Complaint.findByIdAndUpdate(
      req.params.id,
      { status: 'Resolved' },
      { new: true, runValidators: true }
    ).populate('userId', 'name email');

    if (!complaint) {
      return res.status(404).json({ message: 'Complaint not found' });
    }

    return res.json(complaint);
  } catch (error) {
    return next(error);
  }
});

router.get('/users', async (req, res, next) => {
  try {
    const users = await User.find()
      .select('-passwordHash')
      .sort({ createdAt: -1 })
      .limit(200);
    return res.json(users);
  } catch (error) {
    return next(error);
  }
});

module.exports = router;
