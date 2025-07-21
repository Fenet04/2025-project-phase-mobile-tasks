import 'package:flutter/material.dart';

class DetailsPage extends StatefulWidget {
  final Map<String, dynamic> product;

  DetailsPage({required this.product});

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  String selectedSize = 'M';

  @override
  Widget build(BuildContext context) {
    final List<String> sizes = widget.product["size"].cast<String>();

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                  image: DecorationImage(
                    image: AssetImage(widget.product["image"]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 40,
                left: 16,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.chevron_left, size: 28, color: Colors.blue),
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              child: ListView(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.product["category"],
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          SizedBox(width: 4),
                          Text("(${widget.product["rating"]})"),
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.product["name"],
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "\$${widget.product["price"]}",
                        style: TextStyle(fontSize: 18),
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  Text("Size:", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: sizes.map((size) {
                      bool isSelected = selectedSize == size;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedSize = size;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              size,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  Text(
                    widget.product["description"],
                    style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                  ),
                  SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.red),
                            padding: EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text("DELETE", style: TextStyle(color: Colors.red)),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text("UPDATE"),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
