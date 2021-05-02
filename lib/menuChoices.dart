import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MyDrawer extends StatelessWidget {
  static const url_cw = 'https://filippopaganelli.github.io/crosswords.html';
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: ListView(
              children: [
                SizedBox(
                  width: 380,
                  height: 56,
                  child: Container(
                    child: Stack(
                      alignment: AlignmentDirectional.topCenter,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(55, 101, 176, 1),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 25.0,
                          ),
                          child: Container(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              'Info',
                              style: TextStyle(
                                  fontSize: 35,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                ListTile(
                  contentPadding:
                      EdgeInsets.only(top: 5, bottom: 5, left: 20, right: 20),
                  title: Text(
                    'Browser version',
                    style: TextStyle(fontSize: 30, color: Colors.grey[700]),
                  ),
                  trailing: FaIcon(
                    FontAwesomeIcons.jsSquare,
                    size: 30,
                    color: Color.fromRGBO(55, 101, 176, 1),
                  ),
                  onTap: () => _launchBrowserVersion(context),
                ),
                Divider(
                  height: 20,
                  thickness: 1,
                ),
                ListTile(
                  // CHANGE LINK WITH ACTUAL APP CODE ON GITHUB------------------------!!!!!!!!!!!!
                  contentPadding:
                      EdgeInsets.only(top: 5, bottom: 5, left: 20, right: 20),
                  title: Text(
                    'Code on GitHub',
                    style: TextStyle(fontSize: 30, color: Colors.grey[700]),
                  ),
                  trailing: FaIcon(
                    FontAwesomeIcons.githubSquare,
                    size: 30,
                    color: Color.fromRGBO(55, 101, 176, 1),
                  ),
                  onTap: () => _launchGithub(context),
                ),
                Divider(
                  height: 10,
                  thickness: 1,
                ),
                ListTile(
                  contentPadding:
                      EdgeInsets.only(top: 5, bottom: 5, left: 20, right: 20),
                  title: Text(
                    'My website',
                    style: TextStyle(fontSize: 30, color: Colors.grey[700]),
                  ),
                  trailing: Icon(
                    Icons.web_rounded,
                    size: 32,
                    color: Color.fromRGBO(55, 101, 176, 1),
                  ),
                  onTap: () => _launchMyWebsite(context),
                ),
                Divider(
                  height: 20,
                  thickness: 1,
                ),
                ListTile(
                  contentPadding:
                      EdgeInsets.only(top: 5, bottom: 5, left: 20, right: 20),
                  title: Text(
                    'Get in touch',
                    style: TextStyle(fontSize: 30, color: Colors.grey[700]),
                  ),
                  trailing: Icon(
                    Icons.email_rounded,
                    size: 32,
                    color: Color.fromRGBO(55, 101, 176, 1),
                  ),
                  onTap: () => _launchEmail(context),
                ),
                Divider(
                  height: 10,
                  thickness: 1,
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(bottom: 7, left: 10),
            child: Text('App by: Filippo Paganelli',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic)),
          ),
        ],
      ),
    );
  }
}

_launchBrowserVersion(BuildContext ctx) async {
  const url = 'https://filippopaganelli.github.io/crosswords.html';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    _launchError(url, ctx);
  }
}

_launchMyWebsite(BuildContext ctx) async {
  const url = 'https://filippopaganelli.github.io';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    _launchError(url, ctx);
  }
}

_launchEmail(BuildContext ctx) async {
  const url = 'mailto:paganellifilippo@gmail.com';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    _launchError(url, ctx);
  }
}

_launchGithub(BuildContext ctx) async {
  const url = 'https://github.com/FilippoPaganelli';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    _launchError(url, ctx);
  }
}

_launchError(String url, BuildContext context) {
  Navigator.pop(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        "Could not open: \"$url\"...",
        style: TextStyle(fontSize: 18),
      ),
    ),
  );
  HapticFeedback.vibrate();
}
