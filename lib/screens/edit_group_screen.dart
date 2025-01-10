import 'package:flutter/material.dart';
import 'package:proyecto_rr_principal/mysql.dart';

class EditGroupScreen extends StatefulWidget{
  final String groupId;
  EditGroupScreen({
    required this.groupId,
});
  @override

  _EditGroupScreenState createState()=> _EditGroupScreenState();
}

class _EditGroupScreenState extends State<EditGroupScreen> {
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadGroupData();
  }

  Future<void> _loadGroupData()async{
    try {
      final conn = await MySQLHelper.connect();
      final result = await conn.query(
          'SELECT groupDescription FROM groups WHERE id = ?',
          [widget.groupId]
      );
      if(result.isNotEmpty){
        setState(() {
          _descriptionController.text = result.first['groupDescription'] ?? '' ;
        });
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Group not found'))
        );
      }

    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load group data: $e'))
      );
    }
  }

  Future<void> _updateGroupDescription()async{
    try{
      final conn = await MySQLHelper.connect();
      await conn.query(
        'UPDATE groups SET groupDescription = ? WHERE id = ?',
        [_descriptionController.text, widget.groupId],
      );

      Navigator.pop(context);
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load group description: $e'))
      );
    }
  }

  @override

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('edit group'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
                child: TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Groups Description',
                  ),
                  validator: (value){
                    if(value == null || value.isEmpty){
                      return 'Please insert a description';
                    }
                    return null;
                  },
              ),
            ),
            ElevatedButton(
              onPressed: _updateGroupDescription,
              child: Text('save'),
            )
          ],
        ),
      ),
    );
  }
}