import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TopNewsPage extends StatefulWidget {
  @override
  _TopNewsPageState createState() => _TopNewsPageState();
}

class _TopNewsPageState extends State<TopNewsPage> {
  List articles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTopNews();
  }

  Future<void> fetchTopNews() async {
    try {
      String url = "https://newsapi.org/v2/everything?q=top-headlines&from=2025-05-01&sortBy=publishedAt&apiKey=79f816fb693e4a1cbedbda47b40f5ba1";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          articles = data['articles'] ?? [];
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load news");
      }
    } catch (e) {
      print("Error fetching top news: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Top News"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : articles.isEmpty
          ? Center(child: Text("No news available"))
          : ListView.builder(
        itemCount: articles.length,
        itemBuilder: (context, index) {
          var article = articles[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                article['urlToImage'] != null
                    ? ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                    child: Image.network(article['urlToImage'], fit: BoxFit.cover, width: double.infinity, height: 200))
                    : SizedBox(),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(article['title'] ?? 'No Title',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Text(article['description'] ?? 'No Description'),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
