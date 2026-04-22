const path = require('path');
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const dotenv = require('dotenv');

const User = require('../models/user.model');

dotenv.config({ path: path.resolve(__dirname, '../../.env') });

function parseArg(flag) {
  const index = process.argv.indexOf(flag);
  if (index === -1 || index === process.argv.length - 1) {
    return '';
  }
  return process.argv[index + 1];
}

async function run() {
  const email = parseArg('--email').toLowerCase().trim();
  const password = parseArg('--password');
  const name = parseArg('--name') || 'Admin User';

  if (!email || !password) {
    console.error('Usage: node src/scripts/create-admin.js --email <email> --password <password> [--name <name>]');
    process.exit(1);
  }

  if (!process.env.MONGODB_URI) {
    console.error('MONGODB_URI is missing in backend/.env');
    process.exit(1);
  }

  await mongoose.connect(process.env.MONGODB_URI);

  const passwordHash = await bcrypt.hash(password, 10);

  const existing = await User.findOne({ email });

  if (existing) {
    existing.role = 'admin';
    existing.passwordHash = passwordHash;
    if (!existing.name && name) {
      existing.name = name;
    }
    await existing.save();
    console.log(`Updated existing user as admin: ${email}`);
  } else {
    await User.create({
      name,
      email,
      passwordHash,
      role: 'admin',
      phone: '',
      location: '',
    });
    console.log(`Created new admin user: ${email}`);
  }

  await mongoose.disconnect();
  console.log('Done. You can now login to admin web using the same credentials.');
}

run().catch(async (error) => {
  console.error('Failed to create/promote admin:', error.message);
  try {
    await mongoose.disconnect();
  } catch (_) {
    // ignore disconnect errors
  }
  process.exit(1);
});
