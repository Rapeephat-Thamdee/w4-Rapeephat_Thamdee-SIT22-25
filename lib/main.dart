import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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

  void addSong() async{
    String _songname = _songNameCtrl.text;
    String _name = _nameCtrl.text;
    String _songType = _songTypeCtrl.text;
    
    print("ค่าที่เก็บ $_songname | $_name | $_songType");
    try{
    await FirebaseFirestore.instance.collection("songs").add({
      "songName" : _songname,
      "name" : _name,
      "songType" : _songType,

    });
    _songNameCtrl.clear();
   _nameCtrl.clear();
    _songTypeCtrl.clear();

    }
    catch(e){
      print("เกิดข้อผิดพลาด $e ไปใช้แอปอื่นแอปนี้เจ๊งแล้ว");
    }
  }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
      body: Center(
        child: Column(
          children: [
            TextField(decoration: InputDecoration(labelText: "กรอกขื่อเพลง"),controller: _songNameCtrl,),
            TextField(decoration: InputDecoration(labelText: "กรอกขื่อศิลปิน"),controller: _nameCtrl,),
            TextField(decoration: InputDecoration(labelText: "กรอกแนวเพลง"),controller: _songTypeCtrl,),
            ElevatedButton(onPressed: addSong, child: Text("เพิ่ม",))
          ],
        ),
      ),
    );
  }
}
