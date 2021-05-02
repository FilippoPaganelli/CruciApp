/*import 'package:flutter/material.dart';

class MyBoard extends StatefulWidget {
  final String thisCW;
  MyBoard(this.thisCW);
  @override
  _MyBoardState createState() => _MyBoardState(thisCW);
}

class _MyBoardState extends State<MyBoard> {
  final String thisCW;
  _MyBoardState(this.thisCW);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(builder: (context, snapshot)){return Expanded(
      child: GridView.count(
        // crossAxisCount is the number of columns
        crossAxisCount: 10,
        // This creates two columns with two items in each column
        children: List.generate(110, (index) {
          return Center(
            child: Text(
              '$index',
            ),
          );
        }),
      ),
    );};
  }
}
*/
