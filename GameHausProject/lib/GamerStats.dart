import 'package:flutter/material.dart';

class GamerStats extends StatefulWidget {
  @override
  _GamerStatsState createState() => _GamerStatsState();
}

class _GamerStatsState extends State<GamerStats> {

  /*
   * the list holding all possible stats for all games from the API and a refresh button
   * Game Index:
   * 0, Overwatch
   * 1, Dota2
   * 2, Fortnite
   * 3, LOL
   * 4, refresh button
   */
  List<Widget> _gameStatsHolder = new List(5);

  @override
  Widget build(BuildContext context) {

    // initialize the holder, initially, they all empty 0 size SizedBox
    for(int i = 0; i < 4; i++){
      _gameStatsHolder[i]  = SizedBox(
        width: 0,
        height: 0,
      );
    }

    // create the refresh button at the end
    _gameStatsHolder[4] = _createRefresh();

    // show all stats
    return ListView(
      children: _gameStatsHolder,
    );
  }


  /*
   * every time the users successfully linked their game account (one per attempt),
   * and after the all the API Json file successfully parsed into firebase
   * call this method, and this method will add one game info block into the holder list
   *
   * That's it: After user click "balabala(a random game) game connect" in Ted's page and after
   * the auth succeed, call this method
   */
  _deriveStats (bool isAPIVerified, String whichGame){
    if(isAPIVerified){
      switch(whichGame){
        case 'Overwatch' :{
          _gameStatsHolder[0] = _createOverwatchGameStats();
        } break;
        case 'Dota2' :{
          //TODO: create Dota2 stats block
        } break;
        case 'Fortnite' :{
          //TODO: create Fortnite stats block
        } break;
        case 'LOL' :{
          //TODO: create LOL stats block
        } break;
        default :{
          print('No Game Info Added...');
        }
      }
    }

    setState(() {

    });
  }




  /*
   * every time the users successfully disconnect their game account (one per attempt),
   * call this method, and this method will delete the corresponding stats block
   */
  _deleteStats (whichGame){
    switch(whichGame){
      case 'Overwatch' :{
        _gameStatsHolder[0] = SizedBox(
          width: 0,
          height: 0,
        );
      } break;
      case 'Dota2' :{
        _gameStatsHolder[1] = SizedBox(
          width: 0,
          height: 0,
        );
      } break;
      case 'Fortnite' :{
        _gameStatsHolder[2] = SizedBox(
          width: 0,
          height: 0,
        );
      } break;
      case 'LOL' :{
        _gameStatsHolder[3] = SizedBox(
          width: 0,
          height: 0,
        );
      } break;
      default :{
        print('No Game has been deleted...');
      }
    }

    setState(() {

    });
  }



  /*
   * this method is to create the refresh button
   */
  Widget _createRefresh () {
    return IconButton(
      icon: Icon(Icons.refresh),
      onPressed: () => {
        // TODO: refresh the data in firebase from Game API (the Json file)
      }
    );
  }



  /*
   * this method is to create Overwatch Stats block
   */
  Widget _createOverwatchGameStats(){

    /*
     * TODO: all data of this list should be from firebase after successfully authed.
     * For eg: Battle tag, level, KDA ratio, damage per 10 min, etc...
     */
    List allOverwatchStats = new List();


    return Stack(
      children: <Widget>[

        // background theme color for Overwatch
        Opacity(
          child: Container(
            color: Colors.amber,
          ),
        ),

        // the Game stats, derived from list allOverwatchStats(firebase) ... holding in multiple rows in a column
        Column(
          children: <Widget>[
            Row(),
            Row(),
            Row(),

          ],
        )

      ],
    );
  }

  // TODO: add stats block create methods for other games

}
