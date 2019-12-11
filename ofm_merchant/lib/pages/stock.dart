import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../models/shop.dart';
import '../models/product.dart';
import '../providers/db.dart';
import '../widgets/bottom_sheet.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

Product activeDropdownValue;
List<Product> products;
TextEditingController quantityController;
String selecteddate = DateFormat("yMd").format(DateTime.now());

class StockPage extends StatefulWidget {
  final Shop shop;

  StockPage({@required this.shop});

  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  List<Stock> _selectedStock;
  bool _loading = false;
  @override
  void initState() {
    quantityController = TextEditingController();
    _selectedStock = [];
    products = [];
    _getProducts();
    super.initState();
  }

  @override
  void dispose() {
    quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Stock"),
        actions: <Widget>[
          Visibility(
            visible: _selectedStock.length == 1,
            child: PopupMenuButton<String>(
              onSelected: (String reason) {
                _stockOperations(context, _selectedStock[0], reason);
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: "sales",
                      child: Text('Add To Sales'),
                    ),
                    const PopupMenuItem<String>(
                      value: "waste",
                      child: Text('Add To Waste'),
                    ),
                  ],
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        verticalDirection: VerticalDirection.down,
        children: <Widget>[
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              Visibility(
                visible: products.length > 0,
                child: RaisedButton.icon(
                  icon: Icon(
                    Icons.add_circle,
                    color: Theme.of(context).primaryColor,
                  ),
                  label: Text(
                    'Add',
                  ),
                  onPressed: () {
                    _addStock(context);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
              Visibility(
                visible: _selectedStock.length == 1 && products.length > 0,
                child: RaisedButton.icon(
                  icon: Icon(
                    Icons.edit,
                    color: Theme.of(context).primaryColor,
                  ),
                  label: Text(
                    'Edit',
                  ),
                  onPressed: () {
                    _editStock(context, _selectedStock[0]);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
            ],
          ),
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
                                            selected:
                                                _selectedStock.contains(stock),
                                            onSelectChanged: (selected) {
                                              _onSelectedRow(selected, stock);
                                            },
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

  void _getProducts() async {
    dbService.products.stream.listen((res) {
      setState(() {
        products = res;
        activeDropdownValue = res[0];
      });
    });
  }

  void _onSelectedRow(bool selected, Stock stock) {
    setState(() {
      if (selected) {
        _selectedStock.add(stock);
      } else {
        _selectedStock.remove(stock);
      }
    });
  }

  void _addStock(BuildContext context) {
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
                ProductsDropdown(),
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
                            onPressed: _loading
                                ? null
                                : () {
                                    Navigator.pop(context);

                                    quantityController.clear();
                                  },
                          ),
                          FlatButton(
                            child: Text(
                              "Save",
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            onPressed: _loading
                                ? null
                                : () {
                                    if (quantityController.text.isNotEmpty) {
                                      setState(() {
                                        _loading = true;
                                      });
                                      dbService
                                          .addStock(Stock(
                                              product: activeDropdownValue,
                                              dateadded: selecteddate,
                                              shop: widget.shop,
                                              quantity: double.parse(
                                                  quantityController.text)))
                                          .then((res) {
                                        setState(() {
                                          _loading = false;
                                        });
                                        print('added successfully');
                                        Navigator.pop(context);
                                        quantityController.clear();
                                      }).catchError((error) {
                                        setState(() {
                                          _loading = false;
                                        });
                                        if (error.message
                                            .contains("PERMISSION_DENIED")) {
                                          Flushbar(
                                            title: "Hey There",
                                            message:
                                                "Seems you do not have enough permissions. Please contact the Administrator.",
                                            duration: Duration(seconds: 4),
                                          )..show(context);
                                        } else if (error
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
      },
    );
  }

  void _stockOperations(BuildContext context, Stock stock, String operation) {
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
                  StockOperationsContainer(stock),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 8.0,
                      bottom: 2.0,
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
                              onPressed: _loading
                                  ? null
                                  : () {
                                      Navigator.pop(context);

                                      quantityController.clear();
                                    },
                            ),
                            FlatButton(
                              child: Text(
                                "Add to " + operation,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              onPressed: _loading
                                  ? null
                                  : () {
                                      setState(() {
                                        _loading = true;
                                      });
                                      dbService
                                          .editStockOperations(
                                        Stock(
                                          product: stock.product,
                                          dateadded: DateFormat("yMd")
                                              .format(DateTime.now()),
                                          shop: stock.shop,
                                          quantity: double.parse(
                                              quantityController.text),
                                          stockid: stock.stockid,
                                        ),
                                        stock,
                                        operation,
                                      )
                                          .then((res) {
                                        setState(() {
                                          _loading = false;
                                        });
                                        Navigator.pop(context);
                                        quantityController.clear();
                                        _selectedStock.clear();
                                      }).catchError((error) {
                                        setState(() {
                                          _loading = false;
                                        });
                                        if (error.message
                                            .contains("PERMISSION_DENIED")) {
                                          Flushbar(
                                            title: "Hey There",
                                            message:
                                                "Seems you do not have enough permissions. Please contact the Administrator.",
                                            duration: Duration(seconds: 4),
                                          )..show(context);
                                        } else if (error
                                            .toString()
                                            .contains("NOINTERNET")) {
                                          Flushbar(
                                            title: "Hey There",
                                            message:
                                                "You don't seem to have an active internet connection",
                                            duration: Duration(seconds: 4),
                                          )..show(context);
                                        } else {
                                          Flushbar(
                                            title: "Hey There",
                                            message:
                                                "There seems to be a problem. Please try again later.",
                                            duration: Duration(seconds: 4),
                                          )..show(context);
                                        }
                                      });
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

  void _editStock(BuildContext context, Stock stock) {
    quantityController.text = stock.quantity.toString();
    activeDropdownValue =
        products.firstWhere((product) => product.name == stock.product.name);
    selecteddate = stock.dateadded;

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
                ProductsDropdown(),
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
                            onPressed: _loading
                                ? null
                                : () {
                                    Navigator.pop(context);

                                    quantityController.clear();
                                  },
                          ),
                          FlatButton(
                            child: Text(
                              "Save",
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            onPressed: _loading
                                ? null
                                : () {
                                    if (quantityController.text.isNotEmpty) {
                                      setState(() {
                                        _loading = true;
                                      });
                                      dbService
                                          .editStock(Stock(
                                        product: activeDropdownValue,
                                        dateadded: selecteddate,
                                        shop: stock.shop,
                                        quantity: double.parse(
                                            quantityController.text),
                                        stockid: stock.stockid,
                                      ))
                                          .then((res) {
                                        setState(() {
                                          _loading = false;
                                        });
                                        print('edit successfully');
                                        Navigator.pop(context);
                                        quantityController.clear();
                                        _selectedStock.clear();
                                      }).catchError((error) {
                                        setState(() {
                                          _loading = false;
                                        });
                                        if (error.message
                                            .contains("PERMISSION_DENIED")) {
                                          Flushbar(
                                            title: "Hey There",
                                            message:
                                                "Seems you do not have enough permissions. Please contact the Administrator.",
                                            duration: Duration(seconds: 4),
                                          )..show(context);
                                        } else if (error
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
      },
    );
  }
}

class StockOperationsContainer extends StatefulWidget {
  final Stock stock;

  StockOperationsContainer(this.stock);

  @override
  _StockOperationsContainerState createState() =>
      _StockOperationsContainerState();
}

class _StockOperationsContainerState extends State<StockOperationsContainer> {
  bool isMoreThanQuantity = false;
  bool isLessThanZero = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            widget.stock.product.name,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.black87,
              fontSize: 16.0,
            ),
          ),
        ),
        Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            child: TextField(
              controller: quantityController,
              keyboardType: TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Quantity To Subtract",
                hintStyle: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.black54,
                ),
              ),
              onChanged: (String value) {
                if (double.parse(value) > widget.stock.quantity) {
                  setState(() {
                    isMoreThanQuantity = true;
                  });
                } else {
                  setState(() {
                    isMoreThanQuantity = false;
                  });
                }
                if (double.parse(value) <= 0.0) {
                  setState(() {
                    isLessThanZero = true;
                  });
                } else {
                  setState(() {
                    isLessThanZero = false;
                  });
                }
              },
            ),
          ),
        ),
        Visibility(
          visible: isMoreThanQuantity,
          child: Text(
            "Value can't be higher than product quantity",
            style: TextStyle(
              color: Colors.red,
            ),
          ),
        ),
        Visibility(
          visible: isLessThanZero,
          child: Text(
            "Value can't be lower than zero",
            style: TextStyle(
              color: Colors.red,
            ),
          ),
        ),
      ],
    );
  }
}

class ProductsDropdown extends StatefulWidget {
  @override
  _ProductsDropdownState createState() => _ProductsDropdownState();
}

class _ProductsDropdownState extends State<ProductsDropdown> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            GestureDetector(
              child: Container(
                width: (MediaQuery.of(context).size.width) * 0.5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        selecteddate,
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
            Container(
              width: (MediaQuery.of(context).size.width) * 0.5,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                child: DropdownButton<Product>(
                  value: activeDropdownValue,
                  onChanged: (Product newValue) {
                    setState(() {
                      activeDropdownValue = newValue;
                    });
                  },
                  items: products
                      .map<DropdownMenuItem<Product>>((Product product) {
                    return DropdownMenuItem<Product>(
                      value: product,
                      child: Text(
                        product.name,
                      ),
                    );
                  }).toList(),
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
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                child: TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    hintText: "Quantity",
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
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  activeDropdownValue.uom,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.black54,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
