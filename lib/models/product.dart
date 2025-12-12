class Product {
  final String barcodeNo; // PK
  String productName;
  String category;
  double unitPrice;
  int taxRate; // int
  double price; // unitPrice + tax
  int? stockInfo; // nullable

  Product({
    required this.barcodeNo,
    required this.productName,
    required this.category,
    required this.unitPrice,
    required this.taxRate,
    required this.price,
    this.stockInfo,
  });

  Map<String, dynamic> toMap() {
    return {
      'BarcodeNo': barcodeNo,
      'ProductName': productName,
      'Category': category,
      'UnitPrice': unitPrice,
      'TaxRate': taxRate,
      'Price': price,
      'StockInfo': stockInfo,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      barcodeNo: map['BarcodeNo'] as String,
      productName: map['ProductName'] as String,
      category: map['Category'] as String,
      unitPrice: (map['UnitPrice'] as num).toDouble(),
      taxRate: map['TaxRate'] as int,
      price: (map['Price'] as num).toDouble(),
      stockInfo: map['StockInfo'] == null ? null : map['StockInfo'] as int,
    );
  }
}
