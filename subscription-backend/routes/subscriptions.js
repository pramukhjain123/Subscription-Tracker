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

module.exports = router;
