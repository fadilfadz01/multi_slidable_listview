# multi_slidable_listview
A Flutter widget that enables multi-item slide actions in a ListView, allowing users to swipe and dismiss multiple items at once with customizable actions.

<img src="https://raw.githubusercontent.com/fadilfadz01/multi_slidable_listview/main/example/images/demo.gif" width="291" height="600" alt="Demo">

*❤️ Like this package? Give it a star to show your support!*

## Getting started
To use this package, add `multi_slidable_listview` as a dependency in your pubspec.yaml file.

## Usage
Example 1:
```dart
MultiSlidableListview(
  children: [
    ListTile(
      tileColor: Colors.teal.shade300,
      title: Text('Item 1'),
      subtitle: Text('Swipe here horizontally'),
    ),
    Container(
      color: Colors.teal.shade300,
      child: Column(children: [Text('Item 2'), Text('Swipe here horizontally')]),
    ),
  ],
  rightSlideAction: (slidedItemsIndices) {},
  leftSlideAction: (slidedItemsIndices) {},
),
```

Example 2:
```dart
List<Widget> items = List.generate(
  20,
  (index) => ListTile(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    tileColor: Colors.teal.shade300,
    title: Text('Item $index'),
    subtitle: Text('Swipe here horizontally'),
  ),
);

MultiSlidableListview.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => items[index],
  rightSlideAction: (slidedItemsIndices) {
    setState(() {
      slidedItemsIndices
        ..sort((a, b) => b.compareTo(a))
        ..forEach((index) {
          if (index >= 0 && index < items.length) {
            items.removeAt(index);
          }
        });
    });
  },
  leftSlideAction: (slidedItemsIndices) {},
  rightSlideColor: Colors.red,
  leftSlideColor: Colors.green,
  rightSlideIcon: Icon(Icons.delete, color: Colors.white, size: 30),
  leftSlideIcon: Icon(Icons.archive, color: Colors.white, size: 30),
  sliderBorderRadius: 16,
  contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 2),
),
```
