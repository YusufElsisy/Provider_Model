import 'dart:core';

import 'package:c_6_provider_model2/Authentication.dart';
import 'package:c_6_provider_model2/products.dart';
import 'package:c_6_provider_model2/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'add_product.dart';
import 'auth_screen.dart';
import 'prod_details.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<Authentication>(create: (_) => Authentication()),
      //ChangeNotifierProvider<Products>(create: (_) => Products()),
      ChangeNotifierProxyProvider<Authentication, Products>(
        create: (_) => Products(),
        update: (_, auth, prod) => prod!..update(auth.token, prod.prodList),
      )
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Authentication>(
      builder: (ctx, value, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Shop Store',
          theme: ThemeData(
            primarySwatch: Colors.grey,
            secondaryHeaderColor: Colors.black54,
          ),
          home: value.auth
              ? const MyHomePage()
              : FutureBuilder(
                  future: value.autoLogIn(),
                  builder: (ctx, snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting
                          ? const SplashScreen()
                          : const AuthScreen()),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoading = true;

  @override
  void initState() {
    /*if (Provider.of<Products>(context, listen: false).prodList.isEmpty) {
      isLoading = false;
    } else {*/
    Provider.of<Products>(context, listen: false)
        .fetchData()
        .then((_) => isLoading = false);
    //}
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var prodListItem = Provider.of<Products>(context).prodList;
    Widget cardBuilder(
        String id, String image, String title, String desc, double price, ctx) {
      return TextButton(
        onPressed: () {
          Navigator.push(
                  ctx, MaterialPageRoute(builder: (_) => ProdDetails(id)))
              .then((value) {
            print('Hello $value');
            if (value != null) {
              return Provider.of<Products>(context, listen: false)
                  .delete(value);
            }
          });
        },
        child: Card(
          color: Theme.of(context).primaryColor,
          elevation: 20,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Image.network(image,
                      fit: BoxFit.fill,
                      loadingBuilder: (context, child, progress) =>
                          progress == null
                              ? child
                              : const CircularProgressIndicator()),
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 30),
                      ),
                      const Divider(thickness: 1, color: Colors.black),
                      Text(
                        desc,
                        style: const TextStyle(fontSize: 10),
                        softWrap: true,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.justify,
                      ),
                      const Divider(
                        thickness: 1,
                        color: Colors.black,
                      ),
                      Text(
                        "\$$price",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
              const Expanded(
                flex: 1,
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.black,
                ),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Shop Store'),
          actions: [
            FilledButton(
                onPressed: () =>
                    Provider.of<Authentication>(context, listen: false)
                        .logOut(),
                child: const Text('LogOut'))
          ],
        ),
        body: Container(
            color: Theme.of(context).secondaryHeaderColor,
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : (prodListItem.isEmpty
                    ? const Center(
                        child: Text("No Products Added!",
                            style: TextStyle(fontSize: 25)))
                    : RefreshIndicator(
                        onRefresh: () =>
                            Provider.of<Products>(context, listen: false)
                                .fetchData(),
                        child: ListView(
                            children: prodListItem
                                .map((e) => Builder(
                                    builder: (ctx) => cardBuilder(
                                        e.id,
                                        e.imageUrl,
                                        e.title,
                                        e.description,
                                        e.price,
                                        ctx)))
                                .toList()),
                      ))),
        floatingActionButton: FilledButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const AddProduct())),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.add_box_outlined),
                SizedBox(width: 3),
                Text("Add Product",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18))
              ],
            )));
  }
}
