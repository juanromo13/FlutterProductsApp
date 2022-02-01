import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:productos_app/models/models.dart';

class ProductsService extends ChangeNotifier {
  final String _baseUrl = 'productsapp-f2658-default-rtdb.firebaseio.com';
  final List<Product> products = [];
  Product? selectedProduct;

  final storage = new FlutterSecureStorage();

  File? newPictureFile;

  bool isLoading = true;
  bool isSaving = false;

  ProductsService() {
    this.loadProducts();
  }

  Future loadProducts() async {
    this.isLoading = true;
    notifyListeners();

    final url = Uri.https(_baseUrl, 'products.json', {
      'auth': await storage.read(key: 'token') ?? ''
    });
    final res = await http.get(url);

    final Map<String, dynamic> productsMap = json.decode(res.body);

    productsMap.forEach((key, value) {
      final tempProduct = Product.fromMap(value);
      tempProduct.id = key;

      this.products.add(tempProduct);
    });

    this.isLoading = false;
    notifyListeners();
  }

  Future saveOrCreateProduct(Product product) async {
    this.isSaving = true;
    notifyListeners();

    if (product.id == null) {
      // Create
      await createProduct(product);
    } else {
      // Update
      await this.updateProduct(product);
    }

    this.isSaving = false;
    notifyListeners();
  }

  Future<String> createProduct(Product product) async {
    final url = Uri.https(_baseUrl, 'products.json', {
      'auth': await storage.read(key: 'token') ?? ''
    });
    final res = await http.post(url, body: product.toJson());
    final decodedData = json.decode(res.body);

    product.id = decodedData['name'];

    this.products.add(product);

    return product.id!;
  }

  Future<String> updateProduct(Product product) async {
    final url = Uri.https(_baseUrl, 'products/${product.id}.json', {
      'auth': await storage.read(key: 'token') ?? ''
    });
    final res = await http.delete(url, body: product.toJson());
    final decodedData = res.body;

    final index =
        this.products.indexWhere((element) => element.id == product.id);
    this.products[index] = product;

    return product.id!;
  }

  Future<String> deleteProduct(Product product) async {
    final url = Uri.https(_baseUrl, 'products/${product.id}.json', {
      'auth': await storage.read(key: 'token') ?? ''
    });
    final res = await http.delete(url);
    final decodedData = res.body;

    final index =
    this.products.indexWhere((element) => element.id == product.id);
    this.products[index] = product;

    return product.id!;
  }

  Future refreshProducts() async {
    this.products.clear();
    final url = Uri.https(_baseUrl, 'products.json', {
      'auth': await storage.read(key: 'token') ?? ''
    });
    final res = await http.get(url);

    final Map<String, dynamic> productsMap = json.decode(res.body);

    productsMap.forEach((key, value) {
      final tempProduct = Product.fromMap(value);
      tempProduct.id = key;

      this.products.add(tempProduct);
    });
    notifyListeners();
  }

  void updateSelectedProductImage(String path) {
    this.selectedProduct!.picture = path;
    this.newPictureFile = File.fromUri(Uri(path: path));

    notifyListeners();
  }

  Future<String?> uploadImage() async {
    if (this.newPictureFile == null) return null;

    this.isSaving = true;
    notifyListeners();

    final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/dcr0ogjg5/image/upload?upload_preset=yxwjw4mw');
    final imageUploadRequest = http.MultipartRequest('POST', url);

    final file = await http.MultipartFile.fromPath('file', newPictureFile!.path);

    imageUploadRequest.files.add(file);

    final streamResponse = await imageUploadRequest.send();
    final res = await http.Response.fromStream(streamResponse);

    if (res.statusCode != 200 && res.statusCode != 201) {
      print('Error');
      print(res.body);
      return null;
    }

    this.newPictureFile = null;

    final decodedData = json.decode(res.body);
    return decodedData['secure_url'];
  }
}
