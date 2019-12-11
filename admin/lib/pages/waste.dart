import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/waste.dart';
import '../models/shop.dart';
import '../providers/db.dart';
import 'package:shimmer/shimmer.dart';

class WastePage extends StatefulWidget {
  final Shop shop;

  WastePage(this.shop);
  @override
  _WastePageState createState() => _WastePageState();
}

class _WastePageState extends State<WastePage> {
  String selecteddate;

  double monthwaste;
  @override
  void initState() {
    monthwaste = 0;

    selecteddate = DateFormat("yMd").format(DateTime.now());

    _getWaste(selecteddate, widget.shop);

    _getWasteStats();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.shop.shop} Waste"),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        verticalDirection: VerticalDirection.down,
        children: <Widget>[
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton.icon(
                icon: Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).primaryColor,
                ),
                label: Text(
                  selecteddate,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.black54,
                    fontSize: 16.0,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                onPressed: () {
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
                          _getWaste(selecteddate, widget.shop);
                        });
                      }
                    },
                  );
                },
              ),
            ],
          ),
          Card(
            child: ListTile(
              title: Text('${widget.shop.shop} waste this month'),
              trailing: AnimatedDefaultTextStyle(
                child: Text("KES ${monthwaste.toString()}"),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                duration: const Duration(
                  milliseconds: 200,
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
    dbService.getShopWaste(date, currentshop);
  }

  void _getWasteStats() async {
    var shopwaste = await dbService.getShopMonthWaste(widget.shop);
    shopwaste.forEach((waste) {
      setState(() {
        monthwaste += waste.product.sellingPrice - waste.product.buyingPrice;
      });
    });
  }
}
