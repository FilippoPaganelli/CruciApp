import 'package:flutter/material.dart';
import 'dart:convert';
import 'myBoard.dart';

class CWPage extends StatefulWidget {
  final String thisCW;

  CWPage(this.thisCW);

  @override
  _CWPageState createState() => new _CWPageState(thisCW);
}

class _CWPageState extends State<CWPage> {
  String thisCW;

  _CWPageState(this.thisCW);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //drawer: MyDrawer(),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(55, 101, 176, 1),
        title: Text(
          'Crossword #$thisCW',
          style: TextStyle(
              fontSize: 25, fontWeight: FontWeight.normal, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Row(
            children: [
              ButtonBar(),
            ],
          ),
          Container(
            child: new FutureBuilder(
                future: DefaultAssetBundle.of(context).loadString(
                    "assets/$thisCW/sol.json"), // loads assets for this crossword!
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var sol = json.decode(snapshot.data.toString());
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, top: 10, bottom: 10),
                        child: GridView.count(
                          crossAxisCount: 11, // n° elements in each row!
                          children: List.generate(110, (index) {
                            return Center(
                              child: Text(
                                sol[index].toUpperCase(),
                                style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.normal),
                              ),
                            );
                          }),
                        ),
                      ),
                    );
                  } else
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                }),
          ),
        ],
      ),
    );
  }
}
