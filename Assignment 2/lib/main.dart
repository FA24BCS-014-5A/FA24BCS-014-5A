import 'package:flutter/material.dart';

void main() {
runApp(const StudentCardApp());
}

class StudentCardApp extends StatelessWidget {
const StudentCardApp({super.key});

@override
Widget build(BuildContext context) {
return MaterialApp(
debugShowCheckedModeBanner: false,
title: 'Student Card',
theme: ThemeData(
useMaterial3: true,
fontFamily: 'Arial',
),
home: const StudentCardScreen(),
);
}
}

class StudentCardScreen extends StatelessWidget {
const StudentCardScreen({super.key});

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: const Color(0xFFF4F6FA),
appBar: AppBar(
backgroundColor: Colors.white,
elevation: 0,
centerTitle: true,
title: const Text(
'Student Profile',
style: TextStyle(
color: Color(0xFF17213A),
fontSize: 20,
fontWeight: FontWeight.bold,
),
),
),
body: Center(
child: SingleChildScrollView(
padding: const EdgeInsets.all(20),
child: Container(
width: double.infinity,
constraints: const BoxConstraints(maxWidth: 500),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(30),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.08),
blurRadius: 25,
offset: const Offset(0, 12),
),
],
),
child: Column(
children: [
Container(
width: double.infinity,
padding: const EdgeInsets.all(30),
decoration: const BoxDecoration(
gradient: LinearGradient(
colors: [
Color(0xFF1E3A8A),
Color(0xFF2563EB),
],
begin: Alignment.topLeft,
end: Alignment.bottomRight,
),
borderRadius: BorderRadius.only(
topLeft: Radius.circular(30),
topRight: Radius.circular(30),
),
),
child: Column(
children: [
Container(
width: 95,
height: 95,
decoration: BoxDecoration(
color: Colors.white.withOpacity(0.15),
shape: BoxShape.circle,
border: Border.all(
color: Colors.white.withOpacity(0.5),
width: 2,
),
),
child: const Icon(
Icons.person_rounded,
color: Colors.white,
size: 55,
),
),
const SizedBox(height: 18),
const Text(
'MARYAM BAKHTAWAR',
textAlign: TextAlign.center,
style: TextStyle(
color: Colors.white,
fontSize: 25,
fontWeight: FontWeight.bold,
letterSpacing: 0.5,
),
),
const SizedBox(height: 8),
const Text(
'Bachelor of Computer Science',
style: TextStyle(
color: Color(0xFFDCE7FF),
fontSize: 14,
),
),
const SizedBox(height: 18),
Container(
padding: const EdgeInsets.symmetric(
horizontal: 18,
vertical: 9,
),
decoration: BoxDecoration(
color: Colors.white.withOpacity(0.15),
borderRadius: BorderRadius.circular(30),
),
child: const Text(
'FA24-BCS-006',
style: TextStyle(
color: Colors.white,
fontWeight: FontWeight.w600,
fontSize: 14,
letterSpacing: 1,
),
),
),
],
),
),
Padding(
padding: const EdgeInsets.all(22),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'Academic Information',
style: TextStyle(
color: Color(0xFF17213A),
fontSize: 19,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 18),
_infoTile(
icon: Icons.badge_rounded,
title: 'Registration Number',
value: 'FA24-BCS-006',
color: const Color(0xFF2563EB),
),
const SizedBox(height: 12),
_infoTile(
icon: Icons.computer_rounded,
title: 'Department',
value: 'Computer Science',
color: const Color(0xFF7C3AED),
),
const SizedBox(height: 12),
_infoTile(
icon: Icons.email_rounded,
title: 'Email',
value: 'maryam@gmail.com',
color: const Color(0xFF0891B2),
),
const SizedBox(height: 12),
_infoTile(
icon: Icons.account_balance_rounded,
title: 'University',
value: 'COMSATS University',
color: const Color(0xFF059669),
),
const SizedBox(height: 20),
Container(
width: double.infinity,
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: const Color(0xFFECFDF5),
borderRadius: BorderRadius.circular(16),
border: Border.all(
color: const Color(0xFFD1FAE5),
),
),
child: const Row(
children: [
Icon(
Icons.verified_rounded,
color: Color(0xFF059669),
size: 24,
),
SizedBox(width: 12),
Expanded(
child: Text(
'Active Student',
style: TextStyle(
color: Color(0xFF047857),
fontWeight: FontWeight.bold,
fontSize: 15,
),
),
),
Icon(
Icons.check_circle_rounded,
color: Color(0xFF10B981),
size: 22,
),
],
),
),
],
),
),
const Padding(
padding: EdgeInsets.only(bottom: 22),
child: Text(
'COMSATS University • Student Card',
style: TextStyle(
color: Color(0xFF9AA3B2),
fontSize: 12,
),
),
),
],
),
),
),
),
);
}

static Widget _infoTile({
required IconData icon,
required String title,
required String value,
required Color color,
}) {
return Container(
padding: const EdgeInsets.all(14),
decoration: BoxDecoration(
color: const Color(0xFFF8FAFC),
borderRadius: BorderRadius.circular(17),
border: Border.all(
color: const Color(0xFFE7EAF0),
),
),
child: Row(
children: [
Container(
width: 46,
height: 46,
decoration: BoxDecoration(
color: color.withOpacity(0.10),
borderRadius: BorderRadius.circular(13),
),
child: Icon(
icon,
color: color,
size: 24,
),
),
const SizedBox(width: 14),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
title,
style: const TextStyle(
color: Color(0xFF8A94A6),
fontSize: 12,
fontWeight: FontWeight.w500,
),
),
const SizedBox(height: 4),
Text(
value,
style: const TextStyle(
color: Color(0xFF17213A),
fontSize: 15,
fontWeight: FontWeight.w600,
),
),
],
),
),
],
),
);
}
}

