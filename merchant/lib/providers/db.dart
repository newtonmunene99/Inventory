import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/subjects.dart';
import '../models/employee.dart';
import '../models/shop.dart';
import '../models/product.dart';
import '../models/stock.dart';
import '../models/sale.dart';
import '../models/waste.dart';

import './auth.dart';
import './connection.dart';

DatabaseProvider dbService = DatabaseProvider();

class DatabaseProvider {
  final Firestore _db = Firestore.instance;
  Firestore get firedb => _db;

  final employee = BehaviorSubject<Employee>();
  final stock = BehaviorSubject<List<Stock>>();
  final products = BehaviorSubject<List<Product>>();
  final sales = BehaviorSubject<List<Sale>>();
  final waste = BehaviorSubject<List<Waste>>();

  DatabaseProvider() {
    _db.collection('products').snapshots().listen(
      (QuerySnapshot productsSnapshot) {
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
      },
    );
  }

  void getCurrentEmployee() async {
    _db
        .collection("employees")
        .document((await authService.auth.currentUser()).email)
        .snapshots()
        .listen((DocumentSnapshot document) {
      List shops = document.data["shops"];
      employee.add(Employee(
        name: document.data["name"],
        email: document.data["email"],
        shops: shops
            .map(
              (shop) => Shop(
                    shop: shop["shop"],
                    shopid: shop["shopid"],
                  ),
            )
            .toList(),
        active: document.data["active"],
      ));
    });
  }

  void getSales(String date, Shop shop) {
    sales.add([]);
    _db
        .collection('sales')
        .where("shop", isEqualTo: {
          "shop": shop.shop,
          "shopid": shop.shopid,
        })
        .where("dateadded", isEqualTo: date)
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

  void getWaste(String date, Shop shop) {
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

  void getStock(Shop shop) {
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

  Future<void> addStock(Stock stock) async {
    if (connectionService.connected.value) {
      try {
        DocumentReference added = await _db.collection('stock').add(stock.map);

        return await added.updateData({
          "stockid": added.documentID,
        });
      } catch (e) {
        throw e;
      }
    } else {
      throw Exception("NOINTERNET");
    }
  }

  Future<void> editStock(Stock stock) async {
    if (connectionService.connected.value) {
      try {
        return await _db
            .collection('stock')
            .document(stock.stockid)
            .updateData(stock.map);
      } catch (e) {
        throw e;
      }
    } else {
      throw Exception("NOINTERNET");
    }
  }

  Future<void> editStockOperations(
      Stock stock, Stock originalStock, String operation) async {
    if (connectionService.connected.value) {
      try {
        DocumentReference added =
            await _db.collection(operation).add(stock.map);

        await added.updateData({
          (operation == "sales" ? "salesid" : "wasteid"): added.documentID,
          "timestamp": DateTime.now().millisecondsSinceEpoch,
        });

        if (originalStock.quantity - stock.quantity == 0.0) {
          return await _db
              .collection('stock')
              .document(originalStock.stockid)
              .delete();
        } else {
          return await _db
              .collection('stock')
              .document(originalStock.stockid)
              .updateData({
            "quantity": originalStock.quantity - stock.quantity,
          });
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
      throw e;
    }
  }

  dispose() {
    employee.close();
    stock.close();
    products.close();
    sales.close();
    waste.close();
  }
}
