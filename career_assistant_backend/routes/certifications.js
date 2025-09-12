const express = require('express');
const router = express.Router();
const db = require('../db');

router.post('/upsert', async (req, res) => {
  const { firebase_uid, certifications } = req.body;

  try {
    // 1️⃣ Get user ID
    const [userRows] = await db.query('SELECT id FROM users WHERE firebase_uid=?', [firebase_uid]);
    if (userRows.length === 0) return res.status(404).json({ error: 'User not found' });
    const userId = userRows[0].id;

    // 2️⃣ Get or create resume
    let [resumeRows] = await db.query('SELECT id FROM resumes WHERE user_id = ?', [userId]);
    let resumeId;
    if (resumeRows.length === 0) {
      const [insertResult] = await db.query(
        'INSERT INTO resumes (user_id, title) VALUES (?, ?)',
        [userId, 'My Resume']
      );
      resumeId = insertResult.insertId;
    } else {
      resumeId = resumeRows[0].id;
    }

    // 3️⃣ Insert or update certifications
    for (const cert of certifications) {
      const [existing] = await db.query(
        'SELECT id FROM certifications WHERE resume_id = ? AND certification_name = ?',
        [resumeId, cert.certification_name]
      );

      if (existing.length > 0) {
        await db.query(
          `UPDATE certifications
           SET issuing_org = ?, issue_date = ?, expiry_date = ?, credential_id = ?, credential_url = ?
           WHERE id = ?`,
          [
            cert.issuing_org,
            cert.issue_date,
            cert.expiry_date,
            cert.credential_id,
            cert.credential_url,
            existing[0].id
          ]
        );
      } else {
        await db.query(
          `INSERT INTO certifications
           (resume_id, certification_name, issuing_org, issue_date, expiry_date, credential_id, credential_url)
           VALUES (?, ?, ?, ?, ?, ?, ?)`,
          [
            resumeId,
            cert.certification_name,
            cert.issuing_org,
            cert.issue_date,
            cert.expiry_date,
            cert.credential_id,
            cert.credential_url
          ]
        );
      }
    }

    res.json({ message: 'Certifications saved/updated successfully!' });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

module.exports = router;
