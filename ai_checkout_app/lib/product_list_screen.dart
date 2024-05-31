import 'package:ai_checkout_app/qr_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  double _totalPrice = 0.0;
  Future<void> _deleteProduct(String productId) async {
    try {
      await FirebaseFirestore.instance
          .collection('items')
          .doc(productId)
          .delete();
    } catch (e) {
      print('Error deleting product: $e');
    }
  }

  Future<void> _onrefresh() async {}

  @override
  Widget build(BuildContext context) {
    return LiquidPullToRefresh(
      onRefresh: _onrefresh,
      color: const Color.fromARGB(255, 50, 50, 50),
      height: 200,
      backgroundColor: const Color.fromARGB(255, 55, 135, 57),
      animSpeedFactor: 5,
      springAnimationDurationInMilliseconds: 100,
      child: SafeArea(
        child: Scaffold(
          body: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('items').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                _totalPrice = 0.0; // Reset total price before recalculating

                // Calculate total price
                for (var product in snapshot.data!.docs) {
                  double price = double.parse(product['payable'].toString());
                  _totalPrice += price;
                }

                return Column(
                  children: [
                    const Text(
                      "Checkout App",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot product = snapshot.data!.docs[index];
                          String productName = product['name'];
                          String imagePath =
                              'assets/images/$productName.png'; // Assuming image name matches product name

                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  CircleAvatar(
                                    backgroundImage: AssetImage(imagePath),
                                    backgroundColor: Colors.greenAccent[400],
                                    radius: 30,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['name'],
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                          ' Price: ₹${product['price'].toString()}/unit'),
                                    ],
                                  ),
                                  Text(
                                      "Total: ₹${product['payable'].toString()} "),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () =>
                                        _deleteProduct(product.id.toString()),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total amount is:',
                            style: TextStyle(fontSize: 18.0),
                          ),
                          Text(
                            '₹$_totalPrice',
                            style: const TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    OutlinedButton(
                      child: const Text("Checkout",
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.green,
                          )),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const QrScreen()));
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    )
                  ],
                );
              }
            },
          ),
          // floatingActionButton: FloatingActionButton(
          //   onPressed: () {
          //     // Add functionality for checkout button
          //   },
          //   child: Icon(Icons.shopping_cart),
          // ),
        ),
      ),
    );
  }
}
