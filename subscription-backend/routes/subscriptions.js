const express = require('express');
const router = express.Router();
const Subscription = require('../models/Subscription');
const auth = require('../middleware/auth');

// ➕ Add new subscription
router.post('/', auth, async (req, res) => {
  try {
    const newSub = new Subscription({
      ...req.body,
      userId: req.user.userId
    });
    await newSub.save();
    res.json(newSub);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 📜 Get all subscriptions for the authenticated user
router.get('/', auth, async (req, res) => {
  try {
    const subs = await Subscription.find({ userId: req.user.userId });
    res.json(subs);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ❌ Delete a subscription (only if it belongs to the user)
router.delete('/:id', auth, async (req, res) => {
  try {
    const subscription = await Subscription.findOne({
      _id: req.params.id,
      userId: req.user.userId
    });
    
    if (!subscription) {
      return res.status(404).json({ error: 'Subscription not found' });
    }
    
    await Subscription.findByIdAndDelete(req.params.id);
    res.json({ message: 'Deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ✏️ Update a subscription (only if it belongs to the user)
router.put('/:id', auth, async (req, res) => {
  try {
    const subscription = await Subscription.findOne({
      _id: req.params.id,
      userId: req.user.userId
    });

    if (!subscription) {
      return res.status(404).json({ error: 'Subscription not found' });
    }

    const updatableFields = ['name', 'price', 'dueDate', 'isAutoPay', 'usageHours', 'lastUsed', 'packageName'];
    updatableFields.forEach((field) => {
      if (req.body[field] !== undefined) {
        subscription[field] = req.body[field];
      }
    });

    await subscription.save();
    res.json(subscription);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ⏱️ Update usage only (convenience endpoint)
router.patch('/:id/usage', auth, async (req, res) => {
  try {
    const { usageHours, lastUsed } = req.body;

    const subscription = await Subscription.findOne({
      _id: req.params.id,
      userId: req.user.userId
    });

    if (!subscription) {
      return res.status(404).json({ error: 'Subscription not found' });
    }

    if (usageHours !== undefined) subscription.usageHours = usageHours;
    if (lastUsed !== undefined) subscription.lastUsed = lastUsed;

    await subscription.save();
    res.json(subscription);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
