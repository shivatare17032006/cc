const express = require('express');

const Cart = require('../models/cart.model');
const Order = require('../models/order.model');
const { requireAuth } = require('../middleware/auth.middleware');

const router = express.Router();

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
    });

    cart.items = [];
    await cart.save();

    return res.status(201).json(order);
  } catch (error) {
    return next(error);
  }
});

module.exports = router;