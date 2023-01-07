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
      title: 'Baby Names',
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Baby Name Votes')),
        body: buildBody(context)
    );
  }

  Widget buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('baby').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        print("##################################################### Firestore Access start");
        snapshot.data!.docs.forEach((elem) {
          print(elem.get('name'));
          print(elem.get('votes'));
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
                snapshot.data!.docs[0].reference.update({'votes': FieldValue.increment(1)});
                },
              child: Text('ぼたん'),
            ),
          ],
        );
      },
    );
  }
}
