import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
// import 'dart:html' as html;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '🎞 hims Films',
      theme: ThemeData.dark(),
      home: const MyHomePage(title: 'hims films'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  List<Photo> photos = [];
  Photo? showingPhoto;
  bool switchPhotoContextOpen = true;
  Photo? hoverPhoto;

  String selectedCategory = "Kyoto";

  late AnimationController _animationController;

  @override
  void initState() {
    _fetch();

    _animationController = AnimationController(
        duration: const Duration(milliseconds: 230), vsync: this);

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var isSmallDevice = width <= 500;

    List<Widget> list =
        photos.map((item) => _simplePhotoNetworkItem(item)).toList();
    var grid = GridView.extent(
        maxCrossAxisExtent: 132,
        padding: const EdgeInsets.all(4),
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        children: list);

    var dropdown = DropdownButton<String>(
      dropdownColor: Colors.black87,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.white,
      ),
      value: selectedCategory,
      items: <String>['Kyoto', 'Kobe', 'Ito', 'Other'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              )),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedCategory = value!;
        });
        _fetch();
      },
    );
    var header = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.ideographic,
      children: [
        const Text(
          "Photo of ",
          style: TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(width: 8),
        dropdown
      ],
    );

    var column = Column(
      children: [
        SizedBox(height: isSmallDevice ? 40 : 96),
        // dropdown,
        header,
        SizedBox(height: isSmallDevice ? 32 : 72),
        Expanded(child: grid),
        const SizedBox(height: 32),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            child: Container(
              child: const FaIcon(
                FontAwesomeIcons.twitter,
                color: Colors.white,
                size: 24,
              ),
              padding: const EdgeInsets.only(bottom: 32),
            ),
            onTap: () {
              // html.window.open('https://twitter.com/himara2', 'new tab');
            },
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: null,
      body: Stack(children: [
        Container(
          alignment: Alignment.center,
          child: SizedBox(width: 720, child: column),
        ),
        if (showingPhoto != null) _expansionItem(showingPhoto!, context),
      ]),
      backgroundColor: Colors.black.withOpacity(0.92),
    );
  }

  Widget _simplePhotoNetworkItem(Photo photo) {
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
        child: Transform.scale(
          scale: 1.0,
          child: Opacity(
            opacity: photo == hoverPhoto ? 0.6 : 1.0,
            child: Image.network(
              photo.getImageUrl(320),
              fit: BoxFit.cover,
              width: 320,
            ),
          ),
        ),
        onTap: () {
          switchPhotoContextOpen = true;
          setState(
            () {
              showingPhoto = photo;
            },
          );
        },
      ),
    );
  }

  Widget _expansionItem(Photo photo, BuildContext context) {
    int duration = switchPhotoContextOpen ? 230 : 0;
    _animationController = AnimationController(
        duration: Duration(milliseconds: duration), vsync: this);

    final animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward(from: 0.0);

    double width = 720;
    double height = (width * 4160 / 6240);
    return AnimatedBuilder(
      animation: _animationController,
      builder: (BuildContext context, Widget? child) {
        return Positioned.fill(
          child: GestureDetector(
            child: FadeTransition(
              opacity: animation,
              child: Container(
                color: Colors.black.withOpacity(0.87),
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
                            child: Stack(
                              children: <Widget>[
                                Positioned.fill(
                                  child: Image.network(
                                      photo.getImageUrl(width * 1.5),
                                      fit: BoxFit.cover,
                                      width: width),
                                ),
                                if (_shouldShowPrev())
                                  Positioned.fill(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        color: Colors.grey.withOpacity(0.26),
                                        child: IconButton(
                                          icon: Image.asset(
                                              'images/left_arrow.png',
                                              color: Colors.white),
                                          iconSize: 48,
                                          onPressed: () {
                                            _showPrev();
                                          },
                                        ),
                                        width: 60,
                                        height: 120,
                                      ),
                                    ),
                                  ),
                                if (_shouldShowNext())
                                  Positioned.fill(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        color: Colors.grey.withOpacity(0.26),
                                        child: IconButton(
                                          icon: Image.asset(
                                              'images/right_arrow.png',
                                              color: Colors.white),
                                          iconSize: 48,
                                          onPressed: () {
                                            _showNext();
                                          },
                                        ),
                                        width: 60,
                                        height: 120,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
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
              ), // color: Colors.black.withOpacity(0.9),
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
      },
    );
  }

  void _showPrev() {
    if (showingPhoto != null) {
      var currentIndex = photos.indexOf(showingPhoto!);
      if (currentIndex < 1) {
        return;
      }
      var prevIndex = currentIndex - 1;
      switchPhotoContextOpen = false;
      setState(() {
        showingPhoto = photos[prevIndex];
      });
    }
  }

  void _showNext() {
    if (showingPhoto != null) {
      var currentIndex = photos.indexOf(showingPhoto!);
      if (photos.length <= currentIndex + 1) {
        return;
      }
      var nextIndex = currentIndex + 1;
      switchPhotoContextOpen = false;
      setState(() {
        showingPhoto = photos[nextIndex];
      });
    }
  }

  bool _shouldShowPrev() {
    if (showingPhoto == null) {
      return false;
    }

    var currentIndex = photos.indexOf(showingPhoto!);
    if (currentIndex < 1) {
      return false;
    } else {
      return true;
    }
  }

  bool _shouldShowNext() {
    if (showingPhoto == null) {
      return false;
    }

    var currentIndex = photos.indexOf(showingPhoto!);
    if (photos.length <= currentIndex + 1) {
      return false;
    } else {
      return true;
    }
  }

  void _fetch() async {
    var lowerCategory = selectedCategory.toLowerCase();
    var url = Uri.parse(
        "https://himaratsu-photos.microcms.io/api/v1/photos?limit=50&filters=category%5Bequals%5D$lowerCategory");
    final result = await http.get(url, headers: {
      "X-MICROCMS-API-KEY": '36a41bef898f45ec95f0cf882d9fd7a933c4'
    });
    var contents = json.decode(result.body)["contents"];

    var myContents =
        contents.map((content) => Photo.fromJSON(content)).toList();
    var newItems = List<Photo>.from(myContents);

    setState(() {
      photos = newItems;
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
