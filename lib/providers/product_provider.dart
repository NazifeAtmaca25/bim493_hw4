import 'package:flutter/foundation.dart';
import '../data/db_helper.dart';
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper.instance;

  List<Product> _products = [];
  List<Product> get products => _products;

  String? _highlightBarcode;
  String? get highlightBarcode => _highlightBarcode;

  Future<void> loadProducts() async {
    _products = await _db.getAllProducts();
    notifyListeners();
  }

  Future<Product?> findByBarcode(String barcode) async {
    return await _db.getByBarcode(barcode);
  }

  void setHighlight(String? barcode) {
    _highlightBarcode = barcode;
    notifyListeners();
  }

  Future<void> addProduct(Product p) async {
    await _db.insertProduct(p);
    await loadProducts();
  }

  Future<void> updateProduct(Product p) async {
    await _db.updateProduct(p);
    await loadProducts();
  }

  Future<void> deleteProduct(String barcode) async {
    await _db.deleteProduct(barcode);
    if (_highlightBarcode == barcode) _highlightBarcode = null;
    await loadProducts();
  }
}
