import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class commands extends StatefulWidget {
  commands({Key? key}) : super(key: key);

  @override
  _commandsState createState() => _commandsState();
}

class _commandsState extends State<commands> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      centerTitle: true,
      title:  Text(
        "Commands",
        style: TextStyle(
        color: Theme.of(context).hintColor,
        fontFamily: 'BrandonBI',
        fontSize: 25,
        ),
      ),
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      leading: IconButton(
      onPressed: () => Navigator.of(context).pop(),
      icon: Icon(FontAwesomeIcons.arrowLeft, color: Theme.of(context).hintColor,)
      ),
      ),
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ListView(
        children: [
          Image.asset("assets/voice.png", width: 300, height: 300,),
          
          SizedBox(height: 10,),

          Text("Assistant commands\n", textAlign: TextAlign.center, 
          style: TextStyle(fontFamily: "MaliB", fontSize: 30, color: Theme.of(context).hintColor),),

          Text("  - Navigation commands:", textAlign: TextAlign.left, 
          style: TextStyle(fontFamily: "MaliB", fontSize: 20, color: Theme.of(context).hintColor),),

          Text("   - Open homepage.\n   - Open backup.\n   - Open theme.\n   - Open profile.\n", textAlign: TextAlign.left, 
          style: TextStyle(fontFamily: "MaliR", fontSize: 18, color: Theme.of(context).hintColor),),

          Text("  - Task commands:", textAlign: TextAlign.left, 
          style: TextStyle(fontFamily: "MaliB", fontSize: 20, color: Theme.of(context).hintColor),),

          Text("   - Set title\Title.\n   - Set description\Description.\n   - Set time\Time.\n   - Category is (Work, Personal,\n     Sports, Education, Medical,\n     Others).\n   - Save task\Save.\n",
          textAlign: TextAlign.left, 
          style: TextStyle(fontFamily: "MaliR", fontSize: 18, color: Theme.of(context).hintColor),),

          Text("  - Other commands:", textAlign: TextAlign.left, 
          style: TextStyle(fontFamily: "MaliB", fontSize: 20, color: Theme.of(context).hintColor),),

          Text("    - Enable notification sound.\n    - Disable notification sound.\n", textAlign: TextAlign.left, 
          style: TextStyle(fontFamily: "MaliR", fontSize: 18, color: Theme.of(context).hintColor),),

        ],
      )

    );
  }

}