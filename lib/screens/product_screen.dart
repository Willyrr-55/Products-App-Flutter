import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:products_app/providers/product_form_provider.dart';
import 'package:products_app/services/services.dart';
import 'package:products_app/widgets/widgets.dart';
import 'package:provider/provider.dart';

import '../ui/input_decorations.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<ProductsService>(context);

    return ChangeNotifierProvider(
      create: (_) => ProductFormProvider(productService.selectedProduct),
      child: _ProductScreenBody(productService: productService),
    );

    // return _ProductScreenBody(productService: productService);
  }
}

class _ProductScreenBody extends StatelessWidget {
  const _ProductScreenBody({
    Key? key,
    required this.productService,
  }) : super(key: key);

  final ProductsService productService;

  @override
  Widget build(BuildContext context) {
    final productForm = Provider.of<ProductFormProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
      ),
      body: SingleChildScrollView(
        // keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [
            Stack(
              children: [
                ProductImage(url: productService.selectedProduct.picture),
                Positioned(
                    top: 30,
                    right: 40,
                    child: IconButton(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final PickedFile? pickedFile = await picker.getImage(
                              // source: ImageSource.gallery,
                              source: ImageSource.camera,
                              imageQuality: 80);

                          if (pickedFile == null) {
                            print('No image selected');
                            return;
                          }
                          productService
                              .updateSelectedProductImage(pickedFile.path);
                        },
                        icon: const Icon(Icons.camera_alt_outlined,
                            size: 40, color: Colors.white))),
              ],
            ),
            _ProductForm(),
            const SizedBox(height: 100)
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: productService.isSaving
            ? null
            : () async {
                if (!productForm.isValidForm()) return;

                final String? imageUrl = await productService.uploadImage();
                print(imageUrl);

                if (imageUrl != null) productForm.product.picture = imageUrl;
                productService.saveOrCreateProduct(productForm.product);

                // ignore: use_build_context_synchronously
                FocusScope.of(context).unfocus();
              },
        child: 
          productService.isSaving
            ? const CircularProgressIndicator(color: Colors.white,) 
            : const Icon(Icons.save_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}

class _ProductForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productForm = Provider.of<ProductFormProvider>(context);
    final product = productForm.product;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        decoration: _buildBoxDecoration(),
        child: Form(
          key: productForm.formkey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(children: [
            const SizedBox(height: 10),
            TextFormField(
              initialValue: product.name,
              onChanged: (value) => product.name = value,
              validator: (value) {
                if (value == null || value.length < 1)
                  return 'The name is required';
              },
              decoration: InputDecorations.authInputDecoration(
                  hintText: 'Product name', labelText: 'Name:'),
            ),
            const SizedBox(height: 30),
            TextFormField(
              initialValue: '${product.price}',
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}'))
              ],
              onChanged: (value) {
                if (double.tryParse(value) == null) {
                  product.price = 0;
                } else {
                  product.price = double.parse(value);
                }
              },
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecorations.authInputDecoration(
                  hintText: '\$150', labelText: 'Price:'),
            ),
            const SizedBox(height: 30),
            SwitchListTile.adaptive(
                title: const Text('Available'),
                activeColor: Colors.indigo,
                value: product.avaliable,
                onChanged: productForm.updateAvaolability),
            const SizedBox(height: 30),
          ]),
        ),
      ),
    );
  }

  BoxDecoration _buildBoxDecoration() => BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(25),
              bottomLeft: Radius.circular(25)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 5),
                blurRadius: 5)
          ]);
}
