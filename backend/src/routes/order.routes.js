const express = require('express');
const mongoose = require('mongoose');

const Cart = require('../models/cart.model');
const Order = require('../models/order.model');
const { requireAuth, requireRole } = require('../middleware/auth.middleware');

const router = express.Router();

const OWNER_ROLES = ['admin', 'canteen_owner'];
const STATUS_OPTIONS = ['Pending', 'In Progress', 'Done'];

function getRangeStart(type) {
  const now = new Date();

  if (type === 'day') {
    return new Date(now.getFullYear(), now.getMonth(), now.getDate());
  }

  if (type === 'week') {
    const day = now.getDay();
    const diff = day === 0 ? -6 : 1 - day;
    const start = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    start.setDate(start.getDate() + diff);
    return start;
  }

  if (type === 'month') {
    return new Date(now.getFullYear(), now.getMonth(), 1);
  }

  return null;
}

async function getRevenueForRange(rangeType) {
  const start = getRangeStart(rangeType);
  if (!start) {
    return 0;
  }

  const result = await Order.aggregate([
    {
      $match: {
        createdAt: { $gte: start },
        status: 'Done',
      },
    },
    {
      $group: {
        _id: null,
        total: { $sum: '$totalAmount' },
      },
    },
  ]);

  return result[0]?.total || 0;
}

async function getTopCustomers(limit = 5) {
  const result = await Order.aggregate([
    { $match: { status: 'Done' } },
    {
      $group: {
        _id: '$userId',
        totalSpent: { $sum: '$totalAmount' },
        totalOrders: { $sum: 1 },
      },
    },
    { $sort: { totalSpent: -1 } },
    { $limit: limit },
    {
      $lookup: {
        from: 'users',
        localField: '_id',
        foreignField: '_id',
        as: 'user',
      },
    },
    {
      $unwind: {
        path: '$user',
        preserveNullAndEmptyArrays: true,
      },
    },
    {
      $project: {
        _id: 0,
        userId: '$_id',
        name: '$user.name',
        email: '$user.email',
        totalSpent: 1,
        totalOrders: 1,
      },
    },
  ]);

  return result;
}

async function getTopItems(limit = 5) {
  const result = await Order.aggregate([
    { $match: { status: 'Done' } },
    { $unwind: '$items' },
    {
      $group: {
        _id: '$items.name',
        totalQuantity: { $sum: '$items.quantity' },
        totalRevenue: { $sum: '$items.lineTotal' },
      },
    },
    { $sort: { totalQuantity: -1 } },
    { $limit: limit },
    {
      $project: {
        _id: 0,
        itemName: '$_id',
        totalQuantity: 1,
        totalRevenue: 1,
      },
    },
  ]);

  return result;
}

router.get('/', requireAuth, async (req, res, next) => {
  try {
    const orders = await Order.find({ userId: req.user.userId }).sort({ createdAt: -1 });
    return res.json(orders);
  } catch (error) {
    return next(error);
  }
});

router.post('/', requireAuth, async (req, res, next) => {
  try {
    const cart = await Cart.findOne({ userId: req.user.userId });

    if (!cart || cart.items.length === 0) {
      return res.status(400).json({ message: 'Cart is empty' });
    }

    const orderItems = cart.items.map((item) => ({
      menuItemId: item.menuItemId,
      name: item.name,
      imageIcon: item.imageIcon,
      unitPrice: item.price,
      quantity: item.quantity,
      lineTotal: item.price * item.quantity,
    }));

    const totalAmount = orderItems.reduce((sum, item) => sum + item.lineTotal, 0);

    const order = await Order.create({
      userId: req.user.userId,
      items: orderItems,
      totalAmount,
      status: 'Pending',
      statusUpdatedAt: new Date(),
    });

    cart.items = [];
    await cart.save();

    return res.status(201).json(order);
  } catch (error) {
    return next(error);
  }
});

router.get('/owner', requireAuth, requireRole(OWNER_ROLES), async (req, res, next) => {
  try {
    const orders = await Order.find({})
      .populate('userId', 'name email')
      .sort({ createdAt: -1 });

    const payload = orders.map((order) => ({
      _id: order._id,
      orderId: order.orderId,
      status: order.status,
      statusUpdatedAt: order.statusUpdatedAt,
      createdAt: order.createdAt,
      totalAmount: order.totalAmount,
      items: order.items,
      student: {
        id: order.userId?._id,
        name: order.userId?.name || 'Unknown',
        email: order.userId?.email || '',
      },
    }));

    return res.json(payload);
  } catch (error) {
    return next(error);
  }
});

router.patch('/owner/:id/status', requireAuth, requireRole(OWNER_ROLES), async (req, res, next) => {
  try {
    const { status } = req.body;

    if (!STATUS_OPTIONS.includes(status)) {
      return res.status(400).json({
        message: 'status must be one of: Pending, In Progress, Done',
      });
    }

    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({ message: 'Invalid order id' });
    }

    const order = await Order.findByIdAndUpdate(
      req.params.id,
      {
        status,
        statusUpdatedAt: new Date(),
      },
      { new: true, runValidators: true }
    ).populate('userId', 'name email');

    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }

    return res.json({
      _id: order._id,
      orderId: order.orderId,
      status: order.status,
      statusUpdatedAt: order.statusUpdatedAt,
      createdAt: order.createdAt,
      totalAmount: order.totalAmount,
      items: order.items,
      student: {
        id: order.userId?._id,
        name: order.userId?.name || 'Unknown',
        email: order.userId?.email || '',
      },
    });
  } catch (error) {
    return next(error);
  }
});

router.get('/owner/dashboard/revenue', requireAuth, requireRole(OWNER_ROLES), async (req, res, next) => {
  try {
    const [dayRevenue, weekRevenue, monthRevenue, topCustomers, topItems] = await Promise.all([
      getRevenueForRange('day'),
      getRevenueForRange('week'),
      getRevenueForRange('month'),
      getTopCustomers(5),
      getTopItems(5),
    ]);

    const topCustomer = topCustomers[0] || null;
    const topItem = topItems[0] || null;

    return res.json({
      revenue: {
        day: dayRevenue,
        week: weekRevenue,
        month: monthRevenue,
      },
      topCustomers,
      topItems,
      topCustomer,
      topItem,
      generatedAt: new Date(),
    });
  } catch (error) {
    return next(error);
  }
});

module.exports = router;