import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../widgets/product_form_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _barcodeSearchC = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ProductProvider>().loadProducts());
  }

  @override
  void dispose() {
    _barcodeSearchC.dispose();
    super.dispose();
  }

  Future<void> _openAdd([String? prefillBarcode]) async {
    if (prefillBarcode != null && prefillBarcode.trim().isNotEmpty) {
      _barcodeSearchC.text = prefillBarcode.trim();
    }

    final result = await showDialog<Product>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ProductFormDialog(existing: null),
    );

    if (result == null) return;

    try {
      await context.read<ProductProvider>().addProduct(result);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product saved successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Duplicate barcode! Please use a unique BarcodeNo.')),
      );
    }
  }

  Future<void> _openEdit(Product p) async {
    final edited = await showDialog<Product>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ProductFormDialog(existing: p),
    );

    if (edited == null) return;

    await context.read<ProductProvider>().updateProduct(edited);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product updated successfully.')),
    );
  }

  Future<void> _confirmDelete(Product p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Delete product with barcode: ${p.barcodeNo}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (ok != true) return;

    await context.read<ProductProvider>().deleteProduct(p.barcodeNo);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product deleted.')),
    );
  }

  Future<void> _search() async {
    final barcode = _barcodeSearchC.text.trim();
    if (barcode.isEmpty) {
      context.read<ProductProvider>().setHighlight(null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a barcode to search.')),
      );
      return;
    }

    final provider = context.read<ProductProvider>();
    final product = await provider.findByBarcode(barcode);

    if (product != null) {
      provider.setHighlight(barcode); // highlight row
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product found: ${product.productName}')),
      );
    } else {
      provider.setHighlight(null);
      if (!mounted) return;
      final add = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Product not found'),
          content: const Text('Product not found. Would you like to add a new product?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes')),
          ],
        ),
      );

      if (add == true) {
        await _openAdd(barcode);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final items = provider.products;
    final highlight = provider.highlightBarcode;

    return Scaffold(
      appBar: AppBar(title: const Text('Barcode Product Lookup')),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _barcodeSearchC,
                    decoration: const InputDecoration(
                      labelText: 'Barcode',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _search,
                  child: const Text('Search'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Responsive: dar ekranlarda yatay kaydırılabilir DataTable
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: constraints.maxWidth),
                      child: SingleChildScrollView(
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Barcode')),
                            DataColumn(label: Text('Name')),
                            DataColumn(label: Text('Category')),
                            DataColumn(label: Text('UnitPrice')),
                            DataColumn(label: Text('TaxRate')),
                            DataColumn(label: Text('Price')),
                            DataColumn(label: Text('Stock')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: items.map((p) {
                            final isHL = (highlight != null && p.barcodeNo == highlight);
                            return DataRow(
                              color: isHL
                                  ? WidgetStateProperty.all(Colors.yellow.withOpacity(0.25))
                                  : null,
                              cells: [
                                DataCell(Text(p.barcodeNo)),
                                DataCell(Text(p.productName)),
                                DataCell(Text(p.category)),
                                DataCell(Text(p.unitPrice.toStringAsFixed(2))),
                                DataCell(Text('${p.taxRate}%')),
                                DataCell(Text(p.price.toStringAsFixed(2))),
                                DataCell(Text(p.stockInfo?.toString() ?? '-')),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        tooltip: 'Edit',
                                        onPressed: () => _openEdit(p),
                                        icon: const Icon(Icons.edit),
                                      ),
                                      IconButton(
                                        tooltip: 'Delete',
                                        onPressed: () => _confirmDelete(p),
                                        icon: const Icon(Icons.delete),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
