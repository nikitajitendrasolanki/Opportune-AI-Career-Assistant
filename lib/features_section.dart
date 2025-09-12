import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:lottie/lottie.dart';

class FeaturesSection extends StatefulWidget {
  @override
  _FeaturesSectionState createState() => _FeaturesSectionState();
}

class _FeaturesSectionState extends State<FeaturesSection> {
  final PageController _controller = PageController(viewportFraction: 0.82);

  final List<Map<String, dynamic>> _features = [
    {
      "title": "Build Your Resume",
      "desc": "Create a professional resume in minutes with smart AI assistance.",
      "lottie": "assets/animations/feature1.json",
      "gradient": [Color(0xFFFDEBEB), Color(0xFFE3CFFF)], // pastel pink-lavender
    },
    {
      "title": "AI Career Guidance",
      "desc": "Identify missing skills & get personalized learning suggestions.",
      "lottie": "assets/animations/feature2.json",
      "gradient": [Color(0xFFE3FDFD), Color(0xFFE6E6FA)], // mint + lavender
    },
    {
      "title": "Improve Suggestions",
      "desc": "Receive tailored tips to polish and strengthen your resume.",
      "lottie": "assets/animations/feature3.json",
      "gradient": [Color(0xFFFFF6E9), Color(0xFFEADCFD)], // soft peach + purple
    },
    {
      "title": "Job Recommendations",
      "desc": "Discover job opportunities that perfectly match your skills.",
      "lottie": "assets/animations/feature4.json",
      "gradient": [Color(0xFFEAF4FF), Color(0xFFF3E8FF)], // sky blue + lavender
    },
    {
      "title": "Track Applications",
      "desc": "Stay updated on your job applications and employer responses.",
      "lottie": "assets/animations/feature5.json",
      "gradient": [Color(0xFFF9FBE7), Color(0xFFE1F5FE)], // pastel yellow + blue
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.36,
          child: PageView.builder(
            controller: _controller,
            itemCount: _features.length,
            itemBuilder: (context, index) {
              final feature = _features[index];

              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  double value = 1.0;
                  if (_controller.position.haveDimensions) {
                    value = _controller.page! - index;
                    value = (1 - (value.abs() * 0.2)).clamp(0.85, 1.0);
                  }
                  return Center(
                    child: Transform.scale(
                      scale: value,
                      child: _buildFeatureCard(
                        feature['title'],
                        feature['desc'],
                        feature['lottie'],
                        feature['gradient'],
                        value == 1.0,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        SmoothPageIndicator(
          controller: _controller,
          count: _features.length,
          effect: WormEffect(
            dotHeight: 10,
            dotWidth: 10,
            activeDotColor: Colors.deepPurple,
            dotColor: Colors.grey.shade300,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
      String title, String desc, String lottiePath, List<Color> gradient, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient, // 🎨 pastel gradient unique for each card
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(isActive ? 0.25 : 0.1),
            blurRadius: isActive ? 20 : 12,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            lottiePath,
            height: 130,
            repeat: true,
            animate: true,
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontFamily: 'Orbitron',
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              desc,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black.withOpacity(0.7),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
