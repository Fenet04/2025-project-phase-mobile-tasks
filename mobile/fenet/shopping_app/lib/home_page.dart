import 'package:flutter/material.dart';
import 'details_page.dart';
import 'add_update_page.dart';
import 'search_page.dart';

class HomePage extends StatelessWidget {
  final List<Map<String, dynamic>> products = [
    {
      "name": "Polene Cyme bag",
      "price": 540,
      "category": "Women's bag",
      "rating": 5.0,
      "image": "assets/polene-3.webp",
      "description": "A leather sculptured tote bag. A leather sculptured tote bag. A leather sculptured tote bag. A leather sculptured tote bag. A leather sculptured tote bag. A leather sculptured tote bag. A leather sculptured tote bag. A leather sculptured tote bag. A leather sculptured tote bag. A leather sculptured tote bag. A leather sculptured tote bag. A leather sculptured tote bag. A leather sculptured tote bag. A leather sculptured tote bag. A leather sculptured tote bag. A leather sculptured tote bag. A leather sculptured tote bag. A leather sculptured tote bag. A leather sculptured tote bag.",
      "size": ["S","M","L","XL"]
    },
    {
      "name":"Longchamp bag",
      "price": 225,
      "category": "Women's bag",
      "rating": 4.5,
      "image": "assets/longchamp.png",
      "description": "A foldable spacious women's bag",
      "size": ["S","M","L","XL"]
    },
    {
      "name":"Mesenger bag",
      "price": 80,
      "category":"Women's bag",
      "rating": 4.2,
      "image": "assets/messenger.jpg",
      "description": "An easy throw on unisex bag",
      "size": ["S","M","L","XL"]
    },
  ];

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body:Center(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 20,horizontal: 10),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.rectangle,
                        ),
                      ),
                      SizedBox(width:12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("July 20, 2025", style: TextStyle(color: Colors.grey)),
                          Text("Hello, Fenet", style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  Icon(Icons.notifications_none),
                ],
              ),
              SizedBox(height:24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Available Products", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_)=> SearchPage(products: products)),);
                    },
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.search,size: 20),
                    ),
                  ),
                ],
              ),
              SizedBox(height:16),            
              Expanded(
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final p =products[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (_)=>DetailsPage(product:p)),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color:Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 6,
                              spreadRadius: 2,
                           )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              p["image"],
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                          ),
                          Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(p["name"], style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text("\$${p["price"]}",style:TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                SizedBox(height:4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(p["category"], style: TextStyle(color:Colors.grey)),
                                    Row(
                                      children: [
                                        Icon(Icons.star, size: 16, color: Colors.amber),
                                        SizedBox(width:4),
                                        Text("(${p["rating"]})"),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      ),
                  );  
                },
              ),
            ),
          ],
        ),
      ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
          ),
          constraints: BoxConstraints.expand(),
          child: Icon(Icons.add, color: Colors.white),
        ),
        onPressed: () {
          Navigator.push(context,MaterialPageRoute(builder: (_)=> AddUpdatePage()),);
        },
      ),
    );
  }
}