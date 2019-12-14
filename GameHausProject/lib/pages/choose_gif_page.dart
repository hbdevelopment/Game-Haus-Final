import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:giphy_client/giphy_client.dart';
import 'package:ghfrontend/style/theme_style.dart' as Style;

class ChooseGifPage extends StatefulWidget {


  @override
  State<StatefulWidget> createState() {
    return _ChooseGifPageState();
  }
}

class _ChooseGifPageState extends State<ChooseGifPage> {

  GiphyGif _gif;
  final searchController = TextEditingController();

  List<GiphyGif> gifArray = [];

  @override
  void initState() {
    // TODO: implement initState
    searchGif();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: Text("CHOOSE GIF", style: Style.TextTemplate.app_bar,),
          centerTitle: true,
          backgroundColor: Style.Colors.primaryColor,
        ),
        body: Column(children: <Widget>[
          _createColorsRow(),
          Container(
            color: Style.Colors.grey,
              padding: EdgeInsets.only(left: 5, right: 5),
              margin: EdgeInsets.only(top: 10, bottom: 10),
              child: Padding(
                padding: EdgeInsets.only(left: 10),
                child: TextField(
                    style: new TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
                    controller: searchController,
                    decoration: InputDecoration(
                        hintText: 'Search Giphy',
                        hintStyle: Style.TextTemplate.tf_hint,
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                    ),
                    onChanged: (value) => searchGif()
                ),
              )
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: searchGif,
              child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: (4/3),
                  children: List.generate(gifArray.length, (index) {
                    return _buildGifView(gifArray[index]);
                  })
              ),
            ),
          ),
        ]
      )
    );
  }

  Widget _buildGifView(GiphyGif gif){
    return InkWell(
      child: Container(
        color: Style.Colors.darkGrey,
        child: Image(
          image: NetworkImage(gif.images.downsized.url),
          fit: BoxFit.fitHeight,
        ),
      ),
      onTap: () => _chooseGif(gif),
    );
  }

  Future<void> searchGif() async {
    // Create the client with an api key
    //
    // Visit https://developers.giphy.com to obtain a key
    final client = new GiphyClient(apiKey: 'RbR2vCHAXm4IOfn06Ap0UDm5SVzTkyNm');
    String query = searchController.text;
    if (query != ""){
      await client.search(
          query,
          offset: 1,
          limit: 30,
          rating: GiphyRating.g,
          lang: GiphyLanguage.english
      ).then((collection){
        setState(() {
          gifArray = collection.data;
        });
      });
    }else {
      // Fetch & print a collection with options
      await client.trending(
        offset: 1,
        limit: 60,
        rating: GiphyRating.g,
      ).then((collection){
        setState(() {
          gifArray = collection.data;
        });
      });
    }
  }
  
  void _chooseGif(GiphyGif gif){
    Navigator.pop(context, gif);
    
  }

  Widget _createColorsRow() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            height: 3,
            color: Style.Colors.blue,
          ),
        ),
        Expanded(
          child: Container(
            height: 3,
            color: Style.Colors.red,
          ),
        ),
        Expanded(
          child: Container(
            height: 3,
            color: Style.Colors.yellow,
          ),
        ),
        Expanded(
          child: Container(
            height: 3,
            color: Style.Colors.green,
          ),
        ),
      ],
    );
  }

}