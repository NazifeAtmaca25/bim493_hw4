# BIM493 Mobile Programming I - Assignment #1
## Barcode Product Lookup Application

### Group Members

| Ad Soyad      | Öğrenci Numarası |
|---------------|------------------|
| Gül ERTEN     | 23453142868      |
| Nazife ATMACA | 20629742754      |
| Buğra MUHÇİ   | 14492562250      |



This Flutter application was developed as part of HW4.  
The application provides a barcode-based product management system using a local SQLite database.

---

## Application Purpose

The purpose of this application is to manage products by allowing users to add, search, update, and delete product records.  
All product data is stored locally on the device using SQLite and remains persistent after the application is closed.

---

## Technologies Used

- Flutter
- Dart
- sqflite (SQLite local database)
- provider (state management)
- path (database path handling)

---

## Database Design

The application uses a single table named ProductTable.

Column Details:

- BarcodeNo (TEXT) – Primary Key
- ProductName (TEXT)
- Category (TEXT)
- UnitPrice (REAL)
- TaxRate (INTEGER)
- Price (REAL)
- StockInfo (INTEGER, nullable)

---

## Price Calculation

Product price is calculated automatically using the following formula:

Price = UnitPrice + (UnitPrice × TaxRate / 100)

---

## Application Features

### Add Product
- Products can be added using the Add (+) button.
- All required fields must be filled.
- Barcode number must be unique.

### Search Product
- Products can be searched by barcode number.
- If found, the product row is highlighted in the table.
- If not found, the user is prompted to add a new product.

### Update Product
- Products can be edited using the edit button.
- Barcode number cannot be changed.

### Delete Product
- Products can be deleted using the delete button.
- A confirmation dialog is shown before deletion.

### Data Persistence
- All data is stored locally using SQLite.
- Data remains available after restarting the application.

---

## Input Validation Rules

- BarcodeNo, ProductName, Category: required
- UnitPrice: non-negative number
- TaxRate: integer between 0 and 100
- StockInfo: optional, non-negative integer

---

## Project Structure

lib/
- data/db_helper.dart
- models/product.dart
- providers/product_provider.dart
- screens/home_screen.dart
- widgets/product_form_dialog.dart
- main.dart

---

## Sample Test Data

BarcodeNo: 123  
ProductName: Cola  
Category: Drink  
UnitPrice: 10  
TaxRate: 20  
StockInfo: 5

Expected Price: 12.00

---

## Notes

- Provider is used for state management.
- UI updates automatically after database operations.
- The project fully satisfies the HW4 requirements.

---


