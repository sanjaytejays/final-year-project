import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QrScreen extends StatefulWidget {
  const QrScreen({Key? key}) : super(key: key);

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  Future<void> deleteCollection(String collectionPath) async {
    final collectionRef = FirebaseFirestore.instance.collection(collectionPath);
    final batch = FirebaseFirestore.instance.batch();

    try {
      final querySnapshot = await collectionRef.get();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      print('Error deleting collection: $e');
      throw e;
    }
  }

  double getTotalPayableAmount(QuerySnapshot snapshot) {
    double total = 0.0;
    for (var product in snapshot.docs) {
      double price = double.parse(product['payable'].toString());
      total += price;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Scan here to pay...!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 20,
            ),
            FutureBuilder(
              future: FirebaseFirestore.instance.collection('items').get(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else {
                  double totalAmount = getTotalPayableAmount(snapshot.data!);
                  return Text(
                    "Your total bill is ₹$totalAmount",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  );
                }
              },
            ),
            const SizedBox(
              height: 20,
            ),
            Card(
              elevation: 100,
              shadowColor: Colors.grey,
              child: Image.asset(
                "assets/images/qr.jpg",
                width: 300,
                height: 300,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            OutlinedButton(
              child: const Text(
                "Done",
                style: TextStyle(fontSize: 20.0),
              ),
              onPressed: () async {
                try {
                  await deleteCollection('items');
                  print('Collection deleted successfully.');
                } catch (e) {
                  print('Failed to delete collection: $e');
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
