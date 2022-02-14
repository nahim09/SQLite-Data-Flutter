import 'package:flutter/material.dart';
import 'package:sqlite/database/sqlite_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _dataList = [];

  getAllData() async {
    var list = await SQLHelper.getAllData();
    setState(() {
      _dataList = list;
    });
  }

  addItem(int? id, String? title, String? description) {
    TextEditingController titleController = TextEditingController();
    TextEditingController desController = TextEditingController();

    if (id != null) {
      titleController.text = title!;
      desController.text = description!;
    }

    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(hintText: "Title"),
                ),
                TextField(
                  controller: desController,
                  decoration: const InputDecoration(hintText: "Description"),
                ),
                ElevatedButton(
                    onPressed: () {
                      var title = titleController.text.toString();
                      var des = desController.text.toString();

                      if (id == null) {
                        SQLHelper.insertData(title, des).then((value) => {
                              if (value != -1)
                                {
                                  //print("value inserted")
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              "Data inserted Succesfully"))),
                                  
                                }
                              else
                                {
                                  // print("Faile to insert")
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text("Faile to insert")))
                                }
                            });
                      }else{
                        SQLHelper.updateData(id,title,des);
                      }

                      Navigator.of(context).pop(context);
                      getAllData();
                    },
                    child:
                        id == null ? Text("Insert Data") : Text("Update Data")),
              ],
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    getAllData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: const Text("SQLite Data"),
            centerTitle: true,
          ),
          body: _dataList.isNotEmpty
              ? ListView.builder(
                  itemCount: _dataList.length,
                  itemBuilder: (context, position) {
                    return ListTile(
                      title: Text(_dataList[position]["title"].toString()),
                      subtitle:
                          Text(_dataList[position]["description"].toString()),
                      trailing: Wrap(
                        spacing: 20,
                        children: [
                          GestureDetector(
                              onTap: () {
                                addItem(
                                    _dataList[position]["id"],
                                    _dataList[position]["title"].toString(),
                                    _dataList[position]["description"]
                                        .toString());
                              },
                              child: Icon(Icons.edit)),
                          GestureDetector(
                              onTap: () {
                                SQLHelper.deleteData(_dataList[position]["id"]);
                                getAllData();

                                // ScaffoldMessenger.of(context).showSnackBar(
                                //           const SnackBar(
                                //               content:
                                //                   Text("Data inserted Succesfully")));
                              },
                              child: const Icon(Icons.delete))
                        ],
                      ),
                    );
                  })
              : const Center(
                  child: Text("No Data Found"),
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              addItem(null, null, null);
            },
            child: const Icon(Icons.add),
          )),
    );
  }
}
