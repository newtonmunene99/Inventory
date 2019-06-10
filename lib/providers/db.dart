import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ofm_admin/providers/auth.dart';
import 'package:rxdart/subjects.dart';
import '../models/employee.dart';
import '../models/shop.dart';
import '../models/stock.dart';
import '../models/sale.dart';
import '../models/waste.dart';
import '../models/product.dart';
import './connection.dart';

DatabaseProvider dbService = DatabaseProvider();

class DatabaseProvider {
  Firestore _db = Firestore.instance;
  final shops = BehaviorSubject<List<Shop>>();
  final employees = BehaviorSubject<List<Employee>>();
  final products = BehaviorSubject<List<Product>>();
  final items = BehaviorSubject<QuerySnapshot>();
  final stock = BehaviorSubject<List<Stock>>();
  final sales = BehaviorSubject<List<Sale>>();
  final monthsales = BehaviorSubject<List<Sale>>();
  final waste = BehaviorSubject<List<Waste>>();
  final monthwaste = BehaviorSubject<List<Waste>>();

  DatabaseProvider() {
    _db.collection('shops').snapshots().listen((QuerySnapshot shopsSnapshot) {
      shops.add(
        shopsSnapshot.documents
            .map(
              (document) => Shop(
                    shop: document.data["shop"],
                    shopid: document.data["shopid"],
                  ),
            )
            .toList(),
      );
    });

    _db
        .collection('employees')
        .snapshots()
        .listen((QuerySnapshot employeesSnapshot) {
      employees.add(
        employeesSnapshot.documents.map((document) {
          List shops = document.data["shops"];

          return Employee(
            name: document.data["name"],
            email: document.data["email"],
            active: document.data["active"],
            shops: shops
                .map(
                  (shop) => Shop(
                        shop: shop["shop"],
                        shopid: shop["shopid"],
                      ),
                )
                .toList(),
          );
        }).toList(),
      );
    });

    _db
        .collection('products')
        .snapshots()
        .listen((QuerySnapshot productsSnapshot) {
      products.add(
        productsSnapshot.documents
            .map((document) => Product(
                  name: document.data["name"],
                  productid: document.data["productid"],
                  buyingPrice: document.data["buyingPrice"],
                  sellingPrice: document.data["sellingPrice"],
                  uom: document.data["uom"],
                ))
            .toList(),
      );
    });

    getMonthSales();
    getMonthWaste();
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    return (await _db
            .collection("users")
            .document((await authService.auth.currentUser()).email)
            .get())
        .data;
  }

  Future<void> addShop(String shop) async {
    if (connectionService.connected.value) {
      try {
        DocumentReference added = await _db.collection('shops').add({
          "shop": shop,
        });

        return await added.updateData({
          "shopid": added.documentID,
        });
      } catch (e) {
        throw e;
      }
    } else {
      throw Exception("NOINTERNET");
    }
  }

  Future<void> deleteShop(String shopid) async {
    if (connectionService.connected.value) {
      try {
        return await _db.collection('shops').document(shopid).delete();
      } catch (e) {
        throw e;
      }
    } else {
      throw Exception("NOINTERNET");
    }
  }

  Future<void> addProduct(Product product) async {
    if (connectionService.connected.value) {
      try {
        DocumentReference added = await _db.collection('products').add({
          "name": product.name,
          "buyingPrice": product.buyingPrice,
          "sellingPrice": product.sellingPrice,
          "uom": product.uom,
        });

        return await added.updateData({
          "productid": added.documentID,
        });
      } catch (e) {
        throw e;
      }
    } else {
      throw Exception("NOINTERNET");
    }
  }

  Future<void> deleteProducts(List<Product> products) async {
    if (connectionService.connected.value) {
      try {
        int deleted = 0;
        for (var product in products) {
          print(product.productid);
          await _db.collection('products').document(product.productid).delete();
          deleted++;
          if (deleted == products.length) {
            return;
          }
        }
      } catch (e) {
        throw e;
      }
    } else {
      throw Exception("NOINTERNET");
    }
  }

  Future<void> editProduct(Product product) async {
    if (connectionService.connected.value) {
      try {
        return await _db
            .collection('products')
            .document(product.productid)
            .updateData({
          "name": product.name,
          "uom": product.uom,
          "buyingPrice": product.buyingPrice,
          "sellingPrice": product.sellingPrice,
        });
      } catch (e) {
        throw e;
      }
    } else {
      throw Exception("NOINTERNET");
    }
  }

  Future<void> addEmployee(Employee employee) async {
    if (connectionService.connected.value) {
      try {
        return await _db
            .collection('employees')
            .document(employee.email)
            .setData({
          "name": employee.name,
          "email": employee.email,
          "shops": employee.shops
              .map((shop) => {
                    "shop": shop.shop,
                    "shopid": shop.shopid,
                  })
              .toList(),
          "roles": {
            "admin": false,
            "editor": true,
          },
          "active": employee.active
        });
      } catch (e) {
        throw e;
      }
    } else {
      throw Exception("NOINTERNET");
    }
  }

