import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      height: 35,
      width: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade200,
      ),
      child: Row(
        children: [
          SizedBox(width: 5),
          Icon(Icons.search_rounded, color: Colors.grey.shade500),
          Text(
            "山や都市を検索",
            style: TextStyle(
              decoration: TextDecoration.none,
              fontSize: 18,
              fontWeight: FontWeight.w100,
              color: Colors.grey.shade500,
            ),
          )
        ],
      ),
    );
  }
}
