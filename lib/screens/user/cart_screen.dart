import 'package:buybes/constants.dart';
import 'package:buybes/custom_widgets/custom_pop_up_menu.dart';
import 'package:buybes/models/product.dart';
import 'package:buybes/screens/user/product_info.dart';
import 'package:buybes/screens/user/track_orders.dart';
import 'package:buybes/services/fire_store.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'package:shared_preferences/shared_preferences.dart';

class CartScreen extends StatefulWidget {
  static String id = 'CartScreen';

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  FireStore _fireStore = FireStore();
  List<Product> products;
  String uId;
  var razorprice;
Razorpay razorpay;
  @override
  void initState() {
    super.initState();
    getUserId();
razorpay = new Razorpay();

razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlerPaymentSuccess);
razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlerErrorFailure);
razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handlerExternalWallet);
  }

void openCheckout(){
    var options = {
      "key" : "rzp_test_S4YrPxrEFaxHvt",
      "amount" : razorprice*100,
      "name" : "Sample App",
      "description" : "Payment for the some random product",
      "prefill" : {
        "contact" : "2323232323",
        "email" : "shdjsdh@gmail.com"
      },
      "external" : {
        "wallets" : ["paytm"]
      }
    };

try{
razorpay.open(options);
}catch(e){
print(e.toString());
}
}
void handlerPaymentSuccess(){
    print("Pament success");
    Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text('Payment Success'),
                ),
              );
    
  }

void handlerErrorFailure(){
    print("Pament error");
    Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text('Payment Error'),
                ),
              );
}

void handlerExternalWallet(){
    print("External Wallet");
    Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text('External wallet'),
                ),
              );
}
  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double appBarHeight = AppBar().preferredSize.height;
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        title: Text(
          'My Cart',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: <Widget>[
          StreamBuilder<QuerySnapshot>(
              stream: _fireStore.getCartData(uId),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  products = [];
                  for (var doc in snapshot.data.documents) {
                    var data = doc.data;

                    products.add(
                      Product(
                        pID: doc.documentID,
                        pName: data[kProductName],
                        pPrice: data[kProductPrice],
                        pLocation: data[kProductLocation],
                        pQuantity: data[kProductQuantity],
                        pImage:data[kProductImage],
                      ),
                    );
                  }

                  return Container(
                    height: screenHeight -
                        statusBarHeight -
                        appBarHeight -
                        (screenHeight * 0.1),
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(10),
                          child: GestureDetector(
                            onTapUp: (details) {
                              showCustomMenu(
                                  details, context, products[index], index);
                            },
                            child: Container(
                              color: kMainColor,
                              child: Row(
                                children: <Widget>[
                                  CircleAvatar(
                                    backgroundImage: CachedNetworkImageProvider(
                                        products[index].pImage),
                                    radius: screenHeight * 0.15 / 2,
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 20),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                products[index].pName,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                '\Rs${products[index].pPrice}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 20),
                                          child: Text(
                                            '${products[index].pQuantity.toString()} Pcs',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      itemCount: products.length,
                    ),
                  );
                } else {
                  return Container(
                    height: screenHeight -
                        (screenHeight * 0.1) -
                        appBarHeight -
                        statusBarHeight,
                    child: Center(
                      child: Text(
                        'Cart is Empty',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  );
                }
              }),
          Builder(
            builder: (context) => ButtonTheme(
              height: screenHeight * 0.1,
              minWidth: screenWidth,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
              ),
              // ignore: deprecated_member_use
              child: RaisedButton(
                onPressed: () {
                  
                  customDialog(products, context);
                },
                child: Text('Order Now'.toUpperCase()),
                color: kMainColor,
              ),
            ),
          )
        ],
      ),
    );
  }

  void showCustomMenu(details, context, product, index) {
    double dx = details.globalPosition.dx;
    double dy = details.globalPosition.dy;
    double dx2 = MediaQuery.of(context).size.width - dx;
    double dy2 = MediaQuery.of(context).size.height - dy;
    showMenu(
        context: context,
        position: RelativeRect.fromLTRB(dx, dy, dx2, dy2),
        items: [
          MyPopUpMenuItem(
            child: Text('Edit'),
            onClick: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, ProductInfo.id, arguments: product);
            },
          ),
          MyPopUpMenuItem(
            child: Text('Delete'),
            onClick: () {
              Navigator.pop(context);
              _fireStore.deleteCartItem(product.pID, uId);
            },
          ),
        ]);
  }

  void customDialog(List<Product> products, context) async {
    var totalPrice = calcTotalPrice(products);
    String address,mobile,pincode;

    AlertDialog alertDialog = AlertDialog(
      actions: <Widget>[
        MaterialButton(
          child: Text('Confirm'),
          onPressed: () {
            try {
              FireStore fireStore = FireStore();
              fireStore.storeOrders({
                kTotallPrice: totalPrice,
                kAddress: address,
                kMobile:mobile,
                kPincode:pincode,
                kIsConfirmed: false,
                kUserId: uId,
              }, products);
                openCheckout();
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => TrackDelivery()));
              //Navigator.pop(context);
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ordered Successfully'),
                ),
              );
            } catch (e) {
              print(e.message);
            }
          },
        )
      ],
      title: Text('Total Price  = \Rs$totalPrice'),
      content: Column(
        children: [
          TextField(
            onChanged: (value) {
              address = value;
            },
            decoration: InputDecoration(
              hintText: 'Enter Your Home Address',
            ),
          ),
           TextField(
            onChanged: (value) {
              pincode = value;
            },
            decoration: InputDecoration(
              hintText: 'Enter Your pin code',
            ),
          ),
          TextField(
            onChanged: (value) {
              mobile = value;
            },
            decoration: InputDecoration(
              hintText: 'Enter Your phone no',
            ),
          ),
        ],
      ),
    );

    await showDialog(
        context: context,
        builder: (context) {
          return alertDialog;
        });
  }

  calcTotalPrice(List<Product> products) {
    var totalPrice = 0;
    for (var product in products) {
      totalPrice += product.pQuantity * int.parse(product.pPrice);
    }
    setState(() {
      razorprice = totalPrice;
    });
    

    return totalPrice;
  }

  getUserId() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      uId = preferences.getString(kUserId);
    });
  }
}