  Future<void> editEmployee(Employee employee) async {
    if (connectionService.connected.value) {
      try {
        return await _db
            .collection('employees')
            .document(employee.email)
            .updateData({
          "name": employee.name,
          "shops": employee.shops
              .map((shop) => {
                    "shop": shop.shop,
                    "shopid": shop.shopid,
                  })
              .toList(),
          "active": employee.active,
        });
      } catch (e) {
        throw e;
      }
    } else {
      throw Exception("NOINTERNET");
    }
  }

  Future<void> deleteEmployees(List<Employee> employees) async {
    if (connectionService.connected.value) {
      try {
        int deleted = 0;
        for (var employee in employees) {
          await _db.collection('employees').document(employee.email).delete();
          deleted++;
          if (deleted == employees.length) {
            return;
          }
        }
      } catch (e) {
        throw e;
      }
    } else {
      throw Exception("NOINTERNET");
    }
  }

  Future<List<Shop>> getShops() async {
    try {
      QuerySnapshot res = await _db.collection('shops').getDocuments();
      return res.documents
          .map(
            (shop) => Shop(
                  shop: shop.data["shop"],
                  shopid: shop.data["shopid"],
                ),
          )
          .toList();
    } catch (e) {
      throw Exception(e);
    }
  }

  void getShopSales(String date, Shop shop) {
    sales.add([]);
    _db
        .collection('sales')
        .where("shop", isEqualTo: {
          "shop": shop.shop,
          "shopid": shop.shopid,
        })
        .where("dateadded", isEqualTo: date.toString())
        .snapshots()
        .listen(
          (QuerySnapshot salesSnapshot) {
            sales.add(
              salesSnapshot.documents
                  .map((document) => Sale(
                        product: Product(
                          name: document.data["product"]["name"],
                          uom: document.data["product"]["uom"],
                          buyingPrice: document.data["product"]["buyingPrice"],
                          sellingPrice: document.data["product"]
                              ["sellingPrice"],
                          productid: document.data["product"]["productid"],
                        ),
                        shop: Shop(
                          shop: document.data["shop"]["shop"],
                          shopid: document.data["shop"]["shopid"],
                        ),
                        stockid: document.data["stockid"],
                        salesid: document.data["salesid"],
                        dateadded: document.data["dateadded"],
                        timestamp: document.data["timestamp"],
                        quantity: document.data["quantity"],
                      ))
                  .toList(),
            );
          },
        );
  }

  void getMonthSales() {
    var now = DateTime.now();
    var startMonth = DateTime.utc(now.year, now.month, 1);

    _db
        .collection('sales')
        .where("timestamp",
            isGreaterThanOrEqualTo: startMonth.millisecondsSinceEpoch)
        .where("timestamp", isLessThanOrEqualTo: now.millisecondsSinceEpoch)
        .snapshots()
        .listen(
      (QuerySnapshot salesSnapshot) {
        monthsales.add(
          salesSnapshot.documents
              .map((document) => Sale(
                    product: Product(
                      name: document.data["product"]["name"],
                      uom: document.data["product"]["uom"],
                      buyingPrice: document.data["product"]["buyingPrice"],
                      sellingPrice: document.data["product"]["sellingPrice"],
                      productid: document.data["product"]["productid"],
                    ),
                    shop: Shop(
                      shop: document.data["shop"]["shop"],
                      shopid: document.data["shop"]["shopid"],
                    ),
                    stockid: document.data["stockid"],
                    salesid: document.data["salesid"],
                    dateadded: document.data["dateadded"],
                    timestamp: document.data["timestamp"],
                    quantity: document.data["quantity"],
                  ))
              .toList(),
        );
      },
    );
  }

  Future<List<Sale>> getShopMonthSales(Shop shop) async {
    var now = DateTime.now();
    var startMonth = DateTime.utc(now.year, now.month, 1);

    var salesSnapshot = await _db
        .collection('sales')
        .where("shop", isEqualTo: {
          "shop": shop.shop,
          "shopid": shop.shopid,
        })
        .where("timestamp",
            isGreaterThanOrEqualTo: startMonth.millisecondsSinceEpoch)
        .where("timestamp", isLessThanOrEqualTo: now.millisecondsSinceEpoch)
        .getDocuments();

    return salesSnapshot.documents
        .map((document) => Sale(
              product: Product(
                name: document.data["product"]["name"],
                uom: document.data["product"]["uom"],
                buyingPrice: document.data["product"]["buyingPrice"],
                sellingPrice: document.data["product"]["sellingPrice"],
                productid: document.data["product"]["productid"],
              ),
              shop: Shop(
                shop: document.data["shop"]["shop"],
                shopid: document.data["shop"]["shopid"],
              ),
              stockid: document.data["stockid"],
              salesid: document.data["salesid"],
              dateadded: document.data["dateadded"],
              timestamp: document.data["timestamp"],
              quantity: document.data["quantity"],
            ))
        .toList();
  }

