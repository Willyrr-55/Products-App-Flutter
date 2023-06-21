
import 'package:flutter/material.dart';

import '../models/models.dart';

class ProductFormProvider extends ChangeNotifier{

  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  Product product;

  ProductFormProvider( this.product );

  updateAvaolability(bool value){
    product.avaliable = value;
    notifyListeners();
  }

  bool isValidForm(){
    return formkey.currentState?.validate() ?? false ;
  }

}