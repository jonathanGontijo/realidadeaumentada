import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:realidadeaumentada/api_consumer.dart';
import 'package:realidadeaumentada/home_screen.dart';

class ItemsUploadScreen extends StatefulWidget {
  @override
  State<ItemsUploadScreen> createState() => _ItemsUploadScreenState();
}

class _ItemsUploadScreenState extends State<ItemsUploadScreen> {
  Uint8List? imageFileUint8List;
  bool isUploading = false;
  String downloadUrlOfUploadedImage = '';

  TextEditingController sellerNameTextEditingController =
      TextEditingController();
  TextEditingController sellerPhoneTextEditingController =
      TextEditingController();
  TextEditingController itemNameTextEditingController = TextEditingController();
  TextEditingController itemDescriptionTextEditingController =
      TextEditingController();
  TextEditingController itemPriceTextEditingController =
      TextEditingController();

  //upload form screen
  Widget uploadFormScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          "Upload New Item",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
            )),
        actions: [
          IconButton(
            onPressed: () {
              //validate upload form fields
              if (isUploading != true) {
                validateUploadFormAndUploadItemInfo();
              }
            },
            icon: const Icon(
              Icons.cloud_upload,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          isUploading == true
              ? const LinearProgressIndicator(
                  color: Colors.purpleAccent,
                )
              : Container(),

          //image
          SizedBox(
            height: 230,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: imageFileUint8List != null
                  ? Image.memory(imageFileUint8List!)
                  : const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                      size: 40,
                    ),
            ),
          ),
          const Divider(
            color: Colors.white70,
            thickness: 2,
          ),

          //seller Name
          ListTile(
            leading: const Icon(
              Icons.person_pin_rounded,
              color: Colors.white,
            ),
            title: SizedBox(
              width: 250,
              child: TextField(
                style: const TextStyle(color: Colors.grey),
                controller: sellerNameTextEditingController,
                decoration: const InputDecoration(
                  hintText: "Seller Name",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const Divider(
            color: Colors.white70,
            thickness: 2,
          ),

          //seller Phone
          ListTile(
            leading: const Icon(
              Icons.phone_iphone_rounded,
              color: Colors.white,
            ),
            title: SizedBox(
              width: 250,
              child: TextField(
                style: const TextStyle(color: Colors.grey),
                controller: sellerPhoneTextEditingController,
                decoration: const InputDecoration(
                  hintText: "Seller Phone",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const Divider(
            color: Colors.white70,
            thickness: 2,
          ),

          //item Name
          ListTile(
            leading: const Icon(
              Icons.title,
              color: Colors.white,
            ),
            title: SizedBox(
              width: 250,
              child: TextField(
                style: const TextStyle(color: Colors.grey),
                controller: itemNameTextEditingController,
                decoration: const InputDecoration(
                  hintText: "Item Name",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const Divider(
            color: Colors.white70,
            thickness: 2,
          ),

          //item Description
          ListTile(
            leading: const Icon(
              Icons.description,
              color: Colors.white,
            ),
            title: SizedBox(
              width: 250,
              child: TextField(
                style: const TextStyle(color: Colors.grey),
                controller: itemDescriptionTextEditingController,
                decoration: const InputDecoration(
                  hintText: "Item Description",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const Divider(
            color: Colors.white70,
            thickness: 2,
          ),

          //item Price
          ListTile(
            leading: const Icon(
              Icons.price_change,
              color: Colors.white,
            ),
            title: SizedBox(
              width: 250,
              child: TextField(
                style: const TextStyle(color: Colors.grey),
                controller: itemPriceTextEditingController,
                decoration: const InputDecoration(
                  hintText: "Item Price",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const Divider(
            color: Colors.white70,
            thickness: 2,
          ),
        ],
      ),
    );
  }

  validateUploadFormAndUploadItemInfo() async {
    if (imageFileUint8List != null) {
      if (sellerNameTextEditingController.text.isNotEmpty &&
          sellerPhoneTextEditingController.text.isNotEmpty &&
          itemNameTextEditingController.text.isNotEmpty &&
          itemDescriptionTextEditingController.text.isNotEmpty &&
          itemPriceTextEditingController.text.isNotEmpty) {
        setState(() {
          isUploading = true;
        });

        //upload image to cloud storage
        String imageUniqueName =
            DateTime.now().millisecondsSinceEpoch.toString();

        fStorage.Reference firebaseStorageRef = fStorage
            .FirebaseStorage.instance
            .ref()
            .child("Items Images")
            .child(imageUniqueName);

        fStorage.UploadTask uploadTaskImageFile =
            firebaseStorageRef.putData(imageFileUint8List!);

        fStorage.TaskSnapshot taskSnapshot =
            await uploadTaskImageFile.whenComplete(() {});
        await taskSnapshot.ref.getDownloadURL().then((imageDownloadUrl) {
          downloadUrlOfUploadedImage = imageDownloadUrl;
        });

        // save item info to firestore
        saveItemInfoToFirestore();
      } else {
        Fluttertoast.showToast(
            msg: "Please complete upload form. Every field is mandatory");
      }
    } else {
      Fluttertoast.showToast(msg: "Please select image file.");
    }
  }

  saveItemInfoToFirestore() {
    String itemuniqueId = DateTime.now().millisecondsSinceEpoch.toString();
    FirebaseFirestore.instance.collection("items").doc(itemuniqueId).set({
      'itemsId': itemuniqueId,
      'itemName': itemNameTextEditingController.text,
      'itemDescription': itemDescriptionTextEditingController.text,
      'itemImage': downloadUrlOfUploadedImage,
      'sellerName': sellerNameTextEditingController.text,
      'sellerPhone': sellerPhoneTextEditingController.text,
      'itemPrice': itemPriceTextEditingController.text,
      'publishedDate': DateTime.now(),
      'status': "available"
    });
    Fluttertoast.showToast(msg: 'Your new item upçoaded successfully.');

    setState(() {
      isUploading = false;
      imageFileUint8List = null;
    });
    Navigator.push(
        context, MaterialPageRoute(builder: (c) => const HomeScreen()));
  }

  Widget defaultScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Upload New Item",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_photo_alternate,
              color: Colors.white,
              size: 200,
            ),
            ElevatedButton(
                onPressed: () {
                  showDialogBox();
                },
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.black54),
                child: const Text(
                  "Add New Item",
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ))
          ],
        ),
      ),
    );
  }

  showDialogBox() {
    return showDialog(
      context: context,
      builder: (c) {
        return SimpleDialog(
          backgroundColor: Colors.black,
          title: const Text(
            'Item Image',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          children: [
            SimpleDialogOption(
              onPressed: () {
                captureImageWithPhoneCamera();
              },
              child: const Text(
                'Capture Image with Camera',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                chooseImageFromPhoneGallery();
              },
              child: const Text(
                'Capture Image from Gallery',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        );
      },
    );
  }

  captureImageWithPhoneCamera() async {
    Navigator.pop(context);

    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.camera);

      if (pickedImage != null) {
        String imagePath = pickedImage.path;
        imageFileUint8List = await pickedImage.readAsBytes();

        //remove background from image
        //make image transparent
        imageFileUint8List =
            await ApiConsumer().removeImageBackgroundApi(imagePath);

        setState(() {
          imageFileUint8List;
        });
      }
    } catch (errorMsg) {
      print(errorMsg.toString());

      setState(() {
        imageFileUint8List = null;
      });
    }
  }

  chooseImageFromPhoneGallery() async {
    Navigator.pop(context);

    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        String imagePath = pickedImage.path;
        imageFileUint8List = await pickedImage.readAsBytes();

        //remove background from image
        //make image transparent
        imageFileUint8List =
            await ApiConsumer().removeImageBackgroundApi(imagePath);

        setState(() {
          imageFileUint8List;
        });
      }
    } catch (errorMsg) {
      print(errorMsg.toString());

      setState(() {
        imageFileUint8List = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return imageFileUint8List == null ? defaultScreen() : uploadFormScreen();
  }
}
