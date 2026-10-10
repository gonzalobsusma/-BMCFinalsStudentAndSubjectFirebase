import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enrollment',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const EnrollmentScreen(),
    );
  }
}

class EnrollmentScreen extends StatefulWidget {
  const EnrollmentScreen({super.key});

  @override
  State<EnrollmentScreen> createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends State<EnrollmentScreen> {
  int currentStep = 0;
  bool isSaving = false;
  final name = TextEditingController();
  final section = TextEditingController();
  final course = TextEditingController();
  final subject1 = TextEditingController(text: 'BMC');
  final time1 = TextEditingController(text: '2-5 pm');
  final subject2 = TextEditingController(text: 'AI');
  final time2 = TextEditingController(text: '5-8 pm');

  @override
  void dispose() {
    name.dispose();
    section.dispose();
    course.dispose();
    subject1.dispose();
    time1.dispose();
    subject2.dispose();
    time2.dispose();
    super.dispose();
  }

  Widget textField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      onChanged: (_) => setState(() {}),
    );
  }

  Future<void> saveEnrollment() async {
    setState(() => isSaving = true);
    try {
      await FirebaseFirestore.instance.collection('enrollments').add({
        'name': name.text.trim(),
        'section': section.text.trim(),
        'course': course.text.trim(),
        'subjects': [
          {'subject': subject1.text.trim(), 'time': time1.text.trim()},
          {'subject': subject2.text.trim(), 'time': time2.text.trim()},
        ],
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enrollment saved successfully.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save enrollment: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  Widget _buildCurrentPage() {
    switch (currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'User Registration',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            textField('Name', name),
            textField('Section', section),
            textField('Course', course),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => setState(() => currentStep = 1),
              child: const Text('Next'),
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Subject Enrollment',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const Text('Subject 1'),
            textField('Subject', subject1),
            textField('Time', time1),
            const SizedBox(height: 16),
            const Text('Subject 2'),
            textField('Subject', subject2),
            textField('Time', time2),
            const SizedBox(height: 24),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () => setState(() => currentStep = 0),
                  child: const Text('Back'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => setState(() => currentStep = 2),
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Subject Verification',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text('Name: ${name.text}'),
            Text('Section: ${section.text}'),
            Text('Course: ${course.text}'),
            const Divider(height: 32),
            Text('${subject1.text} (${time1.text})'),
            Text('${subject2.text} (${time2.text})'),
            const SizedBox(height: 24),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () => setState(() => currentStep = 1),
                  child: const Text('Back'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: isSaving ? null : saveEnrollment,
                  child: Text(isSaving ? 'Saving...' : 'Save'),
                ),
              ],
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Step ${currentStep + 1} of 3')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _buildCurrentPage(),
      ),
    );
  }
}
