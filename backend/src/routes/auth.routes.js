const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const User = require('../models/user.model');
const { requireAuth } = require('../middleware/auth.middleware');

const router = express.Router();

const DEMO_ADMIN_ENABLED = process.env.DEMO_ADMIN_ENABLED === 'true';
const DEMO_ADMIN_EMAIL = (process.env.DEMO_ADMIN_EMAIL || '').toLowerCase().trim();
const DEMO_ADMIN_PASSWORD = process.env.DEMO_ADMIN_PASSWORD || '';
const DEMO_ADMIN_USER_ID = process.env.DEMO_ADMIN_USER_ID || '000000000000000000000001';
const DEMO_ADMIN_NAME = process.env.DEMO_ADMIN_NAME || 'Admin';

function normalizeRole(userLike) {
  const raw = (userLike?.role ?? userLike?.userType ?? 'student').toString().trim().toLowerCase();
  if (raw === 'admin') return 'admin';
  if (raw === 'canteen_owner' || raw === 'canteen-owner' || raw === 'owner') return 'canteen_owner';
  return 'student';
}

function createToken(user, role) {
  return jwt.sign(
    {
      userId: user._id.toString(),
      email: user.email,
      role,
    },
    process.env.JWT_SECRET,
    { expiresIn: '7d' }
  );
}

router.post('/register', async (req, res, next) => {
  try {
    const { name, email, password, phone, location } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({
        message: 'name, email and password are required',
      });
    }

    const existing = await User.findOne({ email: email.toLowerCase().trim() });
    if (existing) {
      return res.status(409).json({ message: 'Email already registered' });
    }

    const passwordHash = await bcrypt.hash(password, 10);
    const user = await User.create({
      name: name.trim(),
      email: email.toLowerCase().trim(),
      phone: typeof phone === 'string' ? phone.trim() : '',
      location: typeof location === 'string' ? location.trim() : '',
      passwordHash,
    });

    const role = normalizeRole(user);
    const token = createToken(user, role);

    return res.status(201).json({
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        location: user.location,
        role,
      },
    });
  } catch (error) {
    if (error && error.code === 11000) {
      const duplicateField = Object.keys(error.keyPattern || {})[0] || 'field';
      return res.status(409).json({
        message: `${duplicateField} already registered`,
      });
    }
    return next(error);
  }
});

router.post('/login', async (req, res, next) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: 'email and password are required' });
    }

    const normalizedEmail = email.toLowerCase().trim();

    // Optional demo admin login (disabled by default for production safety).
    if (
      DEMO_ADMIN_ENABLED &&
      DEMO_ADMIN_EMAIL &&
      DEMO_ADMIN_PASSWORD &&
      normalizedEmail === DEMO_ADMIN_EMAIL &&
      password === DEMO_ADMIN_PASSWORD
    ) {
      const token = jwt.sign(
        {
          userId: DEMO_ADMIN_USER_ID,
          email: DEMO_ADMIN_EMAIL,
          role: 'admin',
        },
        process.env.JWT_SECRET,
        { expiresIn: '7d' }
      );

      return res.json({
        token,
        user: {
          id: DEMO_ADMIN_USER_ID,
          name: DEMO_ADMIN_NAME,
          email: DEMO_ADMIN_EMAIL,
          role: 'admin',
        },
      });
    }

    const user = await User.findOne({ email: normalizedEmail }).lean();
    if (!user) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const passwordHash = user.passwordHash || user.password;

    if (!passwordHash) {
      return res.status(400).json({
        message: 'This account is invalid. Please register again with a new email.',
      });
    }

    const isMatch = await bcrypt.compare(password, passwordHash);
    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const role = normalizeRole(user);
    const token = createToken(user, role);

    return res.json({
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role,
      },
    });
  } catch (error) {
    return next(error);
  }
});

router.get('/me', requireAuth, async (req, res, next) => {
  try {
    if (
      DEMO_ADMIN_ENABLED &&
      DEMO_ADMIN_EMAIL &&
      req.user?.email === DEMO_ADMIN_EMAIL &&
      req.user?.role === 'admin'
    ) {
      return res.json({
        _id: DEMO_ADMIN_USER_ID,
        name: DEMO_ADMIN_NAME,
        email: DEMO_ADMIN_EMAIL,
        phone: '',
        location: '',
        role: 'admin',
      });
    }

    const user = await User.findById(req.user.userId).select('-passwordHash');
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    return res.json(user);
  } catch (error) {
    return next(error);
  }
});

module.exports = router;