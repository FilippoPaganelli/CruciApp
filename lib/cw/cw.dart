import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter/services.dart';

class CWPage extends StatefulWidget {
  final String thisCW;

  CWPage(this.thisCW);

  @override
  _CWPageState createState() => new _CWPageState(thisCW);
}

class _CWPageState extends State<CWPage> {
  String thisCW;
  bool isVertical = false;
  int lastTapped = -1;
  Map<int, String> userInputs = Map();

  final FocusScopeNode _node = FocusScopeNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

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
                            return FocusScope(
                                node: _node,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: sol[index] == '-'
                                          ? Color.fromRGBO(45, 91, 166, 1)
                                          : Colors.white,
                                      border: Border.all(color: Colors.black)),
                                  child: sol[index] == '-'
                                      ? Text('')
                                      : TextField(
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(1),
                                          ],
                                          cursorWidth: 5,
                                          textAlign: TextAlign.center,
                                          decoration: InputDecoration(
                                              contentPadding: EdgeInsets.all(0),
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(0)),
                                                  borderSide: BorderSide(
                                                      color:
                                                          Colors.grey[600]))),
                                          cursorColor: Colors.black,
                                          textAlignVertical:
                                              TextAlignVertical.center,
                                          style: TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                              decoration: TextDecoration.none),
                                          onTap: () {
                                            if (lastTapped == index) {
                                              isVertical = !isVertical;
                                            }
                                            lastTapped = index;
                                          },
                                          onChanged: (text) {
                                            userInputs[index] = text;
                                            if (text.isEmpty) {
                                              userInputs.remove(index);
                                            } else {
                                              isVertical == false
                                                  ? _node.focusInDirection(
                                                      TraversalDirection.right)
                                                  : _node.focusInDirection(
                                                      TraversalDirection.down);
                                            }
                                          },
                                        ),
                                ));
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

  void _inputChange(String text) {
    print(text);
  }
}
