import 'package:flutter/material.dart';

class AddUpdatePage extends StatelessWidget {
  final bool isEdit;

  const AddUpdatePage({super.key, this.isEdit = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFEFEF),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.chevron_left, size: 28, color: Colors.blue ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        isEdit ? 'Update Product' : 'Add  Product',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: 0,
                    child: Icon(Icons.chevron_left),
                  ),
                ],
              ),
              SizedBox(height: 20),

              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Color(0xFFF4F4F4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_outlined, size: 40),
                      SizedBox(height: 8),
                      Text("upload image"),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              _buildLabeledField("name"),
              SizedBox(height: 12),
              _buildLabeledField("category"),
              SizedBox(height: 12),
              _buildLabeledField("price", suffix: Icon(Icons.attach_money)),
              SizedBox(height: 12),
              _buildLabeledField("description", isMultiline: true),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text("ADD", style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text("DELETE"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabeledField(String label, {bool isMultiline = false, Widget? suffix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFFF4F4F4),
            borderRadius: BorderRadius.circular(6),
          ),
          child: TextField(
            maxLines: isMultiline ? 4 : 1,
            decoration: InputDecoration(
              border: InputBorder.none,
              suffixIcon: suffix,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ),
      ],
    );
  }
}
