import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupMemberScreen extends StatelessWidget{

  final String groupId;
  GroupMemberScreen({
    required this.groupId
  });

  void removeUserFromGroup(BuildContext context, String groupId, String userId)async{
    try{
      await Supabase.instance.client
          .from('groups')
          .update({
        'members': [{
          "userId": userId,
          "role": 'member',
        }]
      }).eq('id', groupId);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('user removed successfully'))
      );
    }catch(e) {
      print('error removing user from group: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('failed removing user: $e'))
      );
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Group Members'
        ),
      ),
      body: FutureBuilder(
        future: Supabase.instance.client
          .from('groups')
          .select()
          .eq('id', groupId),
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator());
          }else if(snapshot.hasError){
            return Center(child: Text('Error: ${snapshot.error}'));
          }else if(!snapshot.hasData || snapshot.data!.isEmpty){
            return Center(child: Text('No data found'),);
          }
          var groupData = (snapshot.data as List).first;
          List members = groupData['members'];
          return ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index){
                var member = members[index];
                return ListTile(
                  title: Text(
                    member['userId'],
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.remove
                    ),
                    onPressed: (){
                      removeUserFromGroup(context, groupId, member['userId']);
                    },
                  ),
                );
              },
          );
        },
      ),
    );
  }
}