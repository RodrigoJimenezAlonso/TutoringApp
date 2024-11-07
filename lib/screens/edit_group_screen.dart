import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

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
      final response = await Supabase.instance.client
          .from('groups')
          .select('groupDescription')
          .eq('id', widget.groupId)
          .maybeSingle();
      if(response != null){
        setState(() {
          _descriptionController.text = response['groupDescription'] ?? '';
        });
      }else{
        throw Exception('Group not found');
      }
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load group data: $e'))
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
                onPressed: ()async{
                  try{
                    final response = await Supabase.instance.client.from('groups')
                        .update({
                      'groupDescription': _descriptionController.text
                    })
                    .eq('id', widget.groupId);
                    if(response.error == null){
                      Navigator.pop(context);
                    }else{
                      throw response.error!;
                    }
                  }catch(e){
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update group: $e')),
                    );
                  }

                },
              child: Text('save'),
            )
          ],
        ),
      ),
    );
  }
}