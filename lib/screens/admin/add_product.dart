import 'package:buybes/constants.dart';
import 'package:buybes/custom_widgets/custom_text_field.dart';
import 'package:buybes/services/fire_store.dart';
import 'package:flutter/material.dart';
import 'package:buybes/models/product.dart';

class AddProduct extends StatelessWidget {
  static String id = 'AddProduct';
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  String productName,
      productPrice,
      productDescription,
      productCategory,
      productLocation,
      productImage;
  final _fireStore = FireStore();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainColor,
      body: Form(
        key: _globalKey,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CustomTextField(
                  hint: 'Product Name',
                  onSaved: (value) {
                    productName = value;
                  },
                  icon: null,
                ),
                SizedBox(
                  height: 10,
                ),
                CustomTextField(
                  hint: 'Product Price',
                  onSaved: (value) {
                    productPrice = value;
                  },
                  icon: null,
                ),
                SizedBox(
                  height: 10,
                ),
                CustomTextField(
                  hint: 'Product Description',
                  onSaved: (value) {
                    productDescription = value;
                  },
                  icon: null,
                ),
                SizedBox(
                  height: 10,
                ),
                CustomTextField(
                  hint: 'Product Category',
                  onSaved: (value) {
                    productCategory = value;
                  },
                  icon: null,
                ),
                SizedBox(
                  height: 10,
                ),
                CustomTextField(
                  hint: 'Product Location',
                  onSaved: (value) {
                    productLocation = value;
                  },
                  icon: null,
                ),
                SizedBox(
                  height: 10,
                ),
                CustomTextField(
                  hint: 'Product Image Url',
                  onSaved: (value) {
                    productImage = value;
                  },
                  icon: null,
                ),
                SizedBox(
                  height: 25,
                ),
                RaisedButton(
                  onPressed: () {
                    if (_globalKey.currentState.validate()) {
                      _globalKey.currentState.save();
                      _fireStore.addProduct(
                        Product(
                          pName: productName,
                          pPrice: productPrice,
                          pDescription: productDescription,
                          pCategory: productCategory,
                          pLocation: productLocation,
                          pImage: productImage,
                        ),
                      );
                    }
                  },
                  child: Text('Add Product'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
