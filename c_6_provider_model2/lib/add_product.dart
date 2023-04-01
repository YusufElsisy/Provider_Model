import 'package:c_6_provider_model2/products.dart';
import 'package:flutter/material.dart';

//import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  bool isLoading = false;
  double price = 0;

  @override
  Widget build(BuildContext context) {
    var titleController = TextEditingController();
    var descController = TextEditingController();
    var priceController = TextEditingController();
    var imageController = TextEditingController();

    Widget inputForm(String inputParameter, TextEditingController controller) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
              labelText: inputParameter,
              hintText: "Add $inputParameter",
              hintStyle: TextStyle(color: Theme.of(context).primaryColor),
              border: const OutlineInputBorder()),
        ),
      );
    }

    /*Widget tileBuilder(String title, IconData icon, ImageSource source,
        BuildContext dialogContext) {
      return Container(
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(25)),
        child: ListTile(
          onTap: () {
            Provider.of<Products>(context, listen: false).getImage(source);
            Navigator.pop(dialogContext);
          },
          leading: Icon(icon),
          title: Text(title),
        ),
      );
    }*/

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Product"),
      ),
      body: Container(
        color: Theme.of(context).secondaryHeaderColor,
        child: isLoading == true
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListView(
                  children: [
                    inputForm("Title", titleController),
                    inputForm("Description", descController),
                    inputForm("Price", priceController),
                    inputForm("ImageUrl", imageController),
                    /* Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                      labelText: "Title",
                      hintText: "Add Title",
                      border: OutlineInputBorder()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(
                      labelText: "Description",
                      hintText: "Add Description",
                      border: OutlineInputBorder()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(
                      labelText: "Price",
                      hintText: "Add Price",
                      border: OutlineInputBorder()),
                ),
              ), */ // I Put them in a Function
                    /*FilledButton(
                  child: const Text("Add Image"),
                  onPressed: () {
                    var dialog = AlertDialog(
                      title: const Text("Choose Image"),
                      content: Builder(builder: (dialogContext) {
                        return ListView(
                          shrinkWrap: true,
                          children: [
                            const Divider(color: Colors.black, thickness: 2),
                            const SizedBox(height: 10),
                            tileBuilder("Camera", Icons.add_a_photo_outlined,
                                ImageSource.camera, dialogContext),
                            const SizedBox(height: 10),
                            tileBuilder("Gallery", Icons.photo,
                                ImageSource.gallery, dialogContext)
                          ],
                        );
                      }),
                    );
                    showDialog(context: context, builder: (ctx) => dialog);
                  }),*/ // I Changed them with Text Form
                    FilledButton(
                        onPressed: () async {
                          if (titleController.text.isEmpty ||
                              descController.text.isEmpty ||
                              priceController.text.isEmpty ||
                              imageController.text.isEmpty) {
                            ToastContext().init(context);
                            Toast.show("Enter All Fields", duration: 2);
                            /*} else if (Provider.of<Products>(context, listen: false)
                            .image ==
                        null) {
                      ToastContext().init(context);
                      Toast.show("Choose an Image", duration: 2);*/
                          } else {
                            try {
                              setState(() {
                                price = double.parse(priceController.text);
                              });
                              setState(() {
                                isLoading = true;
                              });
                              Provider.of<Products>(context, listen: false)
                                  .addProd(
                                      titleController.text,
                                      descController.text,
                                      price,
                                      imageController.text)
                                  .catchError((_) {
                                return showDialog(
                                    context: context,
                                    builder: (innercontext) => AlertDialog(
                                            title: const Text("Error"),
                                            content: const Text(
                                                'Something Went Wrong'),
                                            actions: [
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(innercontext)
                                                          .pop(),
                                                  child: const Text("Okey"))
                                            ]));
                              }).then((value) {
                                setState(() {
                                  isLoading = false;
                                });
                                Navigator.of(context).pop();
                              });
                              //Provider.of<Products>(context, listen: false).image = imageController.text;

                              //Provider.of<Products>(context, listen: false).deleteImage();
                            } catch (e) {
                              ToastContext().init(context);
                              Toast.show("Enter A Valid Price", duration: 2);
                            }
                          }
                        },
                        child: const Text("Add Product"))
                  ],
                ),
              ),
      ),
    );
  }
}
