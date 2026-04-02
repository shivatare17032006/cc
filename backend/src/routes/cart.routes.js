const express = require('express');
const mongoose = require('mongoose');

const Cart = require('../models/cart.model');
const MenuItem = require('../models/menuItem.model');
const { requireAuth } = require('../middleware/auth.middleware');

const router = express.Router();

async function findOrCreateCart(userId) {
  let cart = await Cart.findOne({ userId });
  if (!cart) {
    cart = await Cart.create({ userId, items: [] });
  }
  return cart;
}

router.get('/', requireAuth, async (req, res, next) => {
  try {
    const cart = await findOrCreateCart(req.user.userId);
    return res.json(cart);
  } catch (error) {
    return next(error);
  }
});

router.post('/items', requireAuth, async (req, res, next) => {
  try {
    const { menuItemId, quantity = 1 } = req.body;

    if (!menuItemId || !mongoose.Types.ObjectId.isValid(menuItemId)) {
      return res.status(400).json({ message: 'Valid menuItemId is required' });
    }

    const item = await MenuItem.findById(menuItemId);
    if (!item) {
      return res.status(404).json({ message: 'Menu item not found' });
    }

    const cart = await findOrCreateCart(req.user.userId);
    const index = cart.items.findIndex((x) => x.menuItemId.toString() === menuItemId);

    if (index >= 0) {
      cart.items[index].quantity += Number(quantity) || 1;
    } else {
      cart.items.push({
        menuItemId: item._id,
        name: item.name,
        imageIcon: item.imageIcon,
        price: item.price,
        quantity: Math.max(1, Number(quantity) || 1),
      });
    }

    await cart.save();
    return res.status(201).json(cart);
  } catch (error) {
    return next(error);
  }
});

router.patch('/items/:menuItemId', requireAuth, async (req, res, next) => {
  try {
    const { menuItemId } = req.params;
    const { quantity } = req.body;

    if (!Number.isInteger(quantity)) {
      return res.status(400).json({ message: 'quantity must be an integer' });
    }

    const cart = await findOrCreateCart(req.user.userId);
    const index = cart.items.findIndex((x) => x.menuItemId.toString() === menuItemId);

    if (index < 0) {
      return res.status(404).json({ message: 'Cart item not found' });
    }

    if (quantity <= 0) {
      cart.items.splice(index, 1);
    } else {
      cart.items[index].quantity = quantity;
    }

    await cart.save();
    return res.json(cart);
  } catch (error) {
    return next(error);
  }
});

router.delete('/items/:menuItemId', requireAuth, async (req, res, next) => {
  try {
    const { menuItemId } = req.params;
    const cart = await findOrCreateCart(req.user.userId);

    cart.items = cart.items.filter((x) => x.menuItemId.toString() !== menuItemId);
    await cart.save();

    return res.json(cart);
  } catch (error) {
    return next(error);
  }
});

router.delete('/', requireAuth, async (req, res, next) => {
  try {
    const cart = await findOrCreateCart(req.user.userId);
    cart.items = [];
    await cart.save();
    return res.json(cart);
  } catch (error) {
    return next(error);
  }
});

module.exports = router;