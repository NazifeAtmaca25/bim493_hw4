import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/product.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._internal();
  DBHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'products.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE ProductTable(
            BarcodeNo TEXT PRIMARY KEY,
            ProductName TEXT NOT NULL,
            Category TEXT NOT NULL,
            UnitPrice REAL NOT NULL,
            TaxRate INTEGER NOT NULL,
            Price REAL NOT NULL,
            StockInfo INTEGER
          )
        ''');
      },
    );
  }

  Future<int> insertProduct(Product p) async {
    final db = await database;
    return await db.insert(
      'ProductTable',
      p.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort, // duplicate barcode => error
    );
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final rows = await db.query('ProductTable', orderBy: 'ProductName ASC');
    return rows.map((e) => Product.fromMap(e)).toList();
  }

  Future<Product?> getByBarcode(String barcode) async {
    final db = await database;
    final rows = await db.query(
      'ProductTable',
      where: 'BarcodeNo = ?',
      whereArgs: [barcode],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Product.fromMap(rows.first);
  }

  Future<int> updateProduct(Product p) async {
    final db = await database;
    return await db.update(
      'ProductTable',
      p.toMap(),
      where: 'BarcodeNo = ?',
      whereArgs: [p.barcodeNo],
    );
  }

  Future<int> deleteProduct(String barcode) async {
    final db = await database;
    return await db.delete(
      'ProductTable',
      where: 'BarcodeNo = ?',
      whereArgs: [barcode],
    );
  }
}
