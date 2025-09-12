const express = require('express');
const router = express.Router();
const db = require('../db');

router.post('/upsert', async (req, res) => {
  const { firebase_uid, linkedin_url, github_url } = req.body;

  try {
    const [userRows] = await db.query('SELECT id FROM users WHERE firebase_uid=?', [firebase_uid]);
    if (userRows.length === 0) return res.status(404).json({ error: 'User not found' });

    const userId = userRows[0].id;

    await db.query(
      'UPDATE users SET linkedin_url=?, github_url=? WHERE id=?',
      [linkedin_url, github_url, userId]
    );

    res.json({ message: 'Social links updated!' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Database error' });
  }
});

module.exports = router;
