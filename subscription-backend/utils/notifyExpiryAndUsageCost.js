const mongoose = require('mongoose');
const Subscription = require('../models/Subscription');
require('dotenv').config({ path: '../.env' });


async function notifyAndCalculateCost() {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('✅ MongoDB Connected');

    const today = new Date();
    const threeDaysFromNow = new Date(today);
    threeDaysFromNow.setDate(today.getDate() + 3);

    const subscriptions = await Subscription.find({});
    console.log(`📦 Total Subscriptions: ${subscriptions.length}`);

    for (const sub of subscriptions) {
      console.log(`\n🔍 Checking: ${sub.name}`);

      // === Feature 1: Near Expiry Notification ===
      if (sub.dueDate && sub.dueDate <= threeDaysFromNow && sub.dueDate >= today) {
        console.log(`⚠️ Subscription '${sub.name}' is nearing expiry on ${sub.dueDate.toDateString()}`);
        // TODO: sendNotificationToUser(sub.userId, `Your ${sub.name} plan expires soon!`);
      }

      // === Feature 2: Usage-based Cost ===
      if (sub.usageHours && sub.usageHours > 0) {
        const endDate = new Date(sub.dueDate);
        const startDate = new Date(endDate);
        startDate.setMonth(endDate.getMonth() - 1); // assume monthly plan

        const daysSinceStart = Math.ceil((new Date(sub.lastUsed) - startDate) / (1000 * 60 * 60 * 24)) || 1;

        const hourlyCost = sub.price / sub.usageHours;
        const dailyUsedCost = sub.price / daysSinceStart;

        console.log(`💰 Cost for '${sub.name}':`);
        console.log(`   ⏰ Hourly: ₹${hourlyCost.toFixed(2)} (for ${sub.usageHours} hrs)`);
        console.log(`   📅 Daily (Used): ₹${dailyUsedCost.toFixed(2)} (for ${daysSinceStart} days used)`);
      } else {
        console.log(`ℹ️ No usage data for '${sub.name}'. Skipping cost calculation.`);
      }
    }
  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await mongoose.disconnect();
    console.log('\n🔌 Disconnected from MongoDB');
  }
}

notifyAndCalculateCost();
