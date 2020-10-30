import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

// List<Post> parsePosts(String responseBody) {
//   final parsed = jsonDecode(responseBody);
//   return parsed.map<Post>((json) => Post.fromJson(json)).toList();
// }

Future<List<Post>> fetchPost(day) async {
  final snapshot = await http
      .get('https://wtfjht-40b1c.web.app/api/v1/posts/' + day.toString());

  if (snapshot.statusCode == 200) {
    Map<dynamic, dynamic> values = jsonDecode(snapshot.body);
    var res = [];
    values.forEach((key, values) {
      final val = jsonDecode(jsonEncode(values));
      res.add(val);
    });

    List<Post> list =
        res.isNotEmpty ? res.map((c) => Post.fromJson(c)).toList() : [];

    return list;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load post');
  }
}

class Post {
  final String title;
  final String day;
  final DateTime date;
  final String description;
  final String image;
  final String todayInOneSentence;
  final String heading;
  final String content;

  Post(
      {this.title,
      this.day,
      this.date,
      this.description,
      this.image,
      this.todayInOneSentence,
      this.heading,
      this.content});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
        title: json['title'],
        day: json['day'],
        date: DateTime.fromMicrosecondsSinceEpoch(json['date']['_seconds']),
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
  Future<List<Post>> futurePost;

  @override
  void initState() {
    super.initState();
    futurePost = fetchPost("1378");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: FutureBuilder<List<Post>>(
          future: futurePost,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var post = snapshot.data.first;
              var title = post.title;
              var day = post.day;
              var date = post.date;
              var description = post.description;
              var image = post.image;
              var todayInOneSentence = post.todayInOneSentence;
              var heading = post.heading;
              var content = post.content;
              return ListView(
                  padding: const EdgeInsets.all(10.0),
                  children: <Widget> [
                    Column(children: [
                      Wrap(children: [
                        // Title
                        MarkdownBody(data: title),
                        Text(" "),
                        MarkdownBody(data: description)
                      ]),
                      Wrap(children: [MarkdownBody(data: todayInOneSentence)]),
                      Wrap(
                        children: [MarkdownBody(data: content)],
                      )
                    ])
                  ]
                  );
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
