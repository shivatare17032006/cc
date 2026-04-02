const express = require('express');
const MenuItem = require('../models/menuItem.model');

const router = express.Router();

const seedItems = [
  {
    name: 'Vada Pav',
    price: 35,
    description: 'Spicy potato fritter in bread bun',
    imageIcon: '🥪',
    imageUrl: 'https://via.placeholder.com/400x300/FFA500/FFFFFF?text=Vada+Pav',
  },
  {
    name: 'Aloo Paratha',
    price: 45,
    description: 'Stuffed flatbread with spiced potato',
    imageIcon: '🫓',
    imageUrl: 'https://via.placeholder.com/400x300/FFA500/FFFFFF?text=Aloo+Paratha',
  },
  {
    name: 'Methi Paratha',
    price: 40,
    description: 'Fenugreek flatbread with butter',
    imageIcon: '🥙',
    imageUrl: 'https://via.placeholder.com/400x300/FFA500/FFFFFF?text=Methi+Paratha',
  },
  {
    name: 'Poli Bhaji',
    price: 60,
    description: 'Soft bread with spicy vegetable curry',
    imageIcon: '🍛',
    imageUrl: 'https://via.placeholder.com/400x300/FFA500/FFFFFF?text=Poli+Bhaji',
  },
  {
    name: 'Upma',
    price: 35,
    description: 'Savory semolina porridge',
    imageIcon: '🍲',
    imageUrl: 'https://via.placeholder.com/400x300/FFA500/FFFFFF?text=Upma',
  },
  {
    name: 'Poha',
    price: 30,
    description: 'Flattened rice with spices',
    imageIcon: '🍚',
    imageUrl: 'https://via.placeholder.com/400x300/FFA500/FFFFFF?text=Poha',
  },
  {
    name: 'Spring Roll',
    price: 40,
    description: 'Crispy vegetable rolls',
    imageIcon: '🥙',
    imageUrl: 'https://via.placeholder.com/400x300/FFA500/FFFFFF?text=Spring+Roll',
  },
  {
    name: 'Gulab Jamun',
    price: 35,
    description: 'Sweet milk-solid dumplings',
    imageIcon: '🍡',
    imageUrl: 'https://via.placeholder.com/400x300/FFA500/FFFFFF?text=Gulab+Jamun',
  },
  {
    name: 'Ice Cream',
    price: 45,
    description: 'Assorted flavors',
    imageIcon: '🍨',
    imageUrl: 'https://via.placeholder.com/400x300/FFA500/FFFFFF?text=Ice+Cream',
  },
];

router.get('/', async (req, res, next) => {
  try {
    const items = await MenuItem.find().sort({ createdAt: 1 });
    res.json(items);
  } catch (error) {
    next(error);
  }
});

router.post('/', async (req, res, next) => {
  try {
    const { name, price } = req.body;
    if (!name || typeof price !== 'number') {
      return res.status(400).json({ message: 'name and numeric price are required' });
    }

    const item = await MenuItem.create(req.body);
    return res.status(201).json(item);
  } catch (error) {
    return next(error);
  }
});

router.patch('/:id', async (req, res, next) => {
  try {
    const item = await MenuItem.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });

    if (!item) {
      return res.status(404).json({ message: 'Menu item not found' });
    }

    return res.json(item);
  } catch (error) {
    return next(error);
  }
});

router.delete('/:id', async (req, res, next) => {
  try {
    const item = await MenuItem.findByIdAndDelete(req.params.id);
    if (!item) {
      return res.status(404).json({ message: 'Menu item not found' });
    }

    return res.json({ ok: true });
  } catch (error) {
    return next(error);
  }
});

router.post('/seed', async (req, res, next) => {
  try {
    await MenuItem.deleteMany({});
    const inserted = await MenuItem.insertMany(seedItems);
    return res.status(201).json({ count: inserted.length });
  } catch (error) {
    return next(error);
  }
});

module.exports = router;