  void getShopWaste(String date, Shop shop) {
    waste.add([]);
    _db
        .collection('waste')
        .where("shop", isEqualTo: {
          "shop": shop.shop,
          "shopid": shop.shopid,
        })
        .where("dateadded", isEqualTo: date.toString())
        .snapshots()
        .listen(
          (QuerySnapshot salesSnapshot) {
            waste.add(
              salesSnapshot.documents
                  .map((document) => Waste(
                        product: Product(
                          name: document.data["product"]["name"],
                          uom: document.data["product"]["uom"],
                          buyingPrice: document.data["product"]["buyingPrice"],
                          sellingPrice: document.data["product"]
                              ["sellingPrice"],
                          productid: document.data["product"]["productid"],
                        ),
                        shop: Shop(
                          shop: document.data["shop"]["shop"],
                          shopid: document.data["shop"]["shopid"],
                        ),
                        stockid: document.data["stockid"],
                        wasteid: document.data["wasteid"],
                        dateadded: document.data["dateadded"],
                        timestamp: document.data["timestamp"],
                        quantity: document.data["quantity"],
                      ))
                  .toList(),
            );
          },
        );
  }

  void getMonthWaste() {
    var now = DateTime.now();
    var startMonth = DateTime.utc(now.year, now.month, 1);

    _db
        .collection('waste')
        .where("timestamp",
            isGreaterThanOrEqualTo: startMonth.millisecondsSinceEpoch)
        .where("timestamp", isLessThanOrEqualTo: now.millisecondsSinceEpoch)
        .snapshots()
        .listen(
      (QuerySnapshot wasteSnapshot) {
        monthwaste.add(
          wasteSnapshot.documents
              .map((document) => Waste(
                    product: Product(
                      name: document.data["product"]["name"],
                      uom: document.data["product"]["uom"],
                      buyingPrice: document.data["product"]["buyingPrice"],
                      sellingPrice: document.data["product"]["sellingPrice"],
                      productid: document.data["product"]["productid"],
                    ),
                    shop: Shop(
                      shop: document.data["shop"]["shop"],
                      shopid: document.data["shop"]["shopid"],
                    ),
                    stockid: document.data["stockid"],
                    wasteid: document.data["wasteid"],
                    dateadded: document.data["dateadded"],
                    timestamp: document.data["timestamp"],
                    quantity: document.data["quantity"],
                  ))
              .toList(),
        );
      },
    );
  }

  Future<List<Waste>> getShopMonthWaste(Shop shop) async {
    var now = DateTime.now();
    var startMonth = DateTime.utc(now.year, now.month, 1);

    var wasteSnapshot = await _db
        .collection('waste')
        .where("shop", isEqualTo: {
          "shop": shop.shop,
          "shopid": shop.shopid,
        })
        .where("timestamp",
            isGreaterThanOrEqualTo: startMonth.millisecondsSinceEpoch)
        .where("timestamp", isLessThanOrEqualTo: now.millisecondsSinceEpoch)
        .getDocuments();

    return wasteSnapshot.documents
        .map((document) => Waste(
              product: Product(
                name: document.data["product"]["name"],
                uom: document.data["product"]["uom"],
                buyingPrice: document.data["product"]["buyingPrice"],
                sellingPrice: document.data["product"]["sellingPrice"],
                productid: document.data["product"]["productid"],
              ),
              shop: Shop(
                shop: document.data["shop"]["shop"],
                shopid: document.data["shop"]["shopid"],
              ),
              stockid: document.data["stockid"],
              wasteid: document.data["wasteid"],
              dateadded: document.data["dateadded"],
              timestamp: document.data["timestamp"],
              quantity: document.data["quantity"],
            ))
        .toList();
  }

  void getShopStock(Shop shop) {
    stock.add([]);
    _db
        .collection('stock')
        .where("shop", isEqualTo: {
          "shop": shop.shop,
          "shopid": shop.shopid,
        })
        .snapshots()
        .listen((QuerySnapshot stockSnapshot) {
          stock.add(
            stockSnapshot.documents
                .map((document) => Stock(
                      product: Product(
                          name: document.data["product"]["name"],
                          uom: document.data["product"]["uom"],
                          buyingPrice: document.data["product"]["buyingPrice"],
                          sellingPrice: document.data["product"]
                              ["sellingPrice"],
                          productid: document.data["product"]["productid"]),
                      shop: Shop(
                        shop: document.data["shop"]["shop"],
                        shopid: document.data["shop"]["shopid"],
                      ),
                      dateadded: document.data["dateadded"],
                      quantity: document.data["quantity"],
                      stockid: document.data["stockid"],
                    ))
                .toList(),
          );
        });
  }

  dispose() {
    shops.close();
    products.close();
    employees.close();
    items.close();
    stock.close();
    waste.close();
    monthwaste.close();
    sales.close();
    monthsales.close();
  }
}
