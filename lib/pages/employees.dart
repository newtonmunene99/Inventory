import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../models/employee.dart';
import '../providers/db.dart';
import '../widgets/bottom_sheet.dart';
import '../models/shop.dart';

bool activeDropdownValue = false;
List<Shop> selectedShops;
List<Shop> shops = [];

class EmployeesPage extends StatefulWidget {
  @override
  _EmployeesPageState createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  List<Employee> selectedEmployees;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    selectedEmployees = [];
    _getShops();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Employees"),
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
                visible: shops.length > 0,
                child: RaisedButton.icon(
                  icon: Icon(
                    Icons.add_circle,
                    color: Theme.of(context).primaryColor,
                  ),
                  label: Text(
                    'Add',
                  ),
                  onPressed: () {
                    _addEmployee(context);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
              Visibility(
                visible: selectedEmployees.length == 1 && shops.length > 0,
                child: RaisedButton.icon(
                  icon: Icon(
                    Icons.edit,
                    color: Theme.of(context).primaryColor,
                  ),
                  label: Text(
                    'Edit',
                  ),
                  onPressed: () {
                    _editEmployee(context, selectedEmployees[0]);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
              Visibility(
                visible: selectedEmployees.length > 0,
                child: RaisedButton.icon(
                  icon: Icon(
                    Icons.delete,
                    color: Theme.of(context).primaryColor,
                  ),
                  label: Text(
                    'Delete',
                  ),
                  onPressed: () {
                    dbService.deleteEmployees(selectedEmployees).then((_) {
                      setState(() {
                        selectedEmployees = [];
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
                  child: StreamBuilder<List<Employee>>(
                      stream: dbService.employees.stream,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<Employee>> snapshot) {
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
                                rows: snapshot.data
                                    .map((employee) => DataRow(
                                          selected: selectedEmployees
                                              .contains(employee),
                                          onSelectChanged: (selected) {
                                            _onSelectedRow(selected, employee);
                                          },
                                          cells: <DataCell>[
                                            DataCell(
                                              Text(
                                                employee.name,
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                employee.email,
                                              ),
                                            ),
                                            DataCell(
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: employee.shops
                                                    .map(
                                                      (shop) => Text(
                                                            shop.shop,
                                                          ),
                                                    )
                                                    .toList(),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                employee.active.toString(),
                                              ),
                                            ),
                                          ],
                                        ))
                                    .toList(),
                                columns: <DataColumn>[
                                  DataColumn(
                                      label: Text("Name"),
                                      numeric: false,
                                      tooltip: "This is the employee's name"),
                                  DataColumn(
                                      label: Text("Email"),
                                      numeric: false,
                                      tooltip: "This is the employee's Email"),
                                  DataColumn(
                                    label: Text("Shops"),
                                    numeric: false,
                                    tooltip:
                                        "This is the employee's assigned shops",
                                  ),
                                  DataColumn(
                                    label: Text("Active"),
                                    numeric: false,
                                    tooltip:
                                        "Determines if employee can make changes",
                                  ),
                                ],
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

  void _getShops() async {
    List<Shop> res = await dbService.getShops();
    if (mounted) {
      setState(() {
        shops = res;
        selectedShops = [];
      });
    }
  }

  void _onSelectedRow(bool selected, employee) async {
    setState(() {
      if (selected) {
        selectedEmployees.add(employee);
      } else {
        selectedEmployees.remove(employee);
      }
    });
  }

  void _addEmployee(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return ShopsAlertDialog();
      },
    ).then((res) {
      if (res && res != null) {
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
                        controller: _nameController,
                        autofocus: true,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: "Employee Name",
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0,
                      ),
                      child: TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "Employee Email",
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0,
                      ),
                      child: EmployeeActiveStatus(),
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
                                  _emailController.clear();
                                  selectedShops.clear();
                                  activeDropdownValue = false;
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
                                      _emailController.text.isNotEmpty) {
                                    dbService
                                        .addEmployee(
                                      Employee(
                                        name: _nameController.text,
                                        email: _emailController.text,
                                        shops: selectedShops,
                                        active: activeDropdownValue,
                                      ),
                                    )
                                        .then((_) {
                                      Navigator.pop(context);
                                      _nameController.clear();
                                      _emailController.clear();
                                      selectedShops.clear();
                                      activeDropdownValue = false;
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
          },
        );
      }
    });
  }

  void _editEmployee(BuildContext context, Employee employee) {
    _nameController.text = employee.name;
    activeDropdownValue = employee.active;

    employee.shops.forEach((employeeshop) {
      Shop foundemployeeshop = shops.firstWhere(
          (shop) => shop.shopid == employeeshop.shopid,
          orElse: () => null);

      if (foundemployeeshop != null) selectedShops.add(foundemployeeshop);
    });

    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return ShopsAlertDialog();
      },
    ).then(
      (res) {
        if (res && res != null) {
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
                          controller: _nameController,
                          autofocus: true,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: "Employee Name",
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16.0,
                        ),
                        child: Flex(
                          direction: Axis.horizontal,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                "Active",
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black54,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                            DropdownButton<bool>(
                              value: activeDropdownValue,
                              onChanged: (bool newValue) {
                                setState(() {
                                  activeDropdownValue = newValue;
                                });
                              },
                              items: <bool>[true, false]
                                  .map<DropdownMenuItem<bool>>((bool value) {
                                return DropdownMenuItem<bool>(
                                  value: value,
                                  child: Text(
                                    value.toString().toUpperCase(),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
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
                                    _nameController.clear();
                                    selectedShops.clear();
                                    activeDropdownValue = false;
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
                                    if (_nameController.text.isNotEmpty) {
                                      dbService
                                          .editEmployee(
                                        Employee(
                                          name: _nameController.text,
                                          email: employee.email,
                                          shops: selectedShops,
                                          active: activeDropdownValue,
                                          roles: employee.roles
                                        ),
                                      )
                                          .then((_) {
                                        Navigator.pop(context);
                                        _nameController.clear();
                                        selectedShops.clear();
                                        activeDropdownValue = false;

                                        setState(() {
                                          selectedEmployees = [];
                                        });
                                      }).catchError(
                                        (error) {
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
                                        },
                                      );
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
      },
    );
  }
}

class ShopsAlertDialog extends StatefulWidget {
  @override
  _ShopsAlertDialogState createState() => _ShopsAlertDialogState();
}

class _ShopsAlertDialogState extends State<ShopsAlertDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select shops to allocate employee to'),
      content: ListView.builder(
        itemCount: shops.length,
        itemBuilder: (BuildContext context, int index) => CheckboxListTile(
              title: Text(shops[index].shop),
              value: selectedShops.contains(shops[index]),
              onChanged: (bool selected) {
                if (selected) {
                  setState(() {
                    selectedShops.add(shops[index]);
                  });
                } else {
                  setState(() {
                    selectedShops.remove(shops[index]);
                  });
                }
              },
            ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Cancel'),
          onPressed: () {
            selectedShops.clear();
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text('Proceed'),
          onPressed: () {
            if (selectedShops.length > 0) {
              Navigator.of(context).pop(true);
            }
          },
        ),
      ],
    );
  }
}

class EmployeeActiveStatus extends StatefulWidget {
  @override
  _EmployeeActiveStatusState createState() => _EmployeeActiveStatusState();
}

class _EmployeeActiveStatusState extends State<EmployeeActiveStatus> {
  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Text(
            "Active",
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.black54,
              fontSize: 16.0,
            ),
          ),
        ),
        DropdownButton<bool>(
          value: activeDropdownValue,
          onChanged: (bool newValue) {
            setState(() {
              activeDropdownValue = newValue;
            });
          },
          items: <bool>[true, false].map<DropdownMenuItem<bool>>((bool value) {
            return DropdownMenuItem<bool>(
              value: value,
              child: Text(
                value.toString().toUpperCase(),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
