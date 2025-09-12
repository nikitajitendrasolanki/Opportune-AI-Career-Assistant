const express = require('express');
const router = express.Router();
const db = require('../db');

// GET full resume by firebase_uid
router.get('/:firebase_uid', async (req, res) => {
  const { firebase_uid } = req.params;

  try {
    // 1️⃣ Fetch user basic info
    const [userRows] = await db.query(
      `SELECT id, full_name, email, linkedin_url, github_url, phone, summary
       FROM users WHERE firebase_uid=?`,
      [firebase_uid]
    );

    if (userRows.length === 0) return res.status(404).json({ error: 'User not found' });
    const user = userRows[0];

    // 2️⃣ Get latest resume_id
    const [resumeRows] = await db.query(
      `SELECT id FROM resumes WHERE user_id=? ORDER BY created_at DESC LIMIT 1`,
      [user.id]
    );

    const resume_id = resumeRows.length > 0 ? resumeRows[0].id : null;
    if (!resume_id) {
      return res.json({
        user,
        social_links: {
          linkedin_url: user.linkedin_url,
          github_url: user.github_url,
        },
        education: [],
        experience: [],
        skills: [],
        projects: [],
        certifications: [],
        languages: [],
      });
    }

    // 3️⃣ Fetch sections (all linked to resume_id)
    const [education] = await db.query(
      `SELECT institution, degree, field_of_study, start_date, end_date
       FROM education WHERE resume_id=? ORDER BY start_date DESC`,
      [resume_id]
    );

    const [skills] = await db.query(
      `SELECT skill_name, proficiency_level FROM skills WHERE resume_id=?`,
      [resume_id]
    );

    const [projects] = await db.query(
      `SELECT project_title, project_description, technologies_used, project_link
       FROM projects WHERE resume_id=?`,
      [resume_id]
    );

    const [certifications] = await db.query(
      `SELECT certification_name, issuing_org, issue_date, expiry_date
       FROM certifications WHERE resume_id=?`,
      [resume_id]
    );

    const [experience] = await db.query(
      `SELECT job_title, company_name, location, start_date, end_date, currently_working, description
       FROM experience WHERE resume_id=? ORDER BY start_date DESC`,
      [resume_id]
    );

    const [languages] = await db.query(
      `SELECT language_name, proficiency
       FROM languages WHERE resume_id=?`,
      [resume_id]
    );

    // 4️⃣ Return JSON
    res.json({
      user,
      social_links: {
        linkedin_url: user.linkedin_url,
        github_url: user.github_url,
      },
      education,
      experience,
      skills,
      projects,
      certifications,
      languages,
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Database error' });
  }
});

module.exports = router;
