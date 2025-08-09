// utils/calculateDailyCost.js
const mongoose = require('mongoose');
const Subscription = require('../models/Subscription');
require('dotenv').config();

async function calculateDailyCost() {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('✅ MongoDB Connected');

    const subscriptions = await Subscription.find({});
    console.log(`🔍 Found ${subscriptions.length} subscriptions`);

    if (subscriptions.length === 0) {
      console.log('📭 No subscriptions found.');
      return;
    }

    let totalDailyCost = 0;

    for (const sub of subscriptions) {
      console.log(`\n➡️ Processing: ${sub.name}`);
      if (!sub.dueDate || !sub.price) {
        console.log('⚠️ Missing dueDate or price. Skipping...');
        continue;
      }

      const startDate = new Date(sub.dueDate);
      startDate.setMonth(startDate.getMonth() - 1);
      const endDate = new Date(sub.dueDate);

      const daysInCycle = Math.ceil((endDate - startDate) / (1000 * 60 * 60 * 24));
      const dailyCost = sub.price / daysInCycle;

      console.log(`📦 ${sub.name} → ₹${dailyCost.toFixed(2)} per day`);
      totalDailyCost += dailyCost;
    }

    console.log(`\n💸 Total Daily Cost of Active Subscriptions: ₹${totalDailyCost.toFixed(2)}`);
  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await mongoose.disconnect();
    console.log('🔌 Disconnected from MongoDB');
  }
}

calculateDailyCost();
