import 'package:flutter/material.dart';
import 'package:ofm_merchant/models/employee.dart';
import 'package:shimmer/shimmer.dart';
import '../pages/stock.dart';
import '../providers/db.dart';

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
      body: StreamBuilder<Employee>(
        stream: dbService.employee.stream,
        builder: (BuildContext bc, AsyncSnapshot<Employee> snapshot) {
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
                  itemCount: snapshot.data.shops.length,
                  itemBuilder: (BuildContext bc, index) => Card(
                        child: ListTile(
                          leading: Text((index + 1).toString()),
                          title: Text(
                            snapshot.data.shops[index].shop,
                          ),
                          onTap: () {
                            dbService.getStock(snapshot.data.shops[index]);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    StockPage(shop: snapshot.data.shops[index]),
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
    );
  }
}
