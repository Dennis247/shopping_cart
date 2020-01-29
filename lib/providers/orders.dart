import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider_pattern/providers/cart.dart';
import 'package:http/http.dart' as http;

class OrderItem with ChangeNotifier {
  final String id;
  final String amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem(
      {@required this.id,
      @required this.amount,
      @required this.products,
      @required this.dateTime});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  List<OrderItem> get orders {
    return [..._orders];
  }

  final String authToken;
  final String userId;

  Orders(this.authToken, this.userId, this._orders);

  Future<void> fetchOrders(String authToken) async {
    if (orders.length > 0) {
      return;
    }
//    final _baseUrl = "https://providerdemo-29777.firebaseio.com/orders.json";
    List<OrderItem> loadedOrders = [];

    try {
      final response = await http.get(
          "https://providerdemo-29777.firebaseio.com/orders/$userId.json?auth=$authToken");
      final extractedOrders =
          json.decode(response.body) as Map<String, dynamic>;
      if (extractedOrders != null) {
        extractedOrders.forEach((orderedId, orderData) {
          loadedOrders.add(OrderItem(
              id: orderedId,
              amount: orderData['amount'].toString(),
              dateTime: DateTime.parse(orderData['dateTime']),
              products: (orderData['products'] as List<dynamic>)
                  .map((item) => CartItem(
                      id: item['id'],
                      price: double.parse(item['price']),
                      quantity: int.parse(item['quantity']),
                      title: item['title'],
                      imgUrl: item['imgUrl'],
                      productId: item['title']))
                  .toList()));
        });
        _orders = loadedOrders.reversed.toList();
        notifyListeners();
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> addOrder(
      List<CartItem> cartItems, double amount, String authToken) async {
    final _baseUrl =
        "https://providerdemo-29777.firebaseio.com/orders/$userId.json?auth=$authToken";
    final timeStamp = DateTime.now();
    try {
      final response = await http.post(_baseUrl,
          body: json.encode({
            'amount': amount,
            'dateTime': timeStamp.toIso8601String(),
            'products': cartItems
                .map((ct) => {
                      'id': ct.id,
                      'productId': ct.productId,
                      'title': ct.title,
                      'quantity': ct.quantity.toString(),
                      'price': ct.price.toString()
                    })
                .toList()
          }));
      _orders.insert(
          0,
          OrderItem(
              id: json.decode(response.body)['name'],
              amount: amount.toString(),
              dateTime: timeStamp,
              products: cartItems));
      notifyListeners();
    } catch (error) {
      print(error.toString());
    }
  }
}
