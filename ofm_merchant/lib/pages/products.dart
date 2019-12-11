import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/db.dart';
import '../models/product.dart';

class ProductsPage extends StatefulWidget {
  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Products"),
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
                  child: StreamBuilder<List<Product>>(
                      stream: dbService.products.stream,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<Product>> snapshot) {
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
                                      label: Text("UOM"),
                                      numeric: false,
                                      tooltip:
                                          "This is the product's Unit of Measurement"),
                                  DataColumn(
                                      label: Text("Buying Price"),
                                      numeric: true,
                                      tooltip:
                                          "This is the products's Buying Price"),
                                  DataColumn(
                                    label: Text("Selling Price"),
                                    numeric: true,
                                    tooltip:
                                        "This is the product's Selling Price",
                                  ),
                                  DataColumn(
                                      label: Text("Profit"),
                                      numeric: true,
                                      tooltip: "This is the Profit margin"),
                                ],
                                rows: snapshot.data
                                    .map(
                                      (Product product) => DataRow(
                                            cells: [
                                              DataCell(
                                                Text(
                                                  product.name,
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  product.uom,
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  product.buyingPrice
                                                      .toString(),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  product.sellingPrice
                                                      .toString(),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  (product.sellingPrice -
                                                          product.buyingPrice)
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
