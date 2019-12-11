import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/waste.dart';
import '../models/shop.dart';
import '../providers/db.dart';
import 'package:shimmer/shimmer.dart';

class WastePage extends StatefulWidget {
  @override
  _WastePageState createState() => _WastePageState();
}

class _WastePageState extends State<WastePage> {
  String selecteddate;
  List<Shop> shops;
  Shop shop;

  @override
  void initState() {
    selecteddate = DateFormat("yMd").format(DateTime.now());

    dbService.employee.stream.listen((res) {
      if (mounted) {
        setState(() {
          shops = res.shops;
          shop = res.shops[0];
        });
        _getWaste(selecteddate, shop);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Waste"),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        verticalDirection: VerticalDirection.down,
        children: <Widget>[
          Visibility(
            visible: shops != null && shops.length > 0,
            child: Card(
              elevation: 5.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (shops != null)
                      DropdownButton<Shop>(
                        value: shop,
                        onChanged: (Shop newValue) {
                          setState(() {
                            shop = newValue;
                          });
                        },
                        items: shops.map<DropdownMenuItem<Shop>>((Shop shop) {
                          return DropdownMenuItem<Shop>(
                            value: shop,
                            child: Text(
                              shop.shop,
                            ),
                          );
                        }).toList(),
                      ),
                    GestureDetector(
                      child: Container(
                        width: (MediaQuery.of(context).size.width) * 0.4,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 16.0,
                          ),
                          child: Container(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                selecteddate
                                    .toString()
                                    .replaceAll('00:00:00.000', ''),
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black54,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(DateTime.now().year),
                          lastDate: DateTime(DateTime.now().year + 1),
                        ).then(
                          (DateTime date) {
                            if (date != null) {
                              setState(() {
                                selecteddate = DateFormat("yMd").format(date);
                              });
                            }
                          },
                        );
                      },
                    ),
                    RaisedButton(
                      child: Text(
                        'Apply',
                      ),
                      color: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      onPressed: () {
                        _getWaste(selecteddate, shop);
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                SingleChildScrollView(
                  child: StreamBuilder<List<Waste>>(
                    stream: dbService.waste.stream,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Waste>> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return Container(
                              width: (MediaQuery.of(context).size.width),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: List<Widget>.filled(
                                  5,
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 8.0),
                                    child: Shimmer.fromColors(
                                      baseColor: Colors.black12,
                                      highlightColor: Colors.black26,
                                      child: Container(
                                        width:
                                            (MediaQuery.of(context).size.width),
                                        height: 20.0,
                                        decoration: BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  growable: false,
                                ),
                              ),
                            );
                          default:
                            return DataTable(
                              columns: [
                                DataColumn(
                                    label: Text("Name"),
                                    numeric: false,
                                    tooltip: "This is the product's name"),
                                DataColumn(
                                    label: Text("Quantity"),
                                    numeric: true,
                                    tooltip:
                                        "This is the product's Remaining Quantity"),
                                DataColumn(
                                    label: Text("Selling Price"),
                                    numeric: false,
                                    tooltip:
                                        "This is the product's Selling Price"),
                              ],
                              rows: snapshot.data
                                  .map(
                                    (Waste waste) => DataRow(
                                          cells: [
                                            DataCell(
                                              Text(
                                                waste.product.name,
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                waste.quantity.toString(),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                waste.product.sellingPrice
                                                    .toString(),
                                              ),
                                            ),
                                          ],
                                        ),
                                  )
                                  .toList(),
                            );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _getWaste(String date, Shop currentshop) {
    dbService.getWaste(date, currentshop);
  }
}
