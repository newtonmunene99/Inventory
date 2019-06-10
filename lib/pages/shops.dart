import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../models/shop.dart';
import '../providers/db.dart';
import '../pages/stock.dart';
import '../widgets/bottom_sheet.dart';

class ShopsPage extends StatefulWidget {
  @override
  _ShopsPageState createState() => _ShopsPageState();
}

class _ShopsPageState extends State<ShopsPage> {
  final _shopController = TextEditingController();

  @override
  void dispose() {
    _shopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Shops"),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        verticalDirection: VerticalDirection.down,
        children: <Widget>[
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton.icon(
                icon: Icon(
                  Icons.add_circle,
                  color: Theme.of(context).primaryColor,
                ),
                label: Text(
                  'Add',
                ),
                onPressed: () {
                  _addShop(context);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<List<Shop>>(
              stream: dbService.shops.stream,
              builder: (BuildContext bc, AsyncSnapshot<List<Shop>> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Container(
                        width: (MediaQuery.of(context).size.width),
                        child: ListView(
                          children: List<Widget>.filled(
                            5,
                            ListTile(
                              leading: Shimmer.fromColors(
                                baseColor: Colors.black12,
                                highlightColor: Colors.black26,
                                child: Container(
                                  height: 20.0,
                                  width: 20.0,
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5.0)),
                                  ),
                                ),
                              ),
                              title: Shimmer.fromColors(
                                baseColor: Colors.black12,
                                highlightColor: Colors.black26,
                                child: Container(
                                  height: 20.0,
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5.0)),
                                  ),
                                ),
                              ),
                            ),
                            growable: false,
                          ),
                        ),
                      );
                    default:
                      return ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext bc, index) => Card(
                              child: ListTile(
                                leading: Text((index + 1).toString()),
                                title: Text(
                                  snapshot.data[index].shop,
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    dbService
                                        .deleteShop(
                                          snapshot.data[index].shopid,
                                        )
                                        .then((_) {})
                                        .catchError((error) {
                                      if (error
                                          .toString()
                                          .contains("NOINTERNET")) {
                                        Flushbar(
                                          title: "Hey There",
                                          message:
                                              "You don't seem to have an active internet connection",
                                          duration: Duration(seconds: 4),
                                        )..show(context);
                                      } else {
                                        print(error);
                                        Flushbar(
                                          title: "Hey There",
                                          message:
                                              "There seems to be a problem. Please try again later.",
                                          duration: Duration(seconds: 4),
                                        )..show(context);
                                      }
                                    });
                                  },
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          StockPage(snapshot.data[index]),
                                    ),
                                  );
                                },
                              ),
                            ),
                      );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addShop(BuildContext context) {
    showModalBottomSheetApp(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            color: Color(0xFF737373),
            child: Container(
              decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: new BorderRadius.only(
                  topLeft: const Radius.circular(10.0),
                  topRight: const Radius.circular(10.0),
                ),
              ),
              child: Wrap(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    child: TextField(
                      controller: _shopController,
                      autofocus: true,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: "Shop Name",
                        hintStyle: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Colors.black54,
                        ),
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 8.0,
                      bottom: 8.0,
                      left: 16.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Icon(
                          Icons.add_circle,
                          color: Theme.of(context).primaryColor,
                        ),
                        ButtonBar(
                          children: <Widget>[
                            FlatButton(
                              child: Text("Cancel"),
                              onPressed: () {
                                Navigator.pop(context);
                                _shopController.clear();
                              },
                            ),
                            FlatButton(
                              child: Text(
                                "Save",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              onPressed: () {
                                if (_shopController.text.isNotEmpty) {
                                  dbService
                                      .addShop(
                                    _shopController.text,
                                  )
                                      .then((_) {
                                    Navigator.pop(context);
                                    _shopController.clear();
                                  }).catchError((error) {
                                    if (error
                                        .toString()
                                        .contains("NOINTERNET")) {
                                      Flushbar(
                                        title: "Hey There",
                                        message:
                                            "You don't seem to have an active internet connection",
                                        duration: Duration(seconds: 4),
                                      )..show(context);
                                    } else {
                                      print(error);
                                      Flushbar(
                                        title: "Hey There",
                                        message:
                                            "There seems to be a problem. Please try again later.",
                                        duration: Duration(seconds: 4),
                                      )..show(context);
                                    }
                                  });
                                }
                              },
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
