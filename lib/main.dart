import 'package:flutter/cupertino.dart';
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
      title: 'Photo Gallery',
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
  Photo? hoverPhoto;

  @override
  void initState() {
    _loadListItem();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [
      const SizedBox(height: 96),
      const SelectableText(
      "Photo by X100V",
      style: TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic),
    ),
    const SizedBox(height: 108)];
    list.addAll(items.map((item) => _photoNetworkItem(item)).toList());

    var grid = GridView.count(crossAxisCount: 6, children: list);
    var rows = Container(
        child: Column(
      children: list,
    ));
    return Scaffold(
        appBar: null,
        body: Stack(
          alignment: Alignment.center,
          children: [
            SingleChildScrollView(
              child: Container(
                child: rows,
                color: Colors.black,
                alignment: Alignment.center,
              ),
            ),
            if (showingPhoto != null) _expantionItem(showingPhoto!, context),
          ],
        ));
  }

  Widget _expantionItem(Photo photo, BuildContext context) {
    double width = 720;
    double height = (width * 4160 / 6240);
    return Positioned.fill(
      child: GestureDetector(
        child: Container(
          child: Align(
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {
                // do nothing
              },
              child: SizedBox(
                height: height + 32 + 40 + 32 + 20, //自分自身の高さ
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border.all(color: Colors.white, width: 8),
                      ),
                      width: width,
                      height: height,
                      child: Image.network(photo.getImageUrl(width),
                          fit: BoxFit.fitWidth, width: width),
                    ),
                    const SizedBox(height: 32),
                    SelectableText(
                      photo.caption,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 48),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          showingPhoto = null;
                        });
                      },
                      child: const Text(
                        "back",
                        style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          color: Colors.black.withOpacity(0.9),
        ),
        // alignment: Alignment.center,
        // padding: EdgeInsets.only(top: 256)),
        onTap: () {
          setState(() {
            showingPhoto = null;
          });
        },
      ),
    );
  }

  Widget _photoNetworkItem(Photo photo) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          hoverPhoto = photo;
        });
      },
      onExit: (_) {
        setState(() {
          hoverPhoto = null;
        });
      },
      child: GestureDetector(
          child: Padding(
            child: Transform.scale(
              scale: hoverPhoto == photo ? 1.1 : 1.0,
              child: Column(
                children: [
                  Image.network(photo.getImageUrl(320),
                      fit: BoxFit.fitWidth, width: 320),
                  const SizedBox(height: 16),
                  SelectableText(
                    photo.caption,
                    style: TextStyle(
                      // fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            padding: EdgeInsets.only(bottom: 72),
          ),
          onTap: () {
            setState(() {
              showingPhoto = photo;
            });
          }),
    );
  }

  void _loadListItem() async {
    var url = Uri.parse("https://himaratsu-photos.microcms.io/api/v1/photos");
    final result = await http.get(url, headers: {
      "X-MICROCMS-API-KEY": '36a41bef898f45ec95f0cf882d9fd7a933c4'
    });
    var contents = json.decode(result.body)["contents"];
    //     .map((content) => content["photo"]["url"]).toList();
    // var newItems = List<String>.from(items);

    var myContents =
        contents.map((content) => Photo.fromJSON(content)).toList();
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

  String getImageUrl(width) {
    return photo.toString() + "?width=$width";
  }
}
