import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:lojavirtual_mobile/screens/login_screen.dart';
import 'package:lojavirtual_mobile/screens/order_screen.dart';
import 'package:lojavirtual_mobile/store/cart.store.dart';
import 'package:lojavirtual_mobile/store/user.store.dart';
import 'package:lojavirtual_mobile/widgets/cart_price.dart';
import 'package:lojavirtual_mobile/widgets/cart_tile.dart';
import 'package:lojavirtual_mobile/widgets/coupon_discount_card.dart';
import 'package:lojavirtual_mobile/widgets/loading_widget.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var cart = Provider.of<CartStore>(context);
    var user = Provider.of<UserStore>(context);
    final _scaffoldKey = GlobalKey<ScaffoldState>();

    user.readUser();

    cart.getItems();

    Widget showProducts() {
      return ListView(
        children: <Widget>[
          Column(
            children: cart.products
                .map((product) => CartTile(product, _scaffoldKey))
                .toList(),
          ),
          CouponDiscountCard(_scaffoldKey),
          CartPrice(() async {
            var response = await cart.finishOrder();

            if (response == null) {
              _scaffoldKey.currentState.showSnackBar(
                SnackBar(
                  content: Text(
                      "Ocorreu um erro ao finalizar o pedido! Por favor, tente novamente."),
                  backgroundColor: Colors.redAccent,
                  duration: Duration(seconds: 3),
                ),
              );
            } else {
              if (response["success"] == true) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => OrderScreen(response["message"]),
                  ),
                );
              } else {
                String messageContent =
                    "${response["message"]} | ${response["data"][0]["message"]} ";

                _scaffoldKey.currentState.showSnackBar(
                  SnackBar(
                    content: Text(messageContent),
                    backgroundColor: Colors.redAccent,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            }
          }),
        ],
      );
    }

    Widget cartEmpty() {
      return Center(
        child: Text(
          "Nenhum produto no carrinho!",
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      );
    }

    Widget makeLoginForToBuy() {
      return Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.remove_shopping_cart,
              size: 80.0,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(
              height: 16.0,
            ),
            Text(
              "Faça o login para adicionar produtos!",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 16.0,
            ),
            SizedBox(
              height: 44.0,
              child: RaisedButton(
                child: Text(
                  "Entrar",
                  style: TextStyle(fontSize: 18.0),
                ),
                textColor: Colors.white,
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
              ),
            )
          ],
        ),
      );
    }

    return Observer(builder: (_) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Meu Carrinho"),
          actions: <Widget>[
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(right: 8.0),
              child: Text(
                cart.cartCount == 0
                    ? ""
                    : "${cart.cartCount} ${cart.cartCount == 1 ? 'ITEM' : 'ITENS'}",
                style: TextStyle(fontSize: 17.0),
              ),
            )
          ],
        ),
        body: cart.isLoading && user.isLogged
            ? LoadingWidget()
            : (!user.isLogged
                ? makeLoginForToBuy()
                : (cart.cartCount == 0 ? cartEmpty() : showProducts())),
      );
    });
  }
}
