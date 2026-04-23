import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intasend_flutter/intasend_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(home: Home()));
}

class Home extends StatefulWidget {
  @override _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final intaSend = IntaSend(
    publishableKey: String.fromEnvironment('INTASEND_KEY'),
    isLive: true,
  );
  String status = "Ready";

  void order() async {
    setState(() => status = "Creating order...");
    final orderRef = FirebaseFirestore.instance.collection('orders').doc();
    await orderRef.set({
      'amount': 500,
      'status': 'PENDING',
      'customer': {'phone': '254712345678'},
      'vendor': {
        'name': 'Mama Fish Hotel',
        'location': GeoPoint(-0.5273, 34.4571)
      },
      'createdAt': FieldValue.serverTimestamp()
    });

    setState(() => status = "Pay with M-Pesa...");
    await intaSend.mpesaSTKPush(
      phoneNumber: "254712345678",
      amount: 500,
      apiRef: orderRef.id,
    );

    orderRef.snapshots().listen((snap) {
      setState(() => status = snap.data()?['status'] ?? 'PENDING');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('HomaFoods Customer')),
      body: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Status: $status', style: TextStyle(fontSize: 20)),
          SizedBox(height: 20),
          ElevatedButton(onPressed: order, child: Text('Order KSh 500'))
        ],
      )),
    );
  }
}
