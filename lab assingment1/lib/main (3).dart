import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' show join;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
      home: const HomePage(),
    );
  }
}

// ---------- DATA SERVICE (SQLite for Mobile/Desktop, LocalStorage for Web) ----------
class DataService {
  static const String _storageKey = 'people_records';

  // READ
  static Future<List<Map<String, dynamic>>> getRecords() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_storageKey);
      if (jsonString == null) return [];
      final List decoded = jsonDecode(jsonString);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      final db = await _getSqliteDb();
      return await db.query('people', orderBy: 'id DESC');
    }
  }

  // INSERT
  static Future<void> insertRecord(Map<String, dynamic> row) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final records = await getRecords();
      int newId = records.isEmpty ? 1 : ((records.map((e) => e['id'] as int? ?? 0).reduce((a, b) => a > b ? a : b)) + 1);
      row['id'] = newId;
      records.insert(0, row);
      await prefs.setString(_storageKey, jsonEncode(records));
    } else {
      final db = await _getSqliteDb();
      await db.insert('people', row);
    }
  }

  // UPDATE
  static Future<void> updateRecord(int id, Map<String, dynamic> row) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final records = await getRecords();
      for (int i = 0; i < records.length; i++) {
        if (records[i]['id'] == id) {
          row['id'] = id;
          records[i] = row;
          break;
        }
      }
      await prefs.setString(_storageKey, jsonEncode(records));
    } else {
      final db = await _getSqliteDb();
      await db.update('people', row, where: 'id = ?', whereArgs: [id]);
    }
  }

  // DELETE
  static Future<void> deleteRecord(int id) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final records = await getRecords();
      records.removeWhere((element) => element['id'] == id);
      await prefs.setString(_storageKey, jsonEncode(records));
    } else {
      final db = await _getSqliteDb();
      await db.delete('people', where: 'id = ?', whereArgs: [id]);
    }
  }

  static Database? _db;
  static Future<Database> _getSqliteDb() async {
    _db ??= await openDatabase(
      join(await getDatabasesPath(), 'people.db'),
      version: 1,
      onCreate: (d, v) => d.execute(
          'CREATE TABLE people(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, email TEXT, age INTEGER, image TEXT)'),
    );
    return _db!;
  }
}

// ---------- SCREEN ----------
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final ageC = TextEditingController();
  List<Map<String, dynamic>> people = [];
  String? imagePath;
  int? editId; // null = Add mode, number = Update mode

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    nameC.dispose();
    emailC.dispose();
    ageC.dispose();
    super.dispose();
  }

  // READ
  Future<void> loadData() async {
    final data = await DataService.getRecords();
    if (!mounted) return;
    setState(() => people = data);
  }

  Future<void> pickImage() async {
    final f = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (f != null) {
      if (!mounted) return;
      setState(() => imagePath = f.path);
    }
  }

  // CREATE + UPDATE
  Future<void> save() async {
    if (nameC.text.trim().isEmpty ||
        emailC.text.trim().isEmpty ||
        int.tryParse(ageC.text.trim()) == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid name, email and age')),
      );
      return;
    }
    
    final row = {
      'name': nameC.text.trim(),
      'email': emailC.text.trim(),
      'age': int.parse(ageC.text.trim()),
      'image': imagePath,
    };

    if (editId == null) {
      await DataService.insertRecord(row); // ADD
    } else {
      await DataService.updateRecord(editId!, row); // UPDATE
    }
    clearForm();
    await loadData();
  }

  // EDIT button
  void startEdit(Map<String, dynamic> p) {
    setState(() {
      editId = p['id'];
      nameC.text = p['name'] ?? '';
      emailC.text = p['email'] ?? '';
      ageC.text = p['age'] != null ? p['age'].toString() : '';
      imagePath = p['image'];
    });
  }

  // DELETE
  Future<void> delete(int id) async {
    await DataService.deleteRecord(id);
    if (editId == id) clearForm();
    await loadData();
  }

  void clearForm() {
    nameC.clear();
    emailC.clear();
    ageC.clear();
    setState(() {
      imagePath = null;
      editId = null;
    });
  }

  bool _imageExists(String? path) {
    if (path == null || path.isEmpty) return false;
    if (kIsWeb) return true; // Web image paths can be local blobs or URLs
    return File(path).existsSync();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQLite CRUD App'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ----- FORM -----
          Center(
            child: GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    _imageExists(imagePath) ? (kIsWeb ? NetworkImage(imagePath!) : FileImage(File(imagePath!)) as ImageProvider) : null,
                child: !_imageExists(imagePath)
                    ? const Icon(Icons.add_a_photo, size: 35)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: nameC,
            decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: emailC,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: ageC,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                labelText: 'Age',
                prefixIcon: Icon(Icons.cake),
                border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: save,
                  child: Text(editId == null ? 'Add' : 'Update'),
                ),
              ),
              if (editId != null) ...[
                const SizedBox(width: 10),
                OutlinedButton(onPressed: clearForm, child: const Text('Cancel')),
              ],
            ],
          ),
          const Divider(height: 32),
          // ----- LIST -----
          if (people.isEmpty)
            const Center(child: Text('No records found yet')),
          ...people.map((p) => Card(
            key: ValueKey(p['id']),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: _imageExists(p['image'])
                    ? (kIsWeb ? NetworkImage(p['image']) : FileImage(File(p['image'])) as ImageProvider)
                    : null,
                child: !_imageExists(p['image']) ? const Icon(Icons.person) : null,
              ),
              title: Text(p['name'] ?? ''),
              subtitle: Text('${p['email'] ?? ''}\nAge: ${p['age'] ?? ''}'),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => startEdit(p)),
                  IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => delete(p['id'])),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }
}
