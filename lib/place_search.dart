import 'package:flutter/material.dart';

import 'data/places.dart';
import 'models/geo.dart';

class PlaceSearch extends SearchDelegate<Place> {
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
        close(context, Places[0]);
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
          onTap: () => close(context, place),
          leading: Icon(Icons.location_on),
          title: Text(place.name),
          trailing: Text(info),
        );
      },
      itemCount: suggestionList.length,
    );
  }
}
