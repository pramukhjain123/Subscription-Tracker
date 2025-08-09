const express = require('express');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const cors = require('cors');

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

// Routes
const subscriptionRoutes = require('./routes/subscriptions');
const authRoutes = require('./routes/auth');

app.use('/api/subscriptions', subscriptionRoutes);
app.use('/api/auth', authRoutes);

// ✅ Connect to MongoDB and THEN start server
mongoose.connect(process.env.MONGO_URI, {
  serverSelectionTimeoutMS: 10000,
}).then(() => {
  console.log('✅ MongoDB Connected');

  const PORT = process.env.PORT || 5000;
  app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));
}).catch((err) => {
  console.error('❌ MongoDB Connection Error:', err.message);
  process.exit(1);
});
