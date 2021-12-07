import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MicroCMS Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'Photo Gallery'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Photo> items = [];
  Photo? showingPhoto;

  @override
  void initState() {
    _loadListItem();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var list = items.map((item) => _photoNetworkItem(item)).toList();

    var grid = GridView.count(
        crossAxisCount: 6,
        children: list
    );
    var rows = Container(child: Column(
      children: list,
    ));
    return Scaffold(
        appBar: null,
        body: Stack(
          alignment: Alignment.center,
          children: [SingleChildScrollView(child: Container(child: rows,
            padding: EdgeInsets.only(top: 128),
            color: Colors.black,
            alignment: Alignment.center,
          ),
          ),
            if (showingPhoto != null) _expantionItem(showingPhoto!),
          ],
        )
    );
  }

  Widget _expantionItem(Photo photo) {
    return GestureDetector(child: Container(child:
    Column(children: [
      Image.network(photo.photo.toString(),
          fit: BoxFit.fitWidth,
          width: 540),
      const SizedBox(height: 24),
      Text(photo.caption, style: TextStyle(
        // fontWeight: FontWeight.bold,
        fontSize: 14,
        color: Colors.white,
      ),
      ),
    ],
    ),
        color: Colors.black87,
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: 256)
    ),
      onTap: () {
        setState(() {
          showingPhoto = null;
        });
      },
    );
  }

  Widget _photoNetworkItem(Photo photo) {
    return
      GestureDetector(child:
      Padding(child:
      Column(children: [
        Image.network(photo.photo.toString(),
            fit: BoxFit.fitWidth,
            width: 320),
        const SizedBox(height: 16),
        Text(photo.caption, style: TextStyle(
          // fontWeight: FontWeight.bold,
          fontSize: 12,
          color: Colors.white,
        ),
        ),
      ],
      ),
        padding: EdgeInsets.only(bottom: 72),
      ),
          onTap: () {
            setState(() {
              showingPhoto = photo;
            });
          }
      );
  }

  void _loadListItem() async {
    var url = Uri.parse("https://himaratsu-photos.microcms.io/api/v1/photos");
    final result = await http.get(
        url,
        headers: {
          "X-MICROCMS-API-KEY": '36a41bef898f45ec95f0cf882d9fd7a933c4'
        });
    var contents = json.decode(result.body)["contents"];
    //     .map((content) => content["photo"]["url"]).toList();
    // var newItems = List<String>.from(items);

    var myContents = contents.map((content) => Photo.fromJSON(content)).toList();
    var newItems = List<Photo>.from(myContents);

    setState(() {
      items = newItems;
    });
  }
}

class Photo {
  final String id;
  final String caption;
  final DateTime publishedAt;
  final Uri photo;

  Photo.fromJSON(Map<String, dynamic> json)
      : id = json['id'],
        caption = json['caption'],
        publishedAt = DateTime.parse(json['publishedAt']),
        photo = Uri.parse(json['photo']['url']);
}