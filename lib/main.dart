import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' hide Colors;

void main() async {
  FirebaseOptions options = FirebaseOptions(
      apiKey: 'AIzaSyC9x3iG5eK3fzlkkS0DGhWD0eH5b5w2GfM',
      appId: '1:887390408274:android:ffdfe22deac69a3de1598b',
      messagingSenderId: '887390408274',
      projectId: 'calendarishigaki');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: options);
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
  late AppointmentDataSource dataSource;

  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: <String>[CalendarApi.calendarScope],
  );

  @override
  void initState() {
    super.initState();
    cref = FirebaseFirestore.instance.collection('schedule');
    dataSource = getCalendarDataSource();

    googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {});
    googleSignIn.signInSilently();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('日程調整用カレンダ')), body: buildBody(context));
  }

  Widget buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: cref.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        print("########## Firestore Access start");
        snapshot.data!.docs.forEach((elem) {
          print(elem.get('email'));
          print(elem.get('subject'));
          print(elem.get('start_time').toDate().toLocal().toString());
          print(elem.get('end_time').toDate().toLocal().toString());
        });
        print("########## Firestore Access end");

        dataSource.appointments!.clear(); // 現在の予定を一旦すべて消去
        snapshot.data!.docs.forEach((elem) {
          dataSource.appointments!.add(Appointment(
            startTime: elem.get('start_time').toDate().toLocal(),
            endTime: elem.get('end_time').toDate().toLocal(),
            subject: elem.get('subject'),
            color: Colors.blue,
            startTimeZone: '',
            endTimeZone: '',
          ));
        });
        dataSource.notifyListeners(CalendarDataSourceAction.reset,
            dataSource.appointments!); // カレンダの再描画

        return Column(
          children: [
            Expanded(
              child: SfCalendar(
                view: CalendarView.week,
                dataSource: dataSource,
              ),
            ),
            OutlinedButton(
              onPressed: () {
                // cref.add({
                //   'email': 'test03@gmail.com',
                //   'subject': '予定3',
                //   'start_time': DateTime.now().add(Duration(hours: 1)),
                //   'end_time': DateTime.now().add(Duration(hours: 3)),
                // });
                getGoogleEventsData();
              },
              child: Text('ぼたん'),
            ),
          ],
        );
      },
    );
  }

  AppointmentDataSource getCalendarDataSource() {
    List<Appointment> appointments = <Appointment>[];

    return AppointmentDataSource(appointments);
  }

  Future<List<Event>> getGoogleEventsData() async {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    final GoogleAPIClient httpClient =
        GoogleAPIClient(await googleUser!.authHeaders);
    final CalendarApi calendarApi = CalendarApi(httpClient);
    final Events calEvents = await calendarApi.events.list(
      "primary",
    );
    final List<Event> appointments = <Event>[];
    if (calEvents.items != null) {
      for (int i = 0; i < calEvents.items!.length; i++) {
        final Event event = calEvents.items![i];
        if (event.start == null) {
          continue;
        }
        print('########## email: ' + (googleUser.email).toString());
        print('########## start-time: ' +
            (event.start!.date ?? event.start!.dateTime!.toLocal()).toString());
        print('########## end-time: ' +
            (event.end!.date ?? event.end!.dateTime!.toLocal()).toString());
        print('########## subject: ' + (event.summary).toString());
        appointments.add(event);
      }
    }
    return appointments;
  }
}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}

class GoogleAPIClient extends IOClient {
  final Map<String, String> _headers;

  GoogleAPIClient(this._headers) : super();

  @override
  Future<IOStreamedResponse> send(BaseRequest request) =>
      super.send(request..headers.addAll(_headers));

  @override
  Future<Response> head(Uri url, {Map<String, String>? headers}) =>
      super.head(url,
          headers: (headers != null ? (headers..addAll(_headers)) : headers));
}
