const express = require('express');

const Booking = require('../models/booking.model');
const { requireAuth } = require('../middleware/auth.middleware');

const router = express.Router();

const TABLE_CAPACITY = {
  1: 4,
  2: 4,
  3: 4,
  4: 4,
  5: 4,
  6: 4,
  7: 4,
  8: 4,
  9: 4,
  10: 4,
  11: 6,
  12: 6,
  13: 6,
  14: 6,
  15: 6,
};

const BOOKING_HOLD_MINUTES = 60;
const SLOT_CUTOFF_MINUTES = 30;

function parseDateAndSlotStart(bookingDate, timeSlot) {
  if (!bookingDate || !timeSlot || !timeSlot.includes('-')) {
    return null;
  }

  const [startPart] = timeSlot.split('-').map((part) => part.trim());
  if (!startPart) {
    return null;
  }

  const match = startPart.match(/^(\d{1,2}):(\d{2})\s*(AM|PM)$/i);
  if (!match) {
    return null;
  }

  const yearMonthDay = bookingDate.split('-').map(Number);
  if (yearMonthDay.length !== 3 || yearMonthDay.some(Number.isNaN)) {
    return null;
  }

  let hour = Number(match[1]);
  const minute = Number(match[2]);
  const period = match[3].toUpperCase();

  if (period === 'PM' && hour !== 12) {
    hour += 12;
  }
  if (period === 'AM' && hour === 12) {
    hour = 0;
  }

  return new Date(yearMonthDay[0], yearMonthDay[1] - 1, yearMonthDay[2], hour, minute, 0, 0);
}

async function autoReleaseExpiredBookings() {
  const now = new Date();
  await Booking.updateMany(
    {
      status: 'booked',
      expiresAt: { $lte: now },
    },
    {
      $set: {
        status: 'released',
        releaseReason: 'auto-expired',
        releasedAt: now,
      },
    }
  );
}

router.get('/availability', requireAuth, async (req, res, next) => {
  try {
    await autoReleaseExpiredBookings();

    const { date, slot } = req.query;
    if (!date || !slot) {
      return res.status(400).json({ message: 'date and slot are required' });
    }

    const booked = await Booking.find({
      bookingDate: date,
      timeSlot: slot,
      status: 'booked',
    }).select('tableNumber');

    const unavailableTables = booked.map((entry) => entry.tableNumber);
    return res.json({ unavailableTables });
  } catch (error) {
    return next(error);
  }
});

router.get('/my', requireAuth, async (req, res, next) => {
  try {
    await autoReleaseExpiredBookings();

    const bookings = await Booking.find({ userId: req.user.userId }).sort({ createdAt: -1 });
    return res.json(bookings);
  } catch (error) {
    return next(error);
  }
});

router.post('/', requireAuth, async (req, res, next) => {
  try {
    await autoReleaseExpiredBookings();

    const { bookingDate, timeSlot, tableNumber, partySize } = req.body;

    if (!bookingDate || !timeSlot || !tableNumber || !partySize) {
      return res.status(400).json({
        message: 'bookingDate, timeSlot, tableNumber and partySize are required',
      });
    }

    const normalizedTableNumber = Number(tableNumber);
    const normalizedPartySize = Number(partySize);

    if (!Number.isInteger(normalizedTableNumber) || !TABLE_CAPACITY[normalizedTableNumber]) {
      return res.status(400).json({ message: 'Invalid table number' });
    }

    if (!Number.isInteger(normalizedPartySize) || normalizedPartySize <= 0) {
      return res.status(400).json({ message: 'Invalid party size' });
    }

    const tableCapacity = TABLE_CAPACITY[normalizedTableNumber];
    if (normalizedPartySize > tableCapacity) {
      return res.status(400).json({
        message: `Table ${normalizedTableNumber} capacity is ${tableCapacity}`,
      });
    }

    const slotStart = parseDateAndSlotStart(bookingDate, timeSlot);
    if (!slotStart || Number.isNaN(slotStart.getTime())) {
      return res.status(400).json({ message: 'Invalid booking date or time slot' });
    }

    const now = new Date();
    const cutoffThreshold = new Date(now.getTime() + SLOT_CUTOFF_MINUTES * 60 * 1000);
    if (slotStart <= cutoffThreshold) {
      return res.status(400).json({
        message: `Booking cutoff passed. Book at least ${SLOT_CUTOFF_MINUTES} minutes before slot start`,
      });
    }

    const expiresAt = new Date(now.getTime() + BOOKING_HOLD_MINUTES * 60 * 1000);

    try {
      const booking = await Booking.create({
        userId: req.user.userId,
        bookingDate,
        timeSlot,
        tableNumber: normalizedTableNumber,
        tableLabel: `Table ${normalizedTableNumber}`,
        partySize: normalizedPartySize,
        expiresAt,
      });

      return res.status(201).json(booking);
    } catch (error) {
      if (error && error.code === 11000) {
        return res.status(409).json({
          message: 'This table is already booked for the selected date and time slot',
        });
      }
      throw error;
    }
  } catch (error) {
    return next(error);
  }
});

router.patch('/:id/release', requireAuth, async (req, res, next) => {
  try {
    await autoReleaseExpiredBookings();

    const booking = await Booking.findOne({
      _id: req.params.id,
      userId: req.user.userId,
    });

    if (!booking) {
      return res.status(404).json({ message: 'Booking not found' });
    }

    if (booking.status !== 'booked') {
      return res.status(400).json({ message: 'Booking is already released' });
    }

    booking.status = 'released';
    booking.releaseReason = 'manual-release';
    booking.releasedAt = new Date();

    await booking.save();

    return res.json(booking);
  } catch (error) {
    return next(error);
  }
});

module.exports = router;
