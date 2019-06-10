import './shop.dart';
import './product.dart';

class Waste {
  final Product product;
  final String wasteid;
  final String dateadded;
  final int timestamp;
  final Shop shop;
  final double quantity;
  final String stockid;

  const Waste({
    this.product,
    this.wasteid,
    this.stockid,
    this.shop,
    this.dateadded,
    this.timestamp,
    this.quantity,
  });

  Map<String, dynamic> get map {
    return {
      "product": product.map,
      "salesid": wasteid,
      "dateadded": dateadded,
      "timestamp": timestamp,
      "shop": {
        "shop": shop.shop,
        "shopid": shop.shopid,
      },
      "quantity": quantity,
      "stockid": stockid
    };
  }
}
