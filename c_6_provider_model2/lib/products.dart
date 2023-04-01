import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;

  Product(
      {required this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.imageUrl});
}

class Products with ChangeNotifier {
  List<Product> prodList = [];
  String? _token;

  //String? token = Provider.of<Authentication>(context).token; ?auth=$token

  void update(String? authToken, List<Product> prodProdList) {
    _token = authToken;
    prodList = prodProdList;
  }

  Future<void> fetchData() async {
    try {
      Uri url = Uri.parse(
          'https://providermodel2-default-rtdb.firebaseio.com/Product.json?auth=$_token');
      final http.Response res = await http.get(url);
      var returnedData = json.decode(res.body);
      if (returnedData == null) {
        prodList = [];
      } else {
        returnedData.forEach((key, prodItem) {
          var prodIndex = prodList.indexWhere((element) => element.id == key);

          /*Product clearProd = Product(
            id: '', title: '', description: '', price: 0.0, imageUrl: '');
        Product isExist = prodList.firstWhere((element) => element.id == key,
            orElse: () => clearProd);
          // if (isExist == clearProd) {*/
          if (prodIndex >= 0) {
            prodList[prodIndex] = Product(
                id: key,
                title: prodItem['title'],
                description: prodItem['description'],
                price: prodItem['price'],
                imageUrl: prodItem['imageUrl']);
          } else {
            prodList.add(Product(
                id: key,
                title: prodItem['title'],
                description: prodItem['description'],
                price: prodItem['price'],
                imageUrl: prodItem['imageUrl']));
          }
          // }
        });
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateData(id) async {
    var prodIndex = prodList.indexWhere((element) => element.id == id);
    if (prodIndex >= 0) {
      Uri url = Uri.parse(
          'https://providermodel2-default-rtdb.firebaseio.com/Product/$id.json?auth=$_token');
      await http.patch(url,
          body: json.encode({
            'title': 'new title',
            'description': 'new description',
            'price': 22 / 9,
            'imageUrl':
                'https://upload.wikimedia.org/wikipedia/commons/1/1a/24701-nature-natural-beauty.jpg',
          }));
    }
    prodList[prodIndex] = Product(
      id: id,
      title: "new title",
      description: 'new description',
      price: 22 / 9,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/1/1a/24701-nature-natural-beauty.jpg',
    );
    notifyListeners();
  }

  Future<void> addProd(
      String title, String description, double price, String imageUrl) async {
    try {
      Uri url = Uri.parse(
          'https://providermodel2-default-rtdb.firebaseio.com/Product.json?auth=$_token');
      http.Response res = await http.post(url,
          body: json.encode({
            'title': title,
            'description': description,
            'price': price,
            'imageUrl': imageUrl,
          }));
      prodList.add(Product(
        id: json.decode(res.body)['name'],
        title: title,
        description: description,
        price: price,
        imageUrl: imageUrl,
      ));
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete(id) async {
    Uri url = Uri.parse(
        'https://providermodel2-default-rtdb.firebaseio.com/Product/$id.json?auth=$_token');
    var prodIndex = prodList.indexWhere((element) => element.id == id);
    Product? prodItem = prodList[prodIndex];
    prodList.removeAt(prodIndex);
    notifyListeners();

    http.Response res = await http.delete(url);
    if (res.statusCode >= 400) {
      prodList.insert(prodIndex, prodItem);
      notifyListeners();
    } else {
      prodItem = null;
    }
    notifyListeners();
  }

/*deleteImage() {
    image = null;
    notifyListeners();
  }*/

/*getImage(ImageSource source) async {
    var pickedImage = await ImagePicker().pickImage(source: source);
    image = pickedImage!.path;
    notifyListeners();
  }*/
}
