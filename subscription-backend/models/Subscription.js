const mongoose = require('mongoose');

const SubscriptionSchema = new mongoose.Schema({
  userId: String,
  name: String,
  price: Number,
  dueDate: Date,
  isAutoPay: Boolean,
  usageHours: { type: Number, default: 0 },
  lastUsed: { type: Date, default: null },
  packageName: { type: String, default: null }
});

module.exports = mongoose.model('Subscription', SubscriptionSchema);
