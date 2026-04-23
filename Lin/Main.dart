import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(home: RiderHome()));
}

class RiderHome extends StatefulWidget {
  @override _RiderHomeState createState() => _RiderHomeState();
}

class _RiderHomeState extends State<RiderHome> {
  String status = "Offline";
  String riderId = "rider1"; // Change this per rider

  @override
  void initState() {
    super.initState();
    setupFCM();
    updateLocation();
  }

  void setupFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
    String? token = await messaging.getToken();
    FirebaseFirestore.instance.collection('riders').doc(riderId).set({
      'name': 'Otieno',
      'phone': '2547xx',
      'available': true,
      'fcmToken': token
    }, SetOptions(merge: true));
    
    FirebaseMessaging.onMessage.listen((msg) {
      if (msg.data['type'] == 'NEW_ORDER') {
        showDialog(context: context, builder: (_) => AlertDialog(
          title: Text('New Order'),
          content: Text('KSh ${msg.notification?.body}'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
        ));
      }
    });
  }

  void updateLocation() async {
    Position pos = await Geolocator.getCurrentPosition();
    FirebaseFirestore.instance.collection('riders').doc(riderId).update({
      'location': GeoPoint(pos.latitude, pos.longitude),
      'lastUpdate': FieldValue.serverTimestamp()
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('HomaFoods Rider')),
      body: Center(child: Text('Status: $status')),
    );
  }
}
