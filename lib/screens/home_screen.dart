import 'package:flutter/material.dart';
import 'package:products_app/models/models.dart';
import 'package:products_app/screens/screens.dart';
import 'package:products_app/services/services.dart';
import 'package:products_app/widgets/widgets.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
   
  const HomeScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {

    final productsService = Provider.of<ProductsService>(context);
    final authService = Provider.of<AuthService>(context);

    if(productsService.isLoading) return const LoadingScreen();

    final List<Product> products = productsService.products;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        leading: IconButton(
          icon: Icon( Icons.login_outlined), 
          onPressed: () async{ 
            await authService.logout();
            // ignore: use_build_context_synchronously
            Navigator.pushReplacementNamed(context, 'login');
           },
        ),
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (BuildContext context, int index) => GestureDetector(
          child: ProductCard(product: products[index]),
          onTap: (){
             productsService.selectedProduct = products[index].copy();
             Navigator.pushNamed(context, 'product');
          }
        )
      ),
      floatingActionButton: FloatingActionButton(
        child:const Icon(Icons.add),
        onPressed: (){
          productsService.selectedProduct = Product(
            avaliable: true, 
            name: '', 
            price: 0
          );
          Navigator.pushNamed(context, 'product');
        } ),
    );
  }
}