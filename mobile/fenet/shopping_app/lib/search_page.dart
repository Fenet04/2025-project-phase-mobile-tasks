import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  final List<Map<String, dynamic>> products;

  SearchPage({required this.products});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String searchText = '';
  double minPrice = 0;
  double maxPrice = 1000;
  RangeValues selectedRange = RangeValues(0, 500);
  TextEditingController categoryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filtered = widget.products.where((product) {
      final nameMatch = product["name"]
          .toLowerCase()
          .contains(searchText.toLowerCase());
      final categoryMatch = categoryController.text.isEmpty ||
          product["category"]
              .toLowerCase()
              .contains(categoryController.text.toLowerCase());
      final price = product["price"]?.toDouble() ?? 0.0;
      final priceMatch = price >= selectedRange.start && price <= selectedRange.end;
      return nameMatch && categoryMatch && priceMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: 28, color: Colors.blue ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Search Product",
          style: TextStyle(color: Colors.black),
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Search",
                              contentPadding: EdgeInsets.symmetric(horizontal: 12),
                              border: InputBorder.none,
                            ),
                            onChanged: (value) {
                              setState(() {
                                searchText = value;
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_forward, color: Colors.blue),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.filter_list, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final p = filtered[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          p["image"],
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      p["name"],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "\$${p["price"]}",
                                    style: TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
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
                                ]
                              ),    
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Align(
              alignment: Alignment.centerLeft,
              child: Text("Category"),
            ),
            SizedBox(height: 4),
            TextField(
              controller: categoryController,
              decoration: InputDecoration(
                hintText: "Enter category",
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            SizedBox(height: 12),

            Align(
              alignment: Alignment.centerLeft,
              child: Text("Price"),
            ),
            RangeSlider(
              values: selectedRange,
              min: minPrice,
              max: maxPrice,
              activeColor: Colors.blue,
              inactiveColor: Colors.blue.shade100,
              divisions: 50,
              labels: RangeLabels(
                "\$${selectedRange.start.toInt()}",
                "\$${selectedRange.end.toInt()}",
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  selectedRange = values;
                });
              },
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text("APPLY", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
