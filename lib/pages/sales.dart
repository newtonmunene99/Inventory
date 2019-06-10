import 'package:flutter/material.dart';
import '../providers/db.dart';
import '../models/shop.dart';
import '../models/sale.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

class SalesPage extends StatefulWidget {
  final Shop shop;

  SalesPage(this.shop);
  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  String selecteddate;

  double monthsales;

  @override
  void initState() {
    monthsales = 0;

    selecteddate = DateFormat("yMd").format(DateTime.now());

    _getSales(selecteddate, widget.shop);

    _getSalesStats();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.shop.shop} Sales"),
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
                          _getSales(selecteddate, widget.shop);
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
              title: Text('${widget.shop.shop} sales this month'),
              trailing: AnimatedDefaultTextStyle(
                child: Text("KES ${monthsales.toString()}"),
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
                  child: StreamBuilder<List<Sale>>(
                    stream: dbService.sales.stream,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Sale>> snapshot) {
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
                                    (Sale sale) => DataRow(
                                          cells: [
                                            DataCell(
                                              Text(
                                                sale.product.name,
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                sale.quantity.toString(),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                sale.product.sellingPrice
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

  void _getSales(String date, Shop currentshop) {
    dbService.getShopSales(date, currentshop);
  }

  void _getSalesStats() async {
    var shopsales = await dbService.getShopMonthSales(widget.shop);
    shopsales.forEach((sale) {
      setState(() {
        monthsales += sale.product.sellingPrice - sale.product.buyingPrice;
      });
    });
  }
}
