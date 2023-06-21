



import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:products_app/models/models.dart';

class ProductsService extends ChangeNotifier{

  final String _baseUrl = 'flutter-varios-e5ad4-default-rtdb.firebaseio.com';
  final List<Product> products = [];
  late Product selectedProduct;

  final storage = FlutterSecureStorage();

  File? newPictureFile;
  bool isLoading = true;
  bool isSaving = false;

  ProductsService(){
    loadProducts();
  }

  Future <List<Product>>  loadProducts ( ) async {

    isLoading = true;
    notifyListeners();

    final url = Uri.https(_baseUrl, 'products.json',{
      'auth': await storage.read(key: 'token') ?? ''
    });
    final resp = await http.get(url);

    final Map<String, dynamic> productsMap = json.decode( resp.body );

    productsMap.forEach((key, value) {
      final tempProduct = Product.fromMap(value);
      tempProduct.id = key;
      products.add(tempProduct);
    });

    isLoading = false;
    notifyListeners();
    return products;
  }

  Future saveOrCreateProduct( Product product ) async{
    isSaving = true;
    notifyListeners();

    if( product.id == null){
      // Create Product
      await createProduct(product);

    }else{
      // Save Product
      await updateProduct(product);

    }

    isSaving = false;
    notifyListeners();
  }

  Future<String> updateProduct( Product product ) async {
    final url = Uri.https(_baseUrl, 'products/${ product.id }.json',{
      'auth': await storage.read(key: 'token') ?? ''
    });
    final resp = await http.put(url, body: product.toJson() );
    final decodeData = resp.body;

    // TODO Update products list
    int index = products.indexWhere((p) => p.id== product.id);
      // print(index);
      // print(decodeData);
    if (index >= 0) {
      products[index] = product;
      print(index);
    }

    return product.id!;
  }
  
  Future<String> createProduct( Product product ) async {
    final url = Uri.https(_baseUrl, 'products.json',{
      'auth': await storage.read(key: 'token') ?? ''
    });
    final resp = await http.post(url, body: product.toJson() );
    final decodeData = json.decode(resp.body);

    product.id = decodeData['name'];

    products.add(product);

    return product.id!;
  }

  void updateSelectedProductImage(String path){
    selectedProduct.picture = path;
    newPictureFile = File.fromUri( Uri(path: path) );
    notifyListeners();
  }

  Future<String?> uploadImage() async{

    if(newPictureFile == null)return null;

    isSaving = true;
    notifyListeners();

    final url = Uri.parse('https://api.cloudinary.com/v1_1/duqddtdui/image/upload?upload_preset=cwvpt8dh');

    final imageUploadRequest = http.MultipartRequest(
      'POST', url
    );

    final file = await http.MultipartFile.fromPath('file', newPictureFile!.path);

    imageUploadRequest.files.add(file);

    final streamResponse = await imageUploadRequest.send();
    final resp = await http.Response.fromStream(streamResponse);

    if( resp.statusCode != 200 && resp.statusCode != 201){
      print('Something was wrong');
      print(resp.body);
      return null; 
    }

    newPictureFile = null;

    final decodeData = json.decode(resp.body);
    return decodeData['secure_url'];

  }
}