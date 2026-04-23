import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(home: VendorHome()));
}

class VendorHome extends StatefulWidget {
  @override _VendorHomeState createState() => _VendorHomeState();
}

class _VendorHomeState extends State<VendorHome> {
  bool open = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('HomaFoods Vendor')),
      body: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Store is ${open ? "OPEN" : "CLOSED"}', style: TextStyle(fontSize: 24)),
          Switch(value: open, onChanged: (v) => setState(() => open = v)),
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection('orders')
              .where('status', whereIn: ['PAID', 'ASSIGNED']).snapshots(),
            builder: (c, s) {
              if (!s.hasData) return Text('No orders');
              return Column(children: s.data!.docs.map((d) => 
                ListTile(title: Text('Order ${d.id}'), subtitle: Text(d['status']))
              ).toList());
            },
          )
        ],
      )),
    );
  }
}
