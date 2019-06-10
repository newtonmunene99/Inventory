import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../models/shop.dart';
import '../providers/db.dart';
import '../pages/sales.dart';
import '../pages/waste.dart';
import 'package:shimmer/shimmer.dart';

class StockPage extends StatefulWidget {
  final Shop shop;

  StockPage(this.shop);

  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  @override
  void initState() {
    dbService.getShopStock(widget.shop);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.shop.shop} Stock"),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (String reason) {
              reason == "sales"
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SalesPage(widget.shop),
                      ),
                    )
                  : Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WastePage(widget.shop),
                      ),
                    );
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: "sales",
                    child: Text('View Sales'),
                  ),
                  const PopupMenuItem<String>(
                    value: "waste",
                    child: Text('View Waste'),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        verticalDirection: VerticalDirection.down,
        children: <Widget>[
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                SingleChildScrollView(
                  child: StreamBuilder<List<Stock>>(
                      stream: dbService.stock.stream,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<Stock>> snapshot) {
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
                                          width: (MediaQuery.of(context)
                                              .size
                                              .width),
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
                                      label: Text("UOM"),
                                      numeric: false,
                                      tooltip:
                                          "This is the product's Unit of Measurement"),
                                  DataColumn(
                                      label: Text("Date Added"),
                                      numeric: true,
                                      tooltip:
                                          "This is the products's Buying Price"),
                                ],
                                rows: snapshot.data
                                    .map(
                                      (Stock stock) => DataRow(
                                            cells: [
                                              DataCell(
                                                Text(
                                                  stock.product.name,
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  stock.quantity.toString(),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  stock.product.uom,
                                                ),
                                              ),
                                              DataCell(
                                                Text(stock.dateadded
                                                    .toString()
                                                    .replaceAll(
                                                        '00:00:00.000', '')),
                                              ),
                                            ],
                                          ),
                                    )
                                    .toList(),
                              );
                          }
                        }
                      }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
