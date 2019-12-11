import './shop.dart';
import './product.dart';

class Sale {
  final Product product;
  final String salesid;
  final String dateadded;
  final int timestamp;
  final Shop shop;
  final double quantity;
  final String stockid;

  const Sale({
    this.product,
    this.salesid,
    this.stockid,
    this.shop,
    this.dateadded,
    this.timestamp,
    this.quantity,
  });

  Map<String, dynamic> get map {
    return {
      "product": product.map,
      "salesid": salesid,
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
