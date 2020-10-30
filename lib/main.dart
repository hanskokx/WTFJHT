import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
// import 'package:date_format/date_format.dart';

Future<Post> fetchPost() async {
  final res = await http.get('https://wtfjht-40b1c.web.app/api/v1/posts/1378');

  if (res.statusCode == 200) {
    var data = json.decode(res.body);
    var rest = data.toString().splitMapJoin((new RegExp(r'^\{\d+\s?:\s')),
        onMatch: (m) => '', onNonMatch: (n) => n);
    rest = rest.substring(0, rest.length - 1);
    return Post.fromJson(jsonEncode(rest));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load post');
  }
}


// class Date {
//   final String timestamp;

//   Date({this.timestamp});

//   factory Date.fromJson(Map<String, dynamic> json) {
//     return Date(timestamp: json['seconds']);
//   }
// }

class Post {
  final String title;
  final String day;
  // final String date;
  final String description;
  final String image;
  final String todayInOneSentence;
  final String heading;
  final String content;

  Post(
      {this.title,
      this.day,
      // this.date,
      this.description,
      this.image,
      this.todayInOneSentence,
      this.heading,
      this.content});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
        title: json['title'],
        day: json['day'],
        // date: json['date']['_seconds'],
        description: json['description'],
        image: json['image'],
        todayInOneSentence: json['todayInOneSentence'],
        heading: json['heading'],
        content: json['content']);
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'What The Fuck Just Happened Today?'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<Post> futurePost;

  @override
  void initState() {
    super.initState();
    futurePost = fetchPost();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: FutureBuilder<Post>(
          future: futurePost,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Row(children: [
                Text("Here's your post!"),
                Text("Title: " + snapshot.data.title.toString())
              ]);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }

            // By default, show a loading spinner.
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
