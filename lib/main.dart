import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'カレンダアプリ',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  late CollectionReference cref;

  @override
  void initState() {
    super.initState();
    cref = FirebaseFirestore.instance.collection('schedule');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('日程調整用カレンダ')),
        body: buildBody(context)
    );
  }

  Widget buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: cref.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        print("##################################################### Firestore Access start");
        snapshot.data!.docs.forEach((elem) {
          print(elem.get('email'));
          print(elem.get('subject'));
          print(elem.get('start_time').toDate().toLocal().toString());
          print(elem.get('end_time').toDate().toLocal().toString());
        });
        print("##################################################### Firestore Access end");
        return Column(
          children: [
            Expanded(
                child: SfCalendar(
                  view: CalendarView.month,
                ),
            ),
            OutlinedButton(
              onPressed: () {
                cref.add({
                  'email': 'test03@gmail.com',
                  'subject': '予定3',
                  'start_time': DateTime.now().add(Duration(hours: 1)),
                  'end_time': DateTime.now().add(Duration(hours: 3)),
                });
                },
              child: Text('ぼたん'),
            ),
          ],
        );
      },
    );
  }
}
