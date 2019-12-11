import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/db.dart';
import '../widgets/bottom_sheet.dart';
import '../models/product.dart';

class ProductsPage extends StatefulWidget {
  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<Product> _selectedProducts;

  final _nameController = TextEditingController();
  final _uom = TextEditingController();
  final _sPrice = TextEditingController();
  final _bPrice = TextEditingController();

  @override
  void initState() {
    _selectedProducts = [];
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _uom.dispose();
    _sPrice.dispose();
    _bPrice.dispose();
    super.dispose();
  }

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
                  _addProduct(context);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              Visibility(
                visible: _selectedProducts.length == 1,
                child: RaisedButton.icon(
                  icon: Icon(
                    Icons.edit,
                    color: Theme.of(context).primaryColor,
                  ),
                  label: Text(
                    'Edit',
                  ),
                  onPressed: () {
                    _editProduct(context, _selectedProducts[0]);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
              Visibility(
                visible: _selectedProducts.length > 0,
                child: RaisedButton.icon(
                  icon: Icon(
                    Icons.delete,
                    color: Theme.of(context).primaryColor,
                  ),
                  label: Text(
                    'Delete',
                  ),
                  onPressed: () {
                    dbService.deleteProducts(_selectedProducts).then((res) {
                      setState(() {
                        _selectedProducts = [];
                      });
                    }).catchError((error) {
                      if (error.toString().contains("NOINTERNET")) {
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              )
            ],
          ),
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
                                            selected: _selectedProducts
                                                .contains(product),
                                            onSelectChanged: (selected) {
                                              _onSelectedRow(selected, product);
                                            },
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

  void _onSelectedRow(bool selected, Product product) async {
    setState(() {
      if (selected) {
        _selectedProducts.add(product);
      } else {
        _selectedProducts.remove(product);
      }
    });
  }

  void _editProduct(BuildContext context, Product product) {
    _nameController.text = product.name;
    _uom.text = product.uom;
    _sPrice.text = product.sellingPrice.toString();
    _bPrice.text = product.buyingPrice.toString();
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
                Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                      width: (MediaQuery.of(context).size.width) * 0.5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16.0,
                        ),
                        child: TextField(
                          controller: _nameController,
                          autofocus: true,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: "Product Name",
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: (MediaQuery.of(context).size.width) * 0.5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16.0,
                        ),
                        child: TextField(
                          controller: _uom,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: "UOM",
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                      width: (MediaQuery.of(context).size.width) * 0.5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: TextField(
                          controller: _bPrice,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            hintText: "Buying Price",
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: (MediaQuery.of(context).size.width) * 0.5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: TextField(
                          controller: _sPrice,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            hintText: "Selling Price",
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
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
                              _nameController.clear();
                              _uom.clear();
                              _sPrice.clear();
                              _bPrice.clear();
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
                              if (_nameController.text.isNotEmpty &&
                                  _sPrice.text.isNotEmpty &&
                                  _bPrice.text.isNotEmpty &&
                                  _uom.text.isNotEmpty) {
                                dbService
                                    .editProduct(
                                  Product(
                                    name: _nameController.text,
                                    uom: _uom.text,
                                    sellingPrice: double.parse(_sPrice.text),
                                    buyingPrice: double.parse(_bPrice.text),
                                    productid: product.productid,
                                  ),
                                )
                                    .then((_) {
                                  Navigator.pop(context);
                                  _nameController.clear();
                                  _uom.clear();
                                  _sPrice.clear();
                                  _bPrice.clear();
                                }).catchError((error) {
                                  if (error.toString().contains("NOINTERNET")) {
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
      },
    );
  }

  void _addProduct(BuildContext context) {
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
                  Flex(
                    direction: Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Container(
                        width: (MediaQuery.of(context).size.width) * 0.5,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 16.0,
                          ),
                          child: TextField(
                            controller: _nameController,
                            autofocus: true,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              hintText: "Product Name",
                              hintStyle: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: (MediaQuery.of(context).size.width) * 0.5,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 16.0,
                          ),
                          child: TextField(
                            controller: _uom,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              hintText: "UOM",
                              hintStyle: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Flex(
                    direction: Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Container(
                        width: (MediaQuery.of(context).size.width) * 0.5,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: TextField(
                            controller: _bPrice,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              hintText: "Buying Price",
                              hintStyle: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: (MediaQuery.of(context).size.width) * 0.5,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: TextField(
                            controller: _sPrice,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              hintText: "Selling Price",
                              hintStyle: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
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
                                _nameController.clear();
                                _uom.clear();
                                _sPrice.clear();
                                _bPrice.clear();
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
                                if (_nameController.text.isNotEmpty &&
                                    _sPrice.text.isNotEmpty &&
                                    _bPrice.text.isNotEmpty &&
                                    _uom.text.isNotEmpty) {
                                  dbService
                                      .addProduct(
                                    Product(
                                      name: _nameController.text,
                                      uom: _uom.text,
                                      sellingPrice: double.parse(_sPrice.text),
                                      buyingPrice: double.parse(_bPrice.text),
                                    ),
                                  )
                                      .then((_) {
                                    Navigator.pop(context);
                                    _nameController.clear();
                                    _uom.clear();
                                    _sPrice.clear();
                                    _bPrice.clear();
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
