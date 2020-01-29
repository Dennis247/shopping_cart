import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:provider_pattern/models/http_exception.dart';
import 'package:provider_pattern/providers/product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  bool showFavouritesOnly = false;

  List<Product> _items = [];

  final String authToken;
  final String userId;

  Products(this.authToken, this._items, this.userId);

  final _baseUrl = "https://providerdemo-29777.firebaseio.com/products.json";

  List<Product> get items {
    return [..._items];
  }

  Future<void> getProducts([bool filterbyUser = false]) async {
    try {
      if (items.length > 0) {
        return;
      }
      String filterString =
          filterbyUser ? '&orderBy="creatorId"&equalTo="$userId"' : "";
      final String url =
          'https://providerdemo-29777.firebaseio.com/products.json?auth=$authToken$filterString';
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      final userFavURl =
          "https://providerdemo-29777.firebaseio.com/userFavourites/$userId.json?auth=$authToken";
      final favouriteResponse = await http.get(userFavURl);
      final favouriteData = json.decode(favouriteResponse.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, product) {
        loadedProducts.add(Product(
            id: prodId,
            description: product['description'],
            imageUrl: product['imageUrl'],
            price: product['price'],
            title: product['title'],
            categoryId: product['categoryId'],
            isFavourite:
                favouriteData == null ? false : favouriteData[prodId] ?? false
            //  isFavourite: product['isFavourite']
            ));
      });
      _items = loadedProducts;
      notifyListeners();
      //   print(json.decode(response.body));
    } catch (error) {
      print(error.toString());
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final response = await http.post(_baseUrl + "?auth=$authToken",
          body: json.encode({
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'title': product.title,
            'isFavourite': product.isFavourite,
            'creatorId': userId
          }));

      final newProduct = Product(
          id: json.decode(response.body)['name'],
          description: product.description,
          imageUrl: product.imageUrl,
          price: product.price,
          title: product.title,
          isFavourite: product.isFavourite);
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateproduct(String productId, Product newProduct) async {
    final _updatebaseUrl =
        "https://providerdemo-29777.firebaseio.com/products/$productId.json?auth=$authToken";

    final int productIndex =
        _items.indexWhere((product) => product.id == productId);
    if (productIndex >= 0) {
      try {
        await http.patch(_updatebaseUrl,
            body: json.encode({
              'price': newProduct.price,
              'title': newProduct.title,
              'description': newProduct.description,
              'imageUrl': newProduct.imageUrl
            }));
      } catch (error) {
        print(error);
      }
      _items[productIndex] = newProduct;
      notifyListeners();
    } else {
      print('product update for $productId failed');
    }
  }

  Future<void> deleteProduct(String productId) async {
    final url =
        "https://providerdemo-29777.firebaseio.com/products.json?auth=$authToken";
    Product existingProduct;
    int existingProductIndex =
        _items.indexWhere((product) => product.id == productId);
    if (existingProductIndex >= 0) {
      existingProduct = _items[existingProductIndex];
      _items.removeAt(existingProductIndex);
      notifyListeners();

      final response = await http.delete(url);
      if (response.statusCode >= 400) {
        _items.insert(existingProductIndex, existingProduct);
        notifyListeners();
        throw HttpException('product could not be deleted');
      } else {
        existingProduct = null;
      }
    }
  }

  Product getProduct(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  void showFavourites() {
    showFavouritesOnly = true;
    notifyListeners();
  }

  void showAll() {
    showFavouritesOnly = false;
    notifyListeners();
  }
}
