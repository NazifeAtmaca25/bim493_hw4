import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductFormDialog extends StatefulWidget {
  final Product? existing; // null => add
  const ProductFormDialog({super.key, this.existing});

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _barcodeC;
  late final TextEditingController _nameC;
  late final TextEditingController _catC;
  late final TextEditingController _unitPriceC;
  late final TextEditingController _taxRateC;
  late final TextEditingController _stockC;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _barcodeC = TextEditingController(text: e?.barcodeNo ?? '');
    _nameC = TextEditingController(text: e?.productName ?? '');
    _catC = TextEditingController(text: e?.category ?? '');
    _unitPriceC = TextEditingController(text: e == null ? '' : e.unitPrice.toString());
    _taxRateC = TextEditingController(text: e == null ? '' : e.taxRate.toString());
    _stockC = TextEditingController(text: e?.stockInfo?.toString() ?? '');
  }

  @override
  void dispose() {
    _barcodeC.dispose();
    _nameC.dispose();
    _catC.dispose();
    _unitPriceC.dispose();
    _taxRateC.dispose();
    _stockC.dispose();
    super.dispose();
  }

  double _calcPrice(double unitPrice, int taxRate) {
    return unitPrice + (unitPrice * taxRate / 100.0);
  }

  String? _requiredText(String? v, String field) {
    if (v == null || v.trim().isEmpty) return '$field boş olamaz';
    return null;
  }

  String? _positiveDouble(String? v, String field) {
    if (v == null || v.trim().isEmpty) return '$field boş olamaz';
    final x = double.tryParse(v.replaceAll(',', '.'));
    if (x == null) return '$field sayı olmalı';
    if (x < 0) return '$field negatif olamaz';
    return null;
  }

  String? _taxValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'TaxRate boş olamaz';
    final x = int.tryParse(v);
    if (x == null) return 'TaxRate sayı olmalı';
    if (x < 0) return 'TaxRate negatif olamaz';
    if (x > 100) return 'TaxRate 0-100 arası olmalı';
    return null;
  }

  String? _stockValidator(String? v) {
    if (v == null || v.trim().isEmpty) return null; // nullable
    final x = int.tryParse(v);
    if (x == null) return 'StockInfo sayı olmalı';
    if (x < 0) return 'StockInfo negatif olamaz';
    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final barcode = _barcodeC.text.trim();
    final name = _nameC.text.trim();
    final cat = _catC.text.trim();
    final unitPrice = double.parse(_unitPriceC.text.replaceAll(',', '.'));
    final tax = int.parse(_taxRateC.text.trim());
    final stock = _stockC.text.trim().isEmpty ? null : int.parse(_stockC.text.trim());
    final price = _calcPrice(unitPrice, tax);

    final product = Product(
      barcodeNo: barcode,
      productName: name,
      category: cat,
      unitPrice: unitPrice,
      taxRate: tax,
      price: price,
      stockInfo: stock,
    );

    Navigator.pop(context, product);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return AlertDialog(
      title: Text(isEdit ? 'Edit Product' : 'Add Product'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _barcodeC,
                decoration: const InputDecoration(labelText: 'BarcodeNo'),
                validator: (v) => _requiredText(v, 'BarcodeNo'),
                enabled: !isEdit, // PK değişmesin
              ),
              TextFormField(
                controller: _nameC,
                decoration: const InputDecoration(labelText: 'ProductName'),
                validator: (v) => _requiredText(v, 'ProductName'),
              ),
              TextFormField(
                controller: _catC,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (v) => _requiredText(v, 'Category'),
              ),
              TextFormField(
                controller: _unitPriceC,
                decoration: const InputDecoration(labelText: 'UnitPrice'),
                keyboardType: TextInputType.number,
                validator: (v) => _positiveDouble(v, 'UnitPrice'),
              ),
              TextFormField(
                controller: _taxRateC,
                decoration: const InputDecoration(labelText: 'TaxRate (%)'),
                keyboardType: TextInputType.number,
                validator: _taxValidator,
              ),
              TextFormField(
                controller: _stockC,
                decoration: const InputDecoration(labelText: 'StockInfo (optional)'),
                keyboardType: TextInputType.number,
                validator: _stockValidator,
              ),
              const SizedBox(height: 8),
              Text(
                'Price otomatik hesaplanır: UnitPrice + (UnitPrice * TaxRate/100)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
