import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'def.dart';

class CWPage extends StatefulWidget {
  final String thisCW;
  final int rows;
  final int cols;

  CWPage(this.thisCW, this.rows, this.cols);

  @override
  _CWPageState createState() => new _CWPageState(thisCW, rows, cols);
}

class _CWPageState extends State<CWPage> {
  bool firstLoading = true;
  final String thisCW;
  final int rows;
  final int cols;
  bool isVertical = false;
  int lastTapped = -1;
  List<String> sol = [];
  List<Definition> def = [];
  Map<String, String> userInputs = Map();
  Map<String, List<int>> words = Map();
  List<TextEditingController> _controllers = [];
  final FocusScopeNode _node = FocusScopeNode();
  String prevDir;
  String prevPath;
  bool prevFileExists = false;
  Color normalCellColor = Colors.amber[50];
  Color highlightedCellColor = Colors.amber[100];
  Map<int, Color> cellsColors = Map(); // init in _loadStuff()
  String shownDef = '';

  @override
  void initState() {
    sol.clear();
    def.clear();
    super.initState();
    _loadDef();
  }

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  _CWPageState(this.thisCW, this.rows, this.cols);

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
          ButtonBar(
            alignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                child: Text(
                  'Save',
                  style: TextStyle(fontSize: 30),
                ),
                onPressed: () {
                  _buttonPress("Save");
                },
              ),
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateColor.resolveWith(
                        (states) => Colors.red[900])),
                child: Text(
                  'Reset',
                  style: TextStyle(fontSize: 30),
                ),
                onPressed: () {
                  _buttonPress("Reset");
                },
              ),
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateColor.resolveWith(
                        (states) => Colors.green[700])),
                child: Text(
                  'Check',
                  style: TextStyle(fontSize: 30),
                ),
                onPressed: () {
                  _buttonPress("Check");
                },
              ),
            ],
          ),
          // definition textbox
          Container(
            padding: EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 0),
            alignment: Alignment.centerLeft,
            child: Text.rich(
              TextSpan(
                style: TextStyle(fontSize: 25),
                children: <TextSpan>[
                  TextSpan(
                      text: 'def: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text: shownDef,
                      style: TextStyle(fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          ),
          Container(
            child: new FutureBuilder(
                future: firstLoading ? _loadStuff() : _getCurrentStuff(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var sol = json.decode(snapshot.data.toString());
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, top: 10, bottom: 10),
                        child: GridView.count(
                          // rows and cols are passed to this page as arguments from "home.dart", through routeGenerator
                          crossAxisCount:
                              cols, // n° elements in each row! a.k.a. "cols" property in "cwinfos.json"!
                          children: List.generate(rows * cols, (index) {
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
                                      : Container(
                                          color: cellsColors[index],
                                          child: TextField(
                                            // set the initial text to previously saved values
                                            controller: _controllers[index]
                                              ..text = userInputs.containsKey(
                                                      index.toString())
                                                  ? userInputs[index.toString()]
                                                  : '',
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            inputFormatters: [
                                              LengthLimitingTextInputFormatter(
                                                  1),
                                            ],
                                            cursorWidth: 4,
                                            cursorRadius: Radius.circular(2),
                                            cursorHeight: 20,
                                            enableInteractiveSelection: false,
                                            textDirection: TextDirection.ltr,
                                            textAlign: TextAlign.center,
                                            decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.all(0),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    0)),
                                                        borderSide: BorderSide(
                                                            color: Colors
                                                                .grey[600]))),
                                            cursorColor: Colors.black,
                                            textAlignVertical:
                                                TextAlignVertical.center,
                                            style: TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                                decoration:
                                                    TextDecoration.none),
                                            onTap: () {
                                              // switches between vertical and horizontal directions
                                              if (lastTapped == index) {
                                                isVertical = !isVertical;
                                              }
                                              lastTapped = index;

                                              // highlight word
                                              _highlightWord(index);
                                            },
                                            onChanged: (text) {
                                              lastTapped =
                                                  -1; // prevents it from flipping direction on previous tap, when auto-jumping to next cell
                                              userInputs[index.toString()] =
                                                  text;
                                              if (text.isEmpty) {
                                                userInputs
                                                    .remove(index.toString());
                                              } else if (text.contains(
                                                  new RegExp(r'[A-Z]'))) {
                                                //print(text);
                                                isVertical == false
                                                    ? _node.focusInDirection(
                                                        TraversalDirection
                                                            .right)
                                                    : _node.focusInDirection(
                                                        TraversalDirection
                                                            .down);
                                              }
                                            },
                                          ),
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
          )
        ],
      ),
    );
  }

  void _buttonPress(String button) {
    switch (button) {
      case "Reset":
        _askForReset();
        break;
      case "Save":
        _saveInputs();
        break;
      case "Check":
        checkInputs();
        break;
    }
  }

  void checkInputs() {
    String msg = '';
    String title = '';
    int right = 0;
    int wrong = 0;
    int missing = 0;
    bool win = false;
    for (int i = 0; i < sol.length; i++) {
      String el = sol[i].toUpperCase();
      if (el != '-') {
        if (userInputs.containsKey(i.toString())) {
          if (userInputs[i.toString()] == el)
            right++;
          else {
            wrong++;
            missing++;
            _controllers[i].text = '_';
          }
        } else
          missing++;
      }
    }
    if (missing == 0) {
      // winning condition
      title = 'Done!';
      msg = "Congratulations.\nThere are no errors!";
    } else {
      title = 'Stats:';
      msg = "Wrong: ${wrong}\nRemaining: ${missing}";
    }
    // notify user about statistics
    AlertDialog alert = AlertDialog(
      title: Text(title, style: TextStyle(fontSize: 35)),
      content: Text(msg, style: TextStyle(fontSize: 25)),
      actions: [
        ElevatedButton(
            onPressed: () {
              if (missing == 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('CW #$thisCW has been completed!',
                        style: TextStyle(fontSize: 23)),
                  ),
                );
              }
              HapticFeedback.vibrate();
              Navigator.of(context).pop();
            },
            child: Text('Ok', style: TextStyle(fontSize: 23))),
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _saveInputs() {
    // only saves status if there are letters on the board
    if (userInputs.isNotEmpty) {
      final writeData = json.encode(userInputs);
      File(prevPath).createSync(recursive: true);
      File prevFile = new File(prevPath);
      prevFile.writeAsString(writeData).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CW #$thisCW has been saved...',
                style: TextStyle(fontSize: 23)),
          ),
        );
        HapticFeedback.vibrate();
      });
    }
    // if there's no letter AND the file exists, remove it to save its status as empty
    else if (prevFileExists) {
      File(prevPath).delete().then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CW #$thisCW has been saved...',
                style: TextStyle(fontSize: 23)),
          ),
        );
        HapticFeedback.vibrate();
      });
    }
    // here the file has never been created and the user wants to save an empty status, thus do nothing
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('CW #$thisCW has never been saved before...',
              style: TextStyle(fontSize: 23)),
        ),
      );
      HapticFeedback.vibrate();
    }
  }

