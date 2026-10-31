import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  bool loading = false;
  List data = [];

  final Dio dio = Dio();

  getData() async {
    setState(() {
      loading = true;
    });

    try {
      var response =
          await dio.get('https://jsonplaceholder.typicode.com/posts');

      if (response.statusCode == 200) {
        var responsebody = response.data;

        setState(() {
          data.clear();
          data.addAll(responsebody);
        });
      }
    } on DioError catch (e) {
      print(e.message);
    } finally {
      setState(() {
        loading = false;
      });
    }

    setState(() {
      loading = false;
    });
  }

  postData(String title, String body, String userId) async {
    try {
      var response = await dio.post(
        'https://jsonplaceholder.typicode.com/posts',
        data: {
          'title': title,
          'body': body,
          'userId': userId,
        },
      );

      if (response.statusCode == 201) {
        var responsebody = response.data;

        setState(() {
          data.insert(0, responsebody);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post Added Successfully'),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  addPostDialog() {
    TextEditingController title = TextEditingController();
    TextEditingController body = TextEditingController();
    TextEditingController userId = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Post'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: title,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: body,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Body',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: userId,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'User ID',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (title.text.isNotEmpty &&
                    body.text.isNotEmpty &&
                    userId.text.isNotEmpty) {
                  postData(
                    title.text,
                    body.text,
                    userId.text,
                  );

                  Navigator.pop(context);
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  deleteData(int id, int index) async {
    try {
      var response = await dio.delete(
        'https://jsonplaceholder.typicode.com/posts/$id',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          data.removeAt(index);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post Deleted Successfully'),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Homepage',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 10,
            ),
            child: MaterialButton(
              onPressed: getData,
              color: Colors.blue,
              textColor: Colors.white,
              child: const Text('GET Request'),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 30,
            ),
            child: MaterialButton(
              onPressed: addPostDialog,
              color: Colors.green,
              textColor: Colors.white,
              child: const Text('POST Request'),
            ),
          ),
          if (loading)
            const Padding(
              padding: EdgeInsets.all(15),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ...List.generate(
            data.length,
            (index) {
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                child: ListTile(
                  title: Text(
                    '${data[index]['title']}',
                  ),
                  subtitle: Text(
                    '${data[index]['body']}',
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      deleteData(
                        data[index]['id'],
                        index,
                      );
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
