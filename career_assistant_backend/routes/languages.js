const express = require('express');
const router = express.Router();
const db = require('../db');

router.post('/upsert', async (req, res) => {
  const { firebase_uid, languages } = req.body; // array of {language_name, proficiency_level}

  try {
    // 1️⃣ Get user ID
    const [userRows] = await db.query('SELECT id FROM users WHERE firebase_uid=?', [firebase_uid]);
    if (userRows.length === 0) return res.status(404).json({ error: 'User not found' });
    const userId = userRows[0].id;

    // 2️⃣ Insert or update languages
    for (const lang of languages) {
      const [existing] = await db.query(
        'SELECT id FROM languages WHERE user_id = ? AND language_name = ?',
        [userId, lang.language_name]
      );

      if (existing.length > 0) {
        await db.query(
          'UPDATE languages SET proficiency = ? WHERE id = ?',
          [lang.proficiency_level, existing[0].id]
        );
      } else {
        await db.query(
          'INSERT INTO languages (user_id, language_name, proficiency) VALUES (?, ?, ?)',
          [userId, lang.language_name, lang.proficiency_level]
        );
      }
    }

    res.json({ message: 'Languages saved/updated successfully!' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

module.exports = router;
