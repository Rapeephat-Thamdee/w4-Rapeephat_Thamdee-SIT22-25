import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // ซ่อนแถบแดง Debug มุมขวาบน
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'My Playlist'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _songNameCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _songTypeCtrl = TextEditingController();

  void addSong() async {
    String _songName = _songNameCtrl.text;
    String _name = _nameCtrl.text;
    String _songType = _songTypeCtrl.text;

    try {
      await FirebaseFirestore.instance.collection("songs").add({
        "songName": _songName,
        "name": _name,
        "songType": _songType
      });
      _songNameCtrl.clear();
      _nameCtrl.clear();
      _songTypeCtrl.clear();

      // ซ่อนคีย์บอร์ดหลังจากกดบันทึก
      FocusScope.of(context).unfocus();
    } catch (e) {
      print("Error : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      // ใช้ Padding เพื่อไม่ให้ข้อมูลชิดขอบจอเกินไป
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: "ชื่อเพลง",
                prefixIcon: Icon(Icons.music_note),
                border: OutlineInputBorder(), // เพิ่มเส้นขอบ
              ),
              controller: _songNameCtrl,
            ),
            const SizedBox(height: 12), // เว้นระยะห่าง
            TextField(
              decoration: const InputDecoration(
                labelText: "ชื่อศิลปิน",
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              controller: _nameCtrl,
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: "แนวเพลง",
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              controller: _songTypeCtrl,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity, // ให้ปุ่มกว้างเต็มหน้าจอ
              height: 50,
              child: ElevatedButton.icon(
                onPressed: addSong,
                icon: const Icon(Icons.save),
                label: const Text("บันทึกเพลง", style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(), // เส้นคั่น

            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection("songs").snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  }

                  final docs = snapshot.data!.docs;

                  return GridView.builder(
                    itemCount: docs.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12, // เพิ่มระยะห่างนิดหน่อย
                      mainAxisSpacing: 12,
                    ),
                    itemBuilder: (context, index) {
                      final songDoc = docs[index];
                      final s = songDoc.data() as Map<String, dynamic>;

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => SongDetail(song: s)),
                          );
                        },
                        // ตกแต่งการ์ดให้ดูมีมิติ
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.library_music, size: 40, color: Colors.deepPurple),
                              const SizedBox(height: 8),
                              Text(
                                s["songName"] ?? "",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                s["name"] ?? "",
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SongDetail extends StatelessWidget {
  final Map<String, dynamic> song;

  const SongDetail({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("รายละเอียดเพลง"),
        backgroundColor: Colors.deepPurple.shade100,
      ),
      // ใส่ Padding ให้หน้า Detail ไม่ชิดขอบ
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // จัดให้ข้อความชิดซ้าย
          children: [
            Center(
              child: Icon(Icons.album, size: 100, color: Colors.deepPurple.shade300),
            ),
            const SizedBox(height: 30),
            Text(
              "ชื่อเพลง: ${song["songName"]}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              "ศิลปิน: ${song["name"]}",
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),
            Text(
              "แนวเพลง: ${song["songType"]}",
              style: const TextStyle(fontSize: 20),
            )
          ],
        ),
      ),
    );
  }
}