// shows an alert dialog asking for Reset confirmation
  void _askForReset() {
    AlertDialog alert = AlertDialog(
      title: Text("Reset!", style: TextStyle(fontSize: 35)),
      content: Text("Are you sure? Any unsaved changes will be lost.",
          style: TextStyle(fontSize: 25)),
      actions: [
        ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateColor.resolveWith((states) => Colors.white)),
            onPressed: () {
              HapticFeedback.vibrate();
              Navigator.of(context).pop();
            },
            child:
                Text('No', style: TextStyle(fontSize: 23, color: Colors.blue))),
        ElevatedButton(
            onPressed: () {
              setState(() {
                _controllers.forEach((ctrl) {
                  ctrl.text = '';
                });
              });

              setState(() {
                userInputs.clear();
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('CW #$thisCW has been reset...',
                      style: TextStyle(fontSize: 23)),
                ),
              );
              HapticFeedback.vibrate();
              Navigator.of(context).pop();
            },
            child: Text('Yes', style: TextStyle(fontSize: 23))),
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<String> _loadStuff() async {
    firstLoading = false;

    prevDir = await _localPath + "/$thisCW";
    prevPath = prevDir + "/prev.json";

    // check if dir .../thisCW doesn't exist, if so create it
    if (!Directory(prevDir).existsSync()) {
      Directory(prevDir).createSync(recursive: true);
    }

    // check if file exists, if so load last letters saved
    if (File(prevPath).existsSync()) {
      File prevFile = new File(prevPath);
      prevFileExists = true;

      String contents = prevFile.readAsStringSync();
      final data = json.decode(contents);
      data.forEach((key, value) {
        userInputs[key] = value;
      });
    }

    // load the words' map
    final String wordsString = await DefaultAssetBundle.of(context)
        .loadString('assets/$thisCW/words.json');
    final data = json.decode(wordsString);
    data.forEach((key, value) {
      words[key] = [];
      value.forEach((number) {
        words[key].add(number);
      });
    });

    // load solution to draw the board and check the letters
    final String sols = await DefaultAssetBundle.of(context)
        .loadString('assets/$thisCW/sol.json');

    final data2 = json.decode(sols);
    data2.forEach((el) {
      sol.add(el);
    });
    for (var i = 0; i < sol.length; i++) {
      _controllers.add(new TextEditingController());
      _controllers[i].addListener(() {
        _controllers[i].selection =
            TextSelection.collapsed(offset: _controllers[i].text.length);
      });
      // init cellsColors map
      cellsColors.putIfAbsent(i, () => normalCellColor);
    }

    return sols;
  }

  void _loadDef() async {
    // load definitions for showing them and highlithing words
    final String defs = await DefaultAssetBundle.of(context)
        .loadString('assets/$thisCW/def.json');
    final data3 = json.decode(defs);
    // put them in list def
    data3.forEach((el) {
      def.add(new Definition(el["index"], el["h_clue"]["def"],
          el["h_clue"]["word"], el["v_clue"]["def"], el["v_clue"]["word"]));
    });
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  void _highlightWord(int index) {
    // get right definition/word (vertical or horizontal ones)
    Definition d = def[index];
    String defStr = isVertical ? d.vDef : d.hDef;
    String word = isVertical ? d.vWord : d.hWord;

    if (word != '-') {
      setState(() {
        _resetCellsColors();
        // definition setting
        shownDef = defStr;
        // highlight only word's cells
        words[word].forEach((el) {
          cellsColors.update(el, (value) => highlightedCellColor);
        });
      });
    }
  }

  void _resetCellsColors() {
    cellsColors.forEach((key, value) {
      if (value == highlightedCellColor)
        cellsColors.update(key, (value) => normalCellColor);
    });
  }

  _getCurrentStuff() {
    // prevents 'setState' to read again from disk
    return;
  }
}
