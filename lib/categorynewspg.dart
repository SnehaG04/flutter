
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'newsview.dart';

class CategoryNewsPage extends StatefulWidget {
  final String category;
  const CategoryNewsPage({super.key, required this.category});

  @override
  State<CategoryNewsPage> createState() => _CategoryNewsPageState();
}

class _CategoryNewsPageState extends State<CategoryNewsPage> {
  List articles = [];
  bool isLoading = true;

  final List<String> validTopHeadlineCategories = [
    'Top News', 'India', 'Finance', 'Health', 'Politics', 'Sports'
  ];

  @override
  void initState() {
    super.initState();
    fetchCategoryNews();
  }





  Future<void> fetchCategoryNews() async {
    setState(() => isLoading = true);

    try {
      String apiKey = "79f816fb693e4a1cbedbda47b40f5ba1";
      String category = widget.category.toLowerCase();
      String url = "https://newsapi.org/v2/top-headlines/sources?category=$category&apiKey=$apiKey";

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        setState(() {
          articles = data['sources'] ?? [];
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load sources");
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category, style: TextStyle(fontWeight: FontWeight.bold))),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : articles.isEmpty
          ? Center(child: Text("No news available"))
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
