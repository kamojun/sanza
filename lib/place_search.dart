import 'package:flutter/material.dart';

import 'data/places.dart';
import 'models/geo.dart';

class PlaceSearch extends SearchDelegate<Place?> {
  // List<int> history = [];
  PlaceSearch() : super(searchFieldLabel: "山や都市を検索");

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<Place> suggestionList = query.isEmpty
        ? []
        : Places.where(
                (m) => m.name.startsWith(query) || m.name2.startsWith(query))
            .toList();
    return ListView.builder(
      itemBuilder: (context, index) {
        var place = suggestionList[index];
        var info = place.info['所属'] ?? place.info['山域'] ?? "";

        return ListTile(
          onTap: () {
            // var idx = Places.indexOf(place);
            // if (history.contains(idx)) history.remove(idx);
            // history.add(idx);
            close(context, place);
          },
          leading: Icon(Icons.location_on),
          title: Text(place.name),
          trailing: Text(info),
        );
      },
      itemCount: suggestionList.length,
    );
  }
}

class SimplePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  SimplePageRoute({required this.page})
      : super(
            pageBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) =>
                page);
}
