// @dart=2.9
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class IndexPage extends StatefulWidget {
  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  List users = [];
  bool isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.fetchUser();
  }

  Future<void> fetchUser() async {
    setState(() {
      isLoading = true;
    });
    var url =
        "https://api.stackexchange.com/2.2/questions/no-answers?order=desc&sort=activity&site=stackoverflow";
    var response = await http.get(url);
    //print(response.statusCode);
    if (response.statusCode == 200) {
      var items = json.decode(response.body)['items'];
      setState(() {
        users = items;
        isLoading = false;
      });
    } else {
      users = [];
      isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("StackOverflow"),
      ),
      body: RefreshIndicator(
        child: getBody(),
        onRefresh: fetchUser,
      ),
    );
  }

  Widget website(String s) {
    return Scaffold(
      appBar: AppBar(title: Text("StackOverflow")),
      body: WebView(initialUrl: s),
    );
  }

  Widget getBody() {
    if (users.contains(null) || users.length < 0 || isLoading) {
      return Center(
          child: CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
      ));
    }
    return ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return getCard(users[index]);
        });
  }

  Widget getCard(item) {
    var title = item['title'];
    var tags = item['tags'];
    var profileUrl = item['owner']['profile_image'];
    var stackUrl = item['link'];

    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => website(stackUrl)));
      },
      child: Card(
        elevation: 1.5,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: ListTile(
            title: Row(
              children: <Widget>[
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(60 / 2),
                      image: DecorationImage(
                          fit: BoxFit.cover, image: NetworkImage(profileUrl))),
                ),
                SizedBox(
                  width: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                        width: MediaQuery.of(context).size.width - 130,
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 140,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (var i = 0; i < tags.length; i++)
                              Container(
                                margin: const EdgeInsets.all(3.0),
                                padding: const EdgeInsets.all(5.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 2,
                                    color: Colors.lightGreen,
                                  ),
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: Text(
                                  tags[i].toString(),
                                  style: TextStyle(color: Colors.lightGreen),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
