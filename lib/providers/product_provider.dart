import 'package:flutter/material.dart';

import '../data/models/product_model.dart';
import '../data/repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider({ProductRepository? repository})
    : _repository = repository ?? ProductRepository();

  final ProductRepository _repository;

  List<Product> _products = [];
  List<Product> _allProducts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load danh sách sản phẩm từ database và cập nhật UI.
  Future<void> loadProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final items = await _repository.getAllProducts();
      _allProducts = List<Product>.from(items);
      _products = List<Product>.from(items);
    } catch (e) {
      _errorMessage = 'Load products failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Thêm sản phẩm mới và cập nhật UI.
  Future<void> addProduct(Product product) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.insertProduct(product);
      await _refreshFromDatabase();
    } catch (e) {
      _errorMessage = 'Add product failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cập nhật sản phẩm và cập nhật UI.
  Future<void> updateProduct(Product product) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateProduct(product);
      await _refreshFromDatabase();
    } catch (e) {
      _errorMessage = 'Update product failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Xoá sản phẩm khỏi database và UI.
  Future<void> deleteProduct(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteProduct(id);
      await _refreshFromDatabase();
    } catch (e) {
      _errorMessage = 'Delete product failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tìm kiếm/lọc sản phẩm theo từ khóa hoặc categoryId.
  void searchProducts(String keyword) {
    final query = keyword.trim().toLowerCase();

    if (query.isEmpty) {
      _products = List<Product>.from(_allProducts);
      notifyListeners();
      return;
    }

    final int? categoryId = int.tryParse(query);

    _products = _allProducts.where((product) {
      final matchName = product.name.toLowerCase().contains(query);
      final matchCategory =
          categoryId != null && product.categoryId == categoryId;
      return matchName || matchCategory;
    }).toList();

    notifyListeners();
  }

  Future<void> _refreshFromDatabase() async {
    final items = await _repository.getAllProducts();
    _allProducts = List<Product>.from(items);
    _products = List<Product>.from(items);
  }
}
