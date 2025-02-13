import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:realidadeaumentada/item_ui_design_widget.dart';
import 'package:realidadeaumentada/items.dart';
import 'package:realidadeaumentada/items_upload_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.purple,
          title: const Text(
            'iKEA AR ',
            style: TextStyle(color: Colors.white),
          ),
          leading: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => ItemsUploadScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.add,
                  color: Colors.white,
                ))
          ],
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("items")
              .orderBy("publishedDate", descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot dataSnapshot) {
            if (dataSnapshot.hasData) {
              return ListView.builder(
                itemCount: dataSnapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  Items eachItemInfo = Items.fromJson(
                      dataSnapshot.data!.docs[index].data()
                          as Map<String, dynamic>);
                  return ItemUIDesignWidget(
                    itemsInfo: eachItemInfo,
                  );
                },
              );
            } else {
              return const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      "Data is not available.",
                      style: TextStyle(fontSize: 30, color: Colors.grey),
                    ),
                  )
                ],
              );
            }
          },
        ));
  }
}
