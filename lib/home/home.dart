import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../menuChoices.dart';

class HomePage extends StatelessWidget {
  HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        //leading: Icon(Icons.menu_rounded),
        /*leading: IconButton(
          icon: Icon(Icons.menu_rounded),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),*/
        backgroundColor: Color.fromRGBO(55, 101, 176, 1),
        title: Text(
          'CruciApp',
          style: TextStyle(
              fontSize: 28, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 60,
            ),
            SizedBox(
              width: 380,
              height: 200,
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Choose one from the list...",
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  );
                  HapticFeedback.vibrate();
                },
                child: Container(
                  child: Stack(
                    alignment: AlignmentDirectional.topCenter,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: AssetImage('assets/play_btn_bg.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color.fromRGBO(55, 101, 176, .8),
                        ),
                      ),
                      Container(
                        alignment: AlignmentDirectional.center,
                        child: Text(
                          'Play Crosswords',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Expanded(
              child: FutureBuilder(
                future: DefaultAssetBundle.of(context)
                    .loadString("assets/cwinfos.json"),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var data = json.decode(snapshot.data.toString());
                    var nItems = data.length;
                    return ListView.separated(
                        separatorBuilder: (context, index) {
                          return Divider(
                            height: 20,
                            thickness: 1,
                          );
                        },
                        padding: EdgeInsets.only(top: 10),
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            onTap: () {
                              // ONTAP NAVIGATION:
                              HapticFeedback.vibrate();
                              Navigator.of(context).pushNamed(
                                '/cw',
                                arguments: [
                                  (index + 1).toString(),
                                  data[index]["rows"],
                                  data[index]["cols"]
                                ],
                              );
                            },
                            contentPadding: EdgeInsets.only(
                                top: 5, left: 20, right: 15, bottom: 5),
                            title: Text(
                              data[index]["name"],
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            minVerticalPadding: 5,
                            subtitle: Text(
                              '\n' + data[index]["description"],
                              style: TextStyle(fontSize: 15),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  data[index]["language"],
                                  style: TextStyle(
                                      color: Colors.blueGrey[600],
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  data[index]["rows"].toString() +
                                      ' x ' +
                                      data[index]["cols"].toString(),
                                  style: TextStyle(
                                      color: Colors.blueGrey[600],
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            leading: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xff083663).withAlpha(45),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // NUMBER:
                                        Text(
                                          "#${index + 1}",
                                          style: TextStyle(
                                              color: Colors.blueGrey[600],
                                              fontSize: 25),
                                        ),
                                      ],
                                    )),
                              ],
                            ),
                          );
                        },
                        itemCount: nItems);
                  } else
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                },
              ),
            ),
            SizedBox(
              height: 15,
            )
          ],
        ),
      ),
    );
  }
}
