import 'package:flutter/material.dart';
import 'package:productos_app/models/models.dart';
import 'package:productos_app/services/services.dart';
import 'package:productos_app/widgets/widgets.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final productService = Provider.of<ProductsService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
        actions: [
          IconButton(
              onPressed: () async {
                await authService.logout();
                Navigator.pushReplacementNamed(context, 'login');
              },
              icon: Icon(Icons.login_outlined))
        ],
      ),
      body: (productService.isLoading)
          ? Center(child: CircularProgressIndicator(color: Colors.indigo))
          : RefreshIndicator(
              onRefresh: () {
                return productService.refreshProducts();
              },
              child: ListView.builder(
                itemCount: productService.products.length,
                itemBuilder: (_, int index) => GestureDetector(
                    child: ProductCard(product: productService.products[index]),
                    onTap: () {
                      productService.selectedProduct =
                          productService.products[index].copy();
                      Navigator.pushNamed(context, 'product');
                    }),
                physics: const AlwaysScrollableScrollPhysics(),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          productService.selectedProduct =
              new Product(available: true, name: '', price: 0.0);
          Navigator.pushNamed(context, 'product');
        },
      ),
    );
  }
}
