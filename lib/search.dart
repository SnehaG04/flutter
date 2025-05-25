import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'newsview.dart';

class SearchNewsPage extends StatefulWidget {
  final String query;
  const SearchNewsPage({super.key, required this.query});

  @override
  State<SearchNewsPage> createState() => _SearchNewsPageState();
}

class _SearchNewsPageState extends State<SearchNewsPage> {
  List articles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSearchResults();
  }

  Future<void> fetchSearchResults() async {
    try {
      String url =
          "https://newsapi.org/v2/everything?q=${widget.query}&sortBy=publishedAt&apiKey=79f816fb693e4a1cbedbda47b40f5ba1";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          articles = data['articles'] ?? [];
          isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch search results");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Results for '${widget.query}'")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : articles.isEmpty
          ? Center(child: Text("No news found"))
          : ListView.builder(
        itemCount: articles.length,
        itemBuilder: (context, index) {
          var article = articles[index];
          return InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=> WebViewPage(url: article['url'])));
            },
            child: Card(
              margin: EdgeInsets.all(10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (article['urlToImage'] != null)
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                      child: Image.network(article['urlToImage'], fit: BoxFit.cover, height: 200, width: double.infinity),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article['title'] ?? "No Title",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text(article['description'] ?? "No Description"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
