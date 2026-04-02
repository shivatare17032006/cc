const express = require('express');
const MenuItem = require('../models/menuItem.model');

const router = express.Router();

const seedItems = [
  {
    name: 'Sabudana Vada',
    price: 45,
    description: 'Crispy fasting snack made with tapioca pearls and peanuts',
    imageIcon: '🥔',
    imageUrl: 'assets/menu/sabudana_vada.png',
  },
  {
    name: 'Vada Pav',
    price: 35,
    description: 'Spicy potato fritter in bread bun',
    imageIcon: '🥪',
    imageUrl: 'assets/menu/vada_pav.png',
  },
  {
    name: 'Bread Pattis',
    price: 30,
    description: 'Crispy bread patties with mildly spiced filling',
    imageIcon: '🥙',
    imageUrl: 'assets/menu/bread_pattis.png',
  },
  {
    name: 'Idli',
    price: 40,
    description: 'Steamed rice cakes served with chutney',
    imageIcon: '🍘',
    imageUrl: 'assets/menu/idli.png',
  },
  {
    name: 'Rava Paratha',
    price: 55,
    description: 'Crisp semolina flatbread with ghee',
    imageIcon: '🫓',
    imageUrl: 'assets/menu/rava_paratha.png',
  },
  {
    name: 'Aloo Paratha',
    price: 60,
    description: 'Stuffed flatbread with spiced potato',
    imageIcon: '🫓',
    imageUrl: 'assets/menu/aloo_paratha.png',
  },
  {
    name: 'Methi Paratha',
    price: 60,
    description: 'Fenugreek flatbread with butter',
    imageIcon: '🫓',
    imageUrl: 'assets/menu/methi_paratha.png',
  },
  {
    name: 'Palak Paratha',
    price: 60,
    description: 'Spinach flatbread, wholesome and filling',
    imageIcon: '🫓',
    imageUrl: 'assets/menu/palak_paratha.png',
  },
  {
    name: 'Sandwich',
    price: 50,
    description: 'Grilled vegetable sandwich with chutney',
    imageIcon: '🥪',
    imageUrl: 'assets/menu/sandwich.png',
  },
  {
    name: 'Paneer Paratha',
    price: 75,
    description: 'Stuffed paneer paratha with butter',
    imageIcon: '🫓',
    imageUrl: 'assets/menu/paneer_paratha.png',
  },
  {
    name: 'Bajra Paratha',
    price: 65,
    description: 'Rustic millet flatbread served hot',
    imageIcon: '🫓',
    imageUrl: 'assets/menu/bajra_paratha.png',
  },
  {
    name: 'Dhokla',
    price: 40,
    description: 'Soft and spongy steamed gram flour snack',
    imageIcon: '🟨',
    imageUrl: 'assets/menu/dhokla.png',
  },
  {
    name: 'Plain Lassi',
    price: 45,
    description: 'Refreshing chilled sweet curd drink',
    imageIcon: '🥛',
    imageUrl: 'assets/menu/plain_lassi.png',
  },
  {
    name: 'Mango Lassi',
    price: 55,
    description: 'Thick mango blended lassi',
    imageIcon: '🥭',
    imageUrl: 'assets/menu/mango_lassi.png',
  },
  {
    name: 'Watermelon Juice',
    price: 50,
    description: 'Freshly squeezed watermelon juice',
    imageIcon: '🍉',
    imageUrl: 'assets/menu/watermelon_juice.png',
  },
  {
    name: 'Papaya Juice',
    price: 50,
    description: 'Naturally sweet papaya cooler',
    imageIcon: '🍈',
    imageUrl: 'assets/menu/papaya_juice.png',
  },
  {
    name: 'Orange Juice',
    price: 55,
    description: 'Fresh orange juice with pulp',
    imageIcon: '🍊',
    imageUrl: 'assets/menu/orange_juice.png',
  },
  {
    name: 'Guava Juice',
    price: 55,
    description: 'Pink guava juice served chilled',
    imageIcon: '🍐',
    imageUrl: 'assets/menu/guava_juice.png',
  },
  {
    name: 'Mosambi Juice',
    price: 55,
    description: 'Sweet lime juice with light citrus notes',
    imageIcon: '🍋',
    imageUrl: 'assets/menu/mosambi_juice.png',
  },
  {
    name: 'Limbu Sarbat',
    price: 30,
    description: 'Classic lemon cooler with a pinch of salt',
    imageIcon: '🍋',
    imageUrl: 'assets/menu/limbu_sarbat.png',
  },
  {
    name: 'Mango Rabdi',
    price: 90,
    description: 'Rich mango flavored rabdi dessert',
    imageIcon: '🥭',
    imageUrl: 'assets/menu/mango_rabdi.png',
  },
  {
    name: 'Plain Rabdi',
    price: 80,
    description: 'Traditional thickened milk dessert',
    imageIcon: '🍮',
    imageUrl: 'assets/menu/plain_rabdi.png',
  },
  {
    name: 'Mix Fruit Rabdi',
    price: 95,
    description: 'Rabdi topped with seasonal mixed fruits',
    imageIcon: '🍇',
    imageUrl: 'assets/menu/mix_fruit_rabdi.png',
  },
  {
    name: 'Cold Coffee',
    price: 70,
    description: 'Creamy chilled coffee with ice',
    imageIcon: '☕',
    imageUrl: 'assets/menu/cold_coffee.png',
  },
  {
    name: 'Anjir Shake',
    price: 90,
    description: 'Nutritious fig milkshake',
    imageIcon: '🥤',
    imageUrl: 'assets/menu/anjir_shake.png',
  },
  {
    name: 'Chiku Shake',
    price: 85,
    description: 'Creamy sapota milkshake',
    imageIcon: '🥤',
    imageUrl: 'assets/menu/chiku_shake.png',
  },
  {
    name: 'Oreo Shake',
    price: 95,
    description: 'Chocolatey Oreo cookie shake',
    imageIcon: '🥤',
    imageUrl: 'assets/menu/oreo_shake.png',
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
