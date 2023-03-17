import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SelectOfferPage extends StatefulWidget {
  const SelectOfferPage({super.key});

  @override
  State<SelectOfferPage> createState() => _SelectOfferPageState();
}

class _SelectOfferPageState extends State<SelectOfferPage> {
  List<Product> products = [];

  void loadProducts() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null &&
          offerings.current!.availablePackages.isNotEmpty) {
        // TODO:
        print(offerings);
        // Display packages for sale
      }
    } on PlatformException catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();

    loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Premium Membership"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 80),
        child: Row(
          children: [
            Container(
              child: const Text("Monthly"),
            ),
            Container(
              child: const Text("Yearly"),
            )
          ],
        ),
      ),
    );
  }
}

class Product {
  String id;
  String name;
  String price;

  Product(this.id, this.name, this.price);
}
