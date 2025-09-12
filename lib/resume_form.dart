import 'dart:ui';
import 'package:flutter/material.dart';
import 'db_service.dart';
import 'resume_preview_screen.dart';
import 'personal_info_section.dart';
import 'education_section.dart';
import 'experience_section.dart';
import 'skills_section.dart';
import 'projects_section.dart';
import 'certifications_section.dart';
import 'languages_section.dart';
import 'social_links_section.dart';

class ResumeForm extends StatefulWidget {
  const ResumeForm({super.key});

  @override
  State<ResumeForm> createState() => _ResumeFormState();
}

class _ResumeFormState extends State<ResumeForm> {
  int _currentStep = 0;

  Map<String, dynamic> personalInfo = {};
  List<Map<String, dynamic>> experience = [];
  List<Map<String, dynamic>> education = [];
  List<Map<String, dynamic>> skills = [];
  List<Map<String, dynamic>> projects = [];
  List<Map<String, dynamic>> certifications = [];
  List<Map<String, dynamic>> languages = [];
  Map<String, dynamic> socialLinks = {};

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final savedData = await DBService.loadResume();
    if (savedData != null) {
      setState(() {
        personalInfo = savedData['personalInfo'] ?? {};
        experience = List<Map<String, dynamic>>.from(savedData['experience'] ?? []);
        education = List<Map<String, dynamic>>.from(savedData['education'] ?? []);
        skills = List<Map<String, dynamic>>.from(savedData['skills'] ?? []);
        projects = List<Map<String, dynamic>>.from(savedData['projects'] ?? []);
        certifications = List<Map<String, dynamic>>.from(savedData['certifications'] ?? []);
        languages = List<Map<String, dynamic>>.from(savedData['languages'] ?? []);
        socialLinks = savedData['socialLinks'] ?? {};
      });
    }
  }

  List<Widget> get _steps => [
    _backgroundWrapper(
      child: PersonalInfoSection(onNext: (data) {
        personalInfo = data;
        _nextStep();
      }),
    ),
    _backgroundWrapper(
      child: ExperienceForm(
        onNext: (data) {
          experience = List<Map<String, dynamic>>.from(data['experiences'] ?? []);
          _nextStep();
        },
        onCancel: _previousStep,
      ),
    ),
    _backgroundWrapper(
      child: EducationSection(
        onNext: (data) {
          education = List<Map<String, dynamic>>.from(data['education'] ?? []);
          _nextStep();
        },
        onCancel: _previousStep,
      ),
    ),
    _backgroundWrapper(
      child: SkillsSection(onNext: (data) {
        skills = List<Map<String, dynamic>>.from(data['skills'] ?? []);
        _nextStep();
      }),
    ),
    _backgroundWrapper(
      child: ProjectsSection(onNext: (data) {
        projects = List<Map<String, dynamic>>.from(data['projects'] ?? []);
        _nextStep();
      }),
    ),
    _backgroundWrapper(
      child: CertificationsSection(
        onNext: (data) {
          certifications = List<Map<String, dynamic>>.from(data['certifications'] ?? []);
          _nextStep();
        },
        onCancel: _previousStep,
      ),
    ),
    _backgroundWrapper(
      child: LanguagesSection(
        onNext: (data) {
          languages = List<Map<String, dynamic>>.from(data['languages'] ?? []);
          _nextStep();
        },
        onCancel: _previousStep,
      ),
    ),
    _backgroundWrapper(
      child: SocialLinksSection(onNext: (data) {
        socialLinks = data;
        _saveAndPreview();
      }),
    ),
  ];

  /// 🔹 Background wrapper WITHOUT extra SingleChildScrollView
  Widget _backgroundWrapper({required Widget child}) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/BG.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: child, // child itself should handle scrolling
        ),
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  void _saveAndPreview() async {
    final filledData = {
      'personalInfo': personalInfo,
      'experience': experience,
      'education': education,
      'skills': skills,
      'projects': projects,
      'certifications': certifications,
      'languages': languages,
      'socialLinks': socialLinks,
    };

    try {
      await DBService.saveResume(filledData);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResumePreviewScreen(resumeData: filledData),
        ),
      );
    } catch (e) {
      print("Error saving and navigating: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds),
          child: const Text(
            "Build Your Resume",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _previousStep,
        ),
      ),
      body: IndexedStack(
        index: _currentStep,
        children: _steps,
      ),
    );
  }
}
