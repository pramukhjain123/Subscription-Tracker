// utils/checkStaleSubs.js
const mongoose = require('mongoose');
const Subscription = require('../models/Subscription');
require('dotenv').config({ path: '../.env' });


async function checkStaleSubscriptions() {
  await mongoose.connect(process.env.MONGO_URI);

  const now = new Date();
  const sevenDaysAgo = new Date(now.setDate(now.getDate() - 7));
  console.log(`⏰ Checking for subs not used since: ${sevenDaysAgo.toISOString()}`);

  const staleSubs = await Subscription.find({
    lastUsed: { $lte: sevenDaysAgo },
  });

  if (staleSubs.length === 0) {
    console.log('✅ No stale subscriptions found');
  } else {
    console.log(`📦 Found stale subscriptions: ${staleSubs.length}`);
  }

  staleSubs.forEach(sub => {
    const message = `⚠️ Subscription "${sub.name}" (User: ${sub.userId || 'N/A'}) not used in 7+ days`;

    console.log(message);

    // ✅ Add your push/email trigger here
    sendNotification({
      userId: sub.userId || null,
      title: 'Inactive Subscription Alert',
      body: message,
    });
  });

  await mongoose.disconnect();
}

// Fake Notification Function (Simulated)
function sendNotification({ userId, title, body }) {
  // You could integrate FCM, OneSignal, or nodemailer here
  console.log(`🔔 [Notification Sent] ${title}: ${body}`);
}

checkStaleSubscriptions().catch(console.error);
