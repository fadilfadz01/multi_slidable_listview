import 'package:flutter/material.dart';
import 'package:multi_slidable_listview/multi_slidable_listview.dart';

void main(List<String> args) => runApp(MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Widget> items = List.generate(
    20,
    (index) => ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      tileColor: Colors.teal.shade300,
      title: Text('Item $index'),
      subtitle: Text('Swipe here horizontally'),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.amber,
        appBar: AppBar(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          title: Text('Multi Slidable Listview'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: MultiSlidableListview.builder(
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
        ),
      ),
    );
  }
}
