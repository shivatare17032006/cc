const express = require('express');
const MenuItem = require('../models/menuItem.model');

const router = express.Router();

const seedItems = [
  {
    name: 'Sabudana Vada',
    price: 45,
    description: 'Crispy fasting snack made with tapioca pearls and peanuts',
    imageIcon: '🥔',
    imageUrl: 'https://source.unsplash.com/600x400/?sago,fritter',
  },
  {
    name: 'Vada Pav',
    price: 35,
    description: 'Spicy potato fritter in bread bun',
    imageIcon: '🥪',
    imageUrl: 'https://source.unsplash.com/600x400/?vada,pav',
  },
  {
    name: 'Bread Pattis',
    price: 30,
    description: 'Crispy bread patties with mildly spiced filling',
    imageIcon: '🥙',
    imageUrl: 'https://source.unsplash.com/600x400/?bread,patty',
  },
  {
    name: 'Idli',
    price: 40,
    description: 'Steamed rice cakes served with chutney',
    imageIcon: '🍘',
    imageUrl: 'https://source.unsplash.com/600x400/?idli,south-indian-food',
  },
  {
    name: 'Rava Paratha',
    price: 55,
    description: 'Crisp semolina flatbread with ghee',
    imageIcon: '🫓',
    imageUrl: 'https://source.unsplash.com/600x400/?paratha,flatbread',
  },
  {
    name: 'Aloo Paratha',
    price: 60,
    description: 'Stuffed flatbread with spiced potato',
    imageIcon: '🫓',
    imageUrl: 'https://source.unsplash.com/600x400/?aloo,paratha',
  },
  {
    name: 'Methi Paratha',
    price: 60,
    description: 'Fenugreek flatbread with butter',
    imageIcon: '🫓',
    imageUrl: 'https://source.unsplash.com/600x400/?methi,paratha',
  },
  {
    name: 'Palak Paratha',
    price: 60,
    description: 'Spinach flatbread, wholesome and filling',
    imageIcon: '🫓',
    imageUrl: 'https://source.unsplash.com/600x400/?palak,paratha',
  },
  {
    name: 'Sandwich',
    price: 50,
    description: 'Grilled vegetable sandwich with chutney',
    imageIcon: '🥪',
    imageUrl: 'https://source.unsplash.com/600x400/?sandwich,grilled',
  },
  {
    name: 'Bajra Paratha',
    price: 65,
    description: 'Rustic millet flatbread served hot',
    imageIcon: '🫓',
    imageUrl: 'https://source.unsplash.com/600x400/?bajra,flatbread',
  },
  {
    name: 'Paneer Paratha',
    price: 75,
    description: 'Stuffed paneer paratha with butter',
    imageIcon: '🫓',
    imageUrl: 'https://source.unsplash.com/600x400/?paneer,paratha',
  },
  {
    name: 'Dhokla',
    price: 40,
    description: 'Soft and spongy steamed gram flour snack',
    imageIcon: '🟨',
    imageUrl: 'https://source.unsplash.com/600x400/?dhokla,gujarati-food',
  },
  {
    name: 'Plain Lassi',
    price: 45,
    description: 'Refreshing chilled sweet curd drink',
    imageIcon: '🥛',
    imageUrl: 'https://source.unsplash.com/600x400/?lassi,yogurt-drink',
  },
  {
    name: 'Mango Lassi',
    price: 55,
    description: 'Thick mango blended lassi',
    imageIcon: '🥭',
    imageUrl: 'https://source.unsplash.com/600x400/?mango,lassi',
  },
  {
    name: 'Watermelon Juice',
    price: 50,
    description: 'Freshly squeezed watermelon juice',
    imageIcon: '🍉',
    imageUrl: 'https://source.unsplash.com/600x400/?watermelon,juice',
  },
  {
    name: 'Papaya Juice',
    price: 50,
    description: 'Naturally sweet papaya cooler',
    imageIcon: '🍈',
    imageUrl: 'https://source.unsplash.com/600x400/?papaya,juice',
  },
  {
    name: 'Orange Juice',
    price: 55,
    description: 'Fresh orange juice with pulp',
    imageIcon: '🍊',
    imageUrl: 'https://source.unsplash.com/600x400/?orange,juice',
  },
  {
    name: 'Guava Juice',
    price: 55,
    description: 'Pink guava juice served chilled',
    imageIcon: '🍐',
    imageUrl: 'https://source.unsplash.com/600x400/?guava,juice',
  },
  {
    name: 'Mosambi Juice',
    price: 55,
    description: 'Sweet lime juice with light citrus notes',
    imageIcon: '🍋',
    imageUrl: 'https://source.unsplash.com/600x400/?sweet-lime,juice',
  },
  {
    name: 'Limbu Sarbat',
    price: 30,
    description: 'Classic lemon cooler with a pinch of salt',
    imageIcon: '🍋',
    imageUrl: 'https://source.unsplash.com/600x400/?lemonade',
  },
  {
    name: 'Mango Rabdi',
    price: 90,
    description: 'Rich mango flavored rabdi dessert',
    imageIcon: '🥭',
    imageUrl: 'https://source.unsplash.com/600x400/?rabdi,mango-dessert',
  },
  {
    name: 'Plain Rabdi',
    price: 80,
    description: 'Traditional thickened milk dessert',
    imageIcon: '🍮',
    imageUrl: 'https://source.unsplash.com/600x400/?rabri,indian-dessert',
  },
  {
    name: 'Mix Fruit Rabdi',
    price: 95,
    description: 'Rabdi topped with seasonal mixed fruits',
    imageIcon: '🍇',
    imageUrl: 'https://source.unsplash.com/600x400/?fruit,dessert,bowl',
  },
  {
    name: 'Cold Coffee',
    price: 70,
    description: 'Creamy chilled coffee with ice',
    imageIcon: '☕',
    imageUrl: 'https://source.unsplash.com/600x400/?cold,coffee',
  },
  {
    name: 'Anjir Shake',
    price: 90,
    description: 'Nutritious fig milkshake',
    imageIcon: '🥤',
    imageUrl: 'https://source.unsplash.com/600x400/?fig,milkshake',
  },
  {
    name: 'Chiku Shake',
    price: 85,
    description: 'Creamy sapota milkshake',
    imageIcon: '🥤',
    imageUrl: 'https://source.unsplash.com/600x400/?sapota,milkshake',
  },
  {
    name: 'Oreo Shake',
    price: 95,
    description: 'Chocolatey Oreo cookie shake',
    imageIcon: '🥤',
    imageUrl: 'https://source.unsplash.com/600x400/?oreo,milkshake',
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
