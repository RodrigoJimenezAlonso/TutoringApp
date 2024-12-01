import 'package:flutter/material.dart';
import 'package:proyecto_rr_principal/mysql.dart';


class GroupMemberScreen extends StatelessWidget{

  final String groupId;
  GroupMemberScreen({
    required this.groupId
  });

  void removeUserFromGroup(BuildContext context, String groupId, String userId)async{
    final messager = ScaffoldMessenger.of(context);
    try{
      final conn = await MySQLHelper.connect();
      await conn.query(
        'DELETE FROM group_members WHERE groupID = ? AND id = ?',
        [groupId, userId]
      );
      await conn.close();
      messager.showSnackBar(
        const SnackBar(
            content: Text('User has been eliminated successfully')
        )
      );

    }catch(e) {
      messager.showSnackBar(
          const SnackBar(
              content: Text('User has not been eliminated')
          )
      );
    }
  }

  Future<List<Map<String, dynamic>>> _getGroupMember()async{
    final conn = await MySQLHelper.connect();
    final result = await conn.query(
      'SELECT user_id FROM group_members WHERE group_id = ?',
      [groupId],
    );

    await conn.close();

    return result.map((row)=> {
      'userId': row['user_id'],
    }).toList();

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
        future: _getGroupMember(),
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