import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class CWPage extends StatefulWidget {
  final String thisCW;

  CWPage(this.thisCW);

  @override
  _CWPageState createState() => new _CWPageState(thisCW);
}

class _CWPageState extends State<CWPage> {
  final String thisCW;
  bool isVertical = false;
  int lastTapped = -1;
  Map<String, String> userInputs = Map();
  Map<String, List<int>> words = Map();
  List<TextEditingController> _controllers = [];
  final FocusScopeNode _node = FocusScopeNode();
  String prevDir;
  String prevPath;
  bool prevFileExists = false;
  List<ValueKey> contKeys = [];

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
          ButtonBar(
            alignment: MainAxisAlignment.spaceEvenly,
            //buttonPadding: EdgeInsets.only(bottom: 20),
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
                child: Text(
                  'Reset',
                  style: TextStyle(fontSize: 30),
                ),
                onPressed: () {
                  _buttonPress("Reset");
                },
              ),
              ElevatedButton(
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
          Container(
            child: new FutureBuilder(
                future: _loadStuff(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var sol = json.decode(snapshot.data.toString());
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, top: 10, bottom: 10),
                        child: GridView.count(
                          // MAKE 11 AND 110 VARIABLE ACCORDING TO CROSSWORD DIMENSIONS!
                          crossAxisCount:
                              11, // n° elements in each row! a.k.a. "cols" property in cwinfos.json!
                          children: List.generate(110, (index) {
                            // here 110 is rows*cols
                            ValueKey _key = ValueKey(index);
                            contKeys.add(_key);
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
                                          key: _key,
                                          color: Colors.amber[100],
                                          child: TextField(
                                            // set the initial text to the previous saved values
                                            controller: _controllers[index]
                                              ..text =
                                                  userInputs[index.toString()],
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            inputFormatters: [
                                              LengthLimitingTextInputFormatter(
                                                  1),
                                            ],
                                            cursorWidth: 5,
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

                                              // highlist word
                                              _highlightWord(index);
                                            },
                                            onChanged: (text) {
                                              userInputs[index.toString()] =
                                                  text;
                                              if (text.isEmpty) {
                                                userInputs.remove(index);
                                              } else {
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
        {
          // key stuff
        }
    }
  }

  void _saveInputs() {
    // only saves status if there are letters on the board
    if (userInputs.isNotEmpty) {
      final data = json.encode(userInputs);
      File(prevPath).createSync(recursive: true);
      File prevFile = new File(prevPath);
      prevFile.writeAsString(data).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Crossword #$thisCW has been saved...',
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
            content: Text('Crossword #$thisCW has been saved...',
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
          content: Text('Crossword #$thisCW has never been saved before...',
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
            onPressed: () {
              _controllers.forEach((ctrl) {
                ctrl.text = '';
              });
              userInputs.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Crossword #$thisCW has been reset...',
                      style: TextStyle(fontSize: 23)),
                ),
              );
              HapticFeedback.vibrate();
              Navigator.of(context).pop();
            },
            child: Text('Yes', style: TextStyle(fontSize: 23))),
        ElevatedButton(
            onPressed: () {
              HapticFeedback.vibrate();
              Navigator.of(context).pop();
            },
            child: Text('No', style: TextStyle(fontSize: 23))),
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

    int length = json.decode(sols).length;
    for (var i = 0; i < length; i++) {
      _controllers.add(new TextEditingController());
    }

    return sols;
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  void _highlightWord(int index) {
    // to be implemented
  }
}
