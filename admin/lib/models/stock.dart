import 'package:flutter/foundation.dart';
import './shop.dart';
import './product.dart';

class Stock {
  final Product product;
  final double quantity;
  final String stockid;
  final String dateadded;
  final Shop shop;

  const Stock(
      {@required this.product,
      @required this.dateadded,
      @required this.shop,
      @required this.quantity,
      this.stockid});

  Map<String, dynamic> get map {
    return {
      "product": product.map,
      "quantity": quantity,
      "dateadded": dateadded.toString(),
      "shop": {
        "shop": shop.shop,
        "shopid": shop.shopid,
      },
      "stockid": stockid
    };
  }
}
