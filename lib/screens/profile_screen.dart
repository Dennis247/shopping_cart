import 'package:flutter/material.dart';
import 'package:provider_pattern/widgets/app_drawer.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  static final String routeName = "ProfilePage";

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController _itemEditController = new TextEditingController();
  Widget _buildprofileItem(
      String title, String subtitle, String actionType, bool obscureText) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(color: Colors.deepOrange, fontSize: 10.0),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12.0, color: Colors.black),
      ),
      trailing: IconButton(
        icon: Icon(
          Icons.edit,
          size: 16,
        ),
        color: Colors.purple,
        onPressed: () {
          _showBottomEditDialogue(context, subtitle, actionType, obscureText);
        },
      ),
    );
  }

  Widget _commonDivider() {
    return Divider(
      indent: 10.0,
      endIndent: 10.0,
      height: 0.5,
      color: Colors.purple,
    );
  }

  Future<void> _showBottomEditDialogue(BuildContext context, String oldvalue,
      String actionType, bool obscureText) async {
    final mediaQuery = MediaQuery.of(context).size;
    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext ctx) {
          return Container(
            decoration: new BoxDecoration(
                color: Color(0xffffffff),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(38.0),
                    topRight: Radius.circular(38.0))),
            child: Padding(
              padding: const EdgeInsets.all(35.0),
              child: ListView(
                children: <Widget>[
                  new Text("Edit $actionType",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Color(0xffd6001b),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                      )),
                  SizedBox(
                    height: mediaQuery.height * 0.03,
                  ),
                  Container(
                      decoration: new BoxDecoration(
                          color: Color(0xfff4f8fb),
                          borderRadius: BorderRadius.circular(4)),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 0, top: 0, bottom: 10),
                        child: TextFormField(
                          obscureText: obscureText,
                          //  controller: _itemEditController,
                          initialValue: "oldvalue",
                          decoration: InputDecoration(
                              hintText: "$actionType",
                              border: InputBorder.none,
                              labelStyle: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  color: Color(0xff999999),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                ),
                              )),
                        ),
                      )),
                  SizedBox(height: mediaQuery.height * 0.02),
                  MaterialButton(
                    minWidth: mediaQuery.width,
                    color: Colors.purple,
                    onPressed: () {},
                    child: Text(
                      'UPDATE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                        side: BorderSide(color: Colors.purple, width: 2)),
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.deepOrange,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "PROFILE",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      drawer: AppDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            elevation: 2.0,
            child: Column(
              children: <Widget>[
                _buildprofileItem(
                    "Email", "dosamuyimen@gmaii.com", "email", false),
                _commonDivider(),
                _buildprofileItem("Phone", "08167828256", "phone", false),
                _commonDivider(),
                _buildprofileItem("Password", "*******", "password", true),
                _commonDivider(),
                _buildprofileItem(
                    "address", "55 brroklyn empire new york", "address", false),
                SizedBox(
                  height: 35,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
