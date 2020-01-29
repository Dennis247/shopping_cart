import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_pattern/providers/auth.dart';
import 'package:provider_pattern/providers/cart.dart';
import 'package:provider_pattern/providers/category.dart';
import 'package:provider_pattern/providers/products.dart';
import 'package:provider_pattern/screens/cart_screen.dart';
import 'package:provider_pattern/screens/category_screen.dart';
import 'package:provider_pattern/widgets/app_drawer.dart';
import 'package:provider_pattern/widgets/badge.dart';
import 'package:provider_pattern/widgets/category_item.dart';

import 'package:provider_pattern/widgets/product_item.dart';

enum FilteredOptions { favourites, all }

class ProductOverviewScreen extends StatefulWidget {
  static final String routeName = "/product-overview-screen";
  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    Future.delayed(Duration.zero).then((_) {
      setState(() {
        _isLoading = true;
      });
      final usertoken = Provider.of<Auth>(context, listen: false).token;
      Provider.of<Products>(context).getProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });

      Provider.of<CategoryProvider>(context).getCategories(usertoken).then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final products = productsData.items;

    final categoryData = Provider.of<CategoryProvider>(context);
    final categories = categoryData.categories;
    // super.build(context);
    return SafeArea(
      child: Scaffold(
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
          elevation: 6.0,
          title: Text(
            "TEA TARTS AND TINGS",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        drawer: AppDrawer(),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                child: ListView(
                  children: <Widget>[
                    SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Favourite",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        FlatButton(
                          child: Text(
                            "See all food items (${products.length})",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).accentColor,
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CategoryPage(
                                    category: Category(name: "All FOOD ITEMS"),
                                    isallCategories: true,
                                  ),
                                ));
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 10.0),

                    //Horizontal List here
                    Container(
                        height: MediaQuery.of(context).size.height / 2.4,
                        width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                            primary: false,
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: products.length,
                            itemBuilder: (BuildContext context, int index) {
                              return ChangeNotifierProvider.value(
                                  value: products[index], child: ProductItem());
                            })),

                    SizedBox(height: 30.0),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Category",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10.0),

                    //Horizontal List here
                    Container(
                      height: MediaQuery.of(context).size.height / 6,
                      child: ListView.builder(
                        primary: false,
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: categories.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ChangeNotifierProvider.value(
                            value: categories[index],
                            child: CategoryItem(),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 20.0),
                  ],
                ),
              ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   // final productsContainer = Provider.of<Products>(context);
  //   return Scaffold(
  //       appBar: AppBar(
  //         title: Text("TEA TARTS AND TINGS"),
  //         actions: <Widget>[
  //           PopupMenuButton(
  //             onSelected: (FilteredOptions selectedvalue) {
  //               setState(() {
  //                 if (selectedvalue == FilteredOptions.favourites) {
  //                   //   productsContainer.showFavourites();
  //                   _showOnlyFavourite = true;
  //                 } else {
  //                   //    productsContainer.showAll();
  //                   _showOnlyFavourite = false;
  //                 }
  //                 print(selectedvalue);
  //               });
  //             },
  //             icon: Icon(Icons.more_vert),
  //             itemBuilder: (_) => [
  //               PopupMenuItem(
  //                 child: Text('Only Favourites'),
  //                 value: FilteredOptions.favourites,
  //               ),
  //               PopupMenuItem(
  //                 child: Text('Show All'),
  //                 value: FilteredOptions.all,
  //               ),
  //             ],
  //           ),
  //           Consumer<Cart>(
  //             builder: (_, cart, ch) => Badge(
  //               child: ch,
  //               value: cart.itemCount.toString(),
  //             ),
  //             child: IconButton(
  //               icon: Icon(Icons.shopping_cart),
  //               onPressed: () {
  //                 Navigator.pushNamed(context, CartScreen.routeName);
  //               },
  //             ),
  //           )
  //         ],
  //       ),
  //       drawer: AppDrawer(),
  //       body: _isLoading
  //           ? Center(
  //               child: CircularProgressIndicator(),
  //             )
  //           : ProductGrid(_showOnlyFavourite));
  // }
}
