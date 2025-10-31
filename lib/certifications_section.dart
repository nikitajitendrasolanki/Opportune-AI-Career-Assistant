import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';

class Certification {
  final TextEditingController nameController;
  final TextEditingController orgController;
  DateTime? issueDate;
  DateTime? expiryDate;
  final TextEditingController credentialIdController;
  final TextEditingController credentialUrlController;

  Certification({
    required this.nameController,
    required this.orgController,
    this.issueDate,
    this.expiryDate,
    required this.credentialIdController,
    required this.credentialUrlController,
  });
}

class CertificationsSection extends StatefulWidget {
  final Function(Map<String, dynamic>) onNext;
  final VoidCallback? onCancel;

  const CertificationsSection({
    Key? key,
    required this.onNext,
    required this.onCancel,
  }) : super(key: key);

  @override
  _CertificationsSectionState createState() => _CertificationsSectionState();
}

class _CertificationsSectionState extends State<CertificationsSection> {
  List<Certification> certifications = [];

  @override
  void initState() {
    super.initState();
    _addCertification();
  }

  void _addCertification() {
    setState(() {
      certifications.add(Certification(
        nameController: TextEditingController(),
        orgController: TextEditingController(),
        credentialIdController: TextEditingController(),
        credentialUrlController: TextEditingController(),
      ));
    });
  }

  void _removeCertification(int index) {
    if (certifications.length <= 1) return; // At least one cert remains
    setState(() {
      certifications.removeAt(index);
    });
  }

  Future<void> _selectDate(BuildContext context, Certification cert, bool isIssue) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isIssue) {
          cert.issueDate = picked;
        } else {
          cert.expiryDate = picked;
        }
      });
    }
  }

  Future<void> _saveAndNext() async {
    final user = FirebaseAuth.instance.currentUser ;
    if (user == null) return;

    List<Map<String, dynamic>> payload = certifications.map((cert) {
      return {
        "certification_name": cert.nameController.text.trim(),
        "issuing_org": cert.orgController.text.trim(),
        "issue_date": cert.issueDate?.toIso8601String(),
        "expiry_date": cert.expiryDate?.toIso8601String(),
        "credential_id": cert.credentialIdController.text.trim(),
        "credential_url": cert.credentialUrlController.text.trim(),
      };
    }).toList();

    try {
      final response = await http.post(
        Uri.parse("http://10.59.252.17:5000/certifications/upsert"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "firebase_uid": user.uid,
          "certifications": payload,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Certifications saved")),
        );
        widget.onNext({"certifications": payload});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error: ${response.body}")),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠ Backend connection error")),
      );
    }
  }

  Widget _buildCertificationInput(Certification cert, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Row: Name + Delete
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: cert.nameController,
                decoration: InputDecoration(
                  labelText: "Certification Name",
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: const TextStyle(color: Colors.black87),
              ),
            ),
            if (certifications.length > 1)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () => _removeCertification(index),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: cert.orgController,
          decoration: InputDecoration(
            labelText: "Issuing Organization",
            filled: true,
            fillColor: Colors.white.withOpacity(0.15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          style: const TextStyle(color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(context, cert, true),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: "Issue Date",
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    cert.issueDate != null
                        ? "${cert.issueDate!.toLocal()}".split(' ')[0]
                        : "Select Date",
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(context, cert, false),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: "Expiry Date",
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    cert.expiryDate != null
                        ? "${cert.expiryDate!.toLocal()}".split(' ')[0]
                        : "Select Date",
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: cert.credentialIdController,
          decoration: InputDecoration(
            labelText: "Credential ID",
            filled: true,
            fillColor: Colors.white.withOpacity(0.15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          style: const TextStyle(color: Colors.black87),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: cert.credentialUrlController,
          decoration: InputDecoration(
            labelText: "Credential URL",
            filled: true,
            fillColor: Colors.white.withOpacity(0.15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          style: const TextStyle(color: Colors.black87),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/BG.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Single Frosted Glass
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(color: Colors.white.withOpacity(0.1)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Certifications",
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: 'Orbitron',
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..shader = const LinearGradient(
                              colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                            ).createShader(Rect.fromLTWH(0, 0, 200, 70)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ...certifications.asMap().entries.map(
                            (entry) =>
                            _buildCertificationInput(entry.value, entry.key),
                      ),
                      ElevatedButton.icon(
                        onPressed: _addCertification,
                        icon: const Icon(Icons.add),
                        label: const Text("Add Certification"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OutlinedButton(
                            onPressed: widget.onCancel,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(color: Colors.redAccent),
                            ),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton.icon(
                            onPressed: _saveAndNext,
                            icon: const Icon(Icons.save, color: Colors.white),
                            label: const Text("Save & Next",
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurpleAccent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}