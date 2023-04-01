import 'package:c_6_provider_model2/products.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProdDetails extends StatelessWidget {
  final String id;

  const ProdDetails(this.id, {super.key});

  @override
  Widget build(BuildContext context) {
    List<Product> list = Provider.of<Products>(context).prodList;
    Product clearProd =
        Product(id: '', title: '', description: '', price: 0.0, imageUrl: '');
    Product filteredItem =
        list.firstWhere((element) => element.id == id, orElse: () => clearProd);
    return Scaffold(
      appBar: AppBar(
        title: filteredItem == clearProd ? null : Text(filteredItem.title),
        actions: [
          FilledButton(
              onPressed: () =>
                  Provider.of<Products>(context, listen: false).updateData(id),
              child: const Text('Update Data'))
        ],
      ),
      body: filteredItem == clearProd
          ? null
          : Container(
              color: Theme.of(context).secondaryHeaderColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: [
                    Card(
                      color: Theme.of(context).primaryColor,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.network(filteredItem.imageUrl,
                            fit: BoxFit.fill,
                            loadingBuilder: (context, child, progress) =>
                                progress == null
                                    ? child
                                    : const CircularProgressIndicator()),
                      ),
                    ),
                    Card(
                      color: Theme.of(context).primaryColor,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              filteredItem.title,
                              style: const TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                            const Divider(thickness: 1, color: Colors.black),
                            Text(filteredItem.description,
                                textAlign: TextAlign.justify),
                            const Divider(thickness: 1, color: Colors.black),
                            Text(
                              "\$${filteredItem.price}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.delete),
        onPressed: () {
          Navigator.pop(context, filteredItem.id);
        },
      ),
    );
  }
}
