import 'dart:ui';
import 'package:flutter/material.dart';
import 'PhoneAuthScreen.dart';
import 'features_section.dart';
import 'resume_form.dart';
import 'chatbot_screen.dart';
import 'job_apply_screen.dart';
import 'db_service.dart';
import 'applied_jobs_storage.dart';
import 'package:lottie/lottie.dart';
import 'resume_preview_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(context),
      extendBodyBehindAppBar: true,
      appBar: _buildGlassAppBar(_scaffoldKey),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/BG.png"),
                repeat: ImageRepeat.repeat,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Slight glass overlay
          Container(color: Colors.white.withOpacity(0.05)),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Text
                  _gradientText(
                    "Welcome back,",
                    [Colors.indigo.shade900, Colors.blue.shade700, Colors.black87],
                    20,
                    FontWeight.w500,
                  ),
                  const SizedBox(height: 6),
                  _gradientText(
                    "Build. Improve. Apply.",
                    [Colors.indigo.shade900, Colors.blue.shade700, Colors.black87],
                    34,
                    FontWeight.bold,
                  ),
                  const SizedBox(height: 22),
                  // Features Section
                  _glassContainer(child: FeaturesSection()),
                  const SizedBox(height: 24),
                  // Quick Actions Section
                  _gradientText(
                    "Quick Actions",
                    [Colors.indigo.shade900, Colors.blue.shade700],
                    22,
                    FontWeight.bold,
                  ),
                  const SizedBox(height: 12),
                  // Quick Action Boxes with pastel gradients
                  _buildQuickActionBox(
                    context,
                    title: "Resume Builder",
                    subtitle: "Create & export PDF",
                    lottiePath: 'assets/animations/downward1.json',
                    gradientColors: [Color(0xFFFDEBEB), Color(0xFFE3CFFF)], // pastel pink-lavender
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ResumeForm()));
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActionBox(
                    context,
                    title: "Career Guidance",
                    subtitle: "Skill & learning tips",
                    lottiePath: 'assets/animations/downward2.json',
                    gradientColors: [Color(0xFFE3FDFD), Color(0xFFE6E6FA)], // mint + lavender
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => PersistentChatbotScreen()));
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActionBox(
                    context,
                    title: "Find Jobs",
                    subtitle: "Search & auto-apply",
                    lottiePath: 'assets/animations/downward3.json',
                    gradientColors: [Color(0xFFFFF6E9), Color(0xFFEADCFD)], // soft peach + purple
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => JobApplyScreen()));
                    },
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
    );
  }

  Widget _gradientText(String text, List<Color> colors, double fontSize, FontWeight weight) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(colors: colors).createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: fontSize, fontWeight: weight, color: Colors.white, fontFamily: 'Orbitron'),
      ),
    );
  }

  Widget _glassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/BG.png"),
            repeat: ImageRepeat.repeat,
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.06)),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/USER.jpg'),
                    backgroundColor: Colors.transparent,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Opportune',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Orbitron',
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _drawerTile(context, icon: Icons.description, title: 'My Resume', onTap: () async {
              final savedResume = await DBService.loadResume();
              if (savedResume != null) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ResumePreviewScreen(resumeData: savedResume)));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No resume found! Please fill the form first.")));
              }
            }),
            _drawerTile(context, icon: Icons.chat, title: 'Career Assistant Chatbot', onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => PersistentChatbotScreen()));
            }),
            _drawerTile(context, icon: Icons.work, title: 'Auto Job Apply', onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => JobApplyScreen()));
            }),
            _drawerTile(context, icon: Icons.history, title: 'Applied Jobs History', onTap: () async {
              final appliedJobs = await AppliedJobsStorage.getAppliedJobs();
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Applied Jobs'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: appliedJobs.length,
                      itemBuilder: (context, index) {
                        final job = appliedJobs[index];
                        return ListTile(title: Text(job['title']!), subtitle: Text('ID: ${job['id']}'));
                      },
                    ),
                  ),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                ),
              );
            }),
            _drawerTile(context, icon: Icons.login, title: 'Login', onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => PhoneAuthScreen()));
            }),
          ],
        ),
      ),
    );
  }

  Widget _drawerTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurpleAccent),
      title: Text(title, style: const TextStyle(color: Colors.deepPurpleAccent, fontFamily: 'Orbitron')),
      onTap: onTap,
    );
  }

  PreferredSize _buildGlassAppBar(GlobalKey<ScaffoldState> key) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight + 8),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AppBar(
            backgroundColor: Colors.white.withOpacity(0.06),
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: GestureDetector(
                onTap: () => key.currentState?.openDrawer(),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white.withOpacity(0.06),
                  backgroundImage: AssetImage('assets/USER.jpg'),
                ),
              ),
            ),
            title: _gradientText(
              "Opportune",
              [Colors.indigo.shade900, Colors.blue.shade700, Colors.black87],
              24,
              FontWeight.bold,
            ),
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.deepPurpleAccent),
          ),
        ),
      ),
    );
  }

  // Quick Action Box with pastel gradient
  Widget _buildQuickActionBox(BuildContext context,
      {required String title,
        required String subtitle,
        required String lottiePath,
        required List<Color> gradientColors,
        required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 180,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(flex: 4, child: Lottie.asset(lottiePath, fit: BoxFit.contain)),
            const SizedBox(width: 12),
            Expanded(
              flex: 6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _gradientText(title, [Colors.indigo.shade900, Colors.blue.shade700], 22, FontWeight.bold),
                  const SizedBox(height: 8),
                  _gradientText(subtitle, [Colors.indigo.shade900, Colors.blue.shade700], 16, FontWeight.w500),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
