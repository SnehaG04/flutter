import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'package:news1/newsview.dart';
import 'package:news1/search.dart';

import 'categorynewspg.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController searchController = TextEditingController();
  List articles = [];
  List carouselArticles = [];
  bool isLoading = true;
  bool isCarouselLoading = true;
  double _rating = 0.0;


  @override
  void initState() {
    super.initState();
    fetchNews();
    fetchCarouselNews();// Fetch news on startup
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Rate Us"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 32.0,
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            SizedBox(height: 10),
            Text('Your Rating: $_rating'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }


  Future<void> fetchNews() async {
    try {
      String url = "https://newsapi.org/v2/top-headlines?sources=techcrunch&apiKey=79f816fb693e4a1cbedbda47b40f5ba1";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          articles = data['articles'] ?? [];
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load news. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching news: $e");
      setState(() {
        isLoading = false;
      });
    }
  }


  Future<void> fetchCarouselNews() async {
    try {
      String url = "https://newsapi.org/v2/everything?domains=techcrunch.com,thenextweb.com&apiKey=79f816fb693e4a1cbedbda47b40f5ba1";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          carouselArticles = data['articles'] ?? [];
          isCarouselLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isCarouselLoading = false;
      });
    }
  }

  List<String> navBarItem = [
    'Top News', 'India', 'Finance', 'Health', 'Politics', 'Sports'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BULLETIN FEED', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        // leading: IconButton(
        //   icon: Icon(Icons.star_rate, color: Colors.amber),
        //   tooltip: "Rate Us",
        //   onPressed: _showRatingDialog,
        // ),
        leading: Padding(
          padding: const EdgeInsets.all(6.0),
          child: ElevatedButton(
            onPressed: _showRatingDialog,
            child: Text("Rate Us", style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 8),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ),


      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search Bar
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                  color: Colors.black12, borderRadius: BorderRadius.circular(35)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push((context), MaterialPageRoute(builder: (context)=>SearchNewsPage(query: searchController.text)));

                        // print("Search: ${searchController.text}");
                      },
                      child: Container(
                        padding: EdgeInsets.fromLTRB(2, 0, 5, 0),
                        child: Icon(Icons.search, color: Colors.blueAccent),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (value) {
                          Navigator.push((context), MaterialPageRoute(builder: (context)=>SearchNewsPage(query: value)));

                        },
                        decoration: InputDecoration(
                            hintText: 'Search for the News', border: InputBorder.none),
                      ),
                    )
                  ],
                ),
              ),
            ),

            // Navigation Categories
            SizedBox(
              height: 60,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: navBarItem.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      String selectedCategory = navBarItem[index];
                      setState(() {
                        searchController.text = selectedCategory;
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchNewsPage(query: selectedCategory),
                        ),
                      );
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => CategoryNewsPage(category: navBarItem[index]),
                      //   ),
                      // );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          navBarItem[index],
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // // Image Slider (Static)
            // Container(
            //   margin: EdgeInsets.symmetric(vertical: 15),
            //   child: CarouselSlider(
            //       items: items.map((item) {
            //         return Builder(builder: (BuildContext context) {
            //           return Container(
            //             child: Card(
            //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            //               child: Stack(
            //                 children: [
            //                   ClipRRect(
            //                     borderRadius: BorderRadius.circular(30),
            //                     child: Image.asset(
            //                       'images/isnews.jpg',
            //                       fit: BoxFit.fitHeight,
            //                       height: double.infinity,
            //                     ),
            //                   ),
            //                   Positioned(
            //                     left: 0, right: 0, bottom: 0,
            //                     child: Container(
            //                       decoration: BoxDecoration(
            //                           borderRadius: BorderRadius.circular(30),
            //                           gradient: LinearGradient(
            //                               colors: [Colors.black12, Colors.black],
            //                               begin: Alignment.topCenter,
            //                               end: Alignment.bottomCenter)),
            //                       child: Padding(
            //                         padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 17),
            //                         child: Text(
            //                           'News Headline',
            //                           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            //                         ),
            //                       ),
            //                     ),
            //                   )
            //                 ],
            //               ),
            //             ),
            //           );
            //         });
            //       }).toList(),
            //       options: CarouselOptions(
            //         height: 200,
            //         autoPlay: true,
            //         enlargeCenterPage: true,
            //       )),
            // ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 15),
              child: isCarouselLoading
                  ? Center(child: CircularProgressIndicator())
                  : carouselArticles.isEmpty
                  ? Center(child: Text("No news available"))
                  : CarouselSlider(
                items: carouselArticles.map((article) {
                  return Builder(builder: (BuildContext context) {
                    return Container(
                      child: InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> WebViewPage(url: article['url'])));
                          // Navigator.push(context, MaterialPageRoute(builder: (context)=>WebViewPage(url: article['url']),));

                        },

                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: article['urlToImage'] != null
                                    ? Image.network(
                                  article['urlToImage'],
                                  fit: BoxFit.cover,
                                  height: double.infinity,
                                  width: double.infinity,
                                )
                                    : Image.asset(
                                  'images/isnews.jpg',
                                  fit: BoxFit.cover,
                                  height: double.infinity,
                                  width: double.infinity,
                                ),
                              ),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    gradient: LinearGradient(
                                      colors: [Colors.black12, Colors.black],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 17),
                                    child: Text(
                                      article['title'] ?? 'No Title',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  });
                }).toList(),
                options: CarouselOptions(
                  height: 200,
                  autoPlay: true,
                  enlargeCenterPage: true,
                ),
              ),
            ),

            // Latest News Section (TechCrunch API)
            Container(
              margin: EdgeInsets.fromLTRB(15, 20, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Latest News',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 28),
                  ),
                ],
              ),
            ),

            isLoading
                ? Center(child: CircularProgressIndicator())
                : articles.isEmpty
                ? Center(child: Text("No news available"))
                : ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  var article = articles[index];
                  return InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> WebViewPage(url: article['url'])));
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 1.5,
                        child: Stack(
                          children: [
                            // News Image (with null check)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: article['urlToImage'] != null
                                  ? Image.network(article['urlToImage'], fit: BoxFit.cover, height: 230, width: double.infinity)
                                  : Image.asset('images/isnews.jpg', fit: BoxFit.cover, height: 230, width: double.infinity),
                            ),
                            Positioned(
                              left: 5, right: 0, bottom: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    gradient: LinearGradient(
                                        colors: [Colors.black12, Colors.black],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter)),
                                padding: EdgeInsets.symmetric(horizontal: 17, vertical: 17),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      article['title'] ?? 'No Title',
                                      style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      article['description'] ?? 'No Description',
                                      style: TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

            // Show More Button
            Container(
              padding: EdgeInsets.fromLTRB(0, 7, 0, 10),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>CategoryNewsPage(category: 'Business'),));
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlueAccent),
                child: Text('SHOW MORE', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  final List items = [Colors.blueAccent, Colors.green, Colors.pink, Colors.red, Colors.orange, Colors.purple];
}
