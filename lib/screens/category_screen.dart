import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_pattern/providers/cart.dart';
import 'package:provider_pattern/providers/category.dart';
import 'package:provider_pattern/providers/product.dart';
import 'package:provider_pattern/providers/products.dart';
import 'package:provider_pattern/screens/cart_screen.dart';
import 'package:provider_pattern/widgets/app_drawer.dart';
import 'package:provider_pattern/widgets/badge.dart';
import 'package:provider_pattern/widgets/category_list_item.dart';

class CategoryPage extends StatefulWidget {
  static final routeName = "CategoryPage";
  final Category category;
  final bool isallCategories;

  const CategoryPage({this.category, this.isallCategories});

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final TextEditingController _searchControl = new TextEditingController();
  List<Product> _allProducts;
  List<Product> _filteredProducts;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    final productData = Provider.of<Products>(context);
    if (widget.isallCategories) {
      _filteredProducts = productData.items;
    } else {
      //todo filter items yet
      _filteredProducts = productData.items;
    }

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
              child: ch,
              value: cart.itemCount.toString(),
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.pushNamed(context, CartScreen.routeName);
              },
            ),
          )
        ],
        elevation: 0.0,
        title: Text(widget.category.name),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: mediaQuery.height * 0.02,
            ),
            Card(
              elevation: 2.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(5.0),
                  ),
                ),
                child: TextField(
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(
                        color: Colors.white,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    hintText: "Search..",
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.black,
                    ),
                    suffixIcon: Icon(
                      Icons.filter_list,
                      color: Colors.black,
                    ),
                    hintStyle: TextStyle(
                      fontSize: 15.0,
                      color: Colors.black,
                    ),
                  ),
                  maxLines: 1,
                  controller: _searchControl,
                ),
              ),
            ),
            SizedBox(height: 10.0),
            ListView.builder(
              primary: false,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _filteredProducts.length,
              itemBuilder: (BuildContext context, int index) {
                return ChangeNotifierProvider.value(
                  value: _filteredProducts[index],
                  child: CategoryListItem(),
                );
              },
            ),
            SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}
