const express = require('express');
const router = express.Router();
const db = require('../db');

// -------------------------
// POST /users/upsert
// Save or update user data
// -------------------------
router.post('/upsert', async (req, res) => {
  const { firebase_uid, users } = req.body;

  if (!firebase_uid || !users) {
    return res.status(400).json({ error: 'firebase_uid and user data required' });
  }

  try {
    const [existing] = await db.query('SELECT id FROM users WHERE firebase_uid=?', [firebase_uid]);

    if (existing.length === 0) {
      await db.query(
        'INSERT INTO users (firebase_uid, full_name, email, phone, summary) VALUES (?, ?, ?, ?, ?)',
        [firebase_uid, users.full_name || '', users.email || '', users.phone || '', users.summary || '']
      );
    } else {
      const userId = existing[0].id;
      await db.query(
        'UPDATE users SET full_name=?, email=?, phone=?, summary=? WHERE id=?',
        [users.full_name || '', users.email || '', users.phone || '', users.summary || '', userId]
      );
    }

    res.json({ message: 'User data saved successfully!' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Database error' });
  }
});

// -------------------------
// GET /users/:firebase_uid
// Fetch user data
// -------------------------
router.get('/:firebase_uid', async (req, res) => {
  const { firebase_uid } = req.params;

  try {
    const [userRows] = await db.query('SELECT * FROM users WHERE firebase_uid=?', [firebase_uid]);
    if (userRows.length === 0) return res.status(404).json({ error: 'User not found' });

    res.json(userRows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Database error' });
  }
});

module.exports = router;
