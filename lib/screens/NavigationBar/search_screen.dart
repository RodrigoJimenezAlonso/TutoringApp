import 'package:flutter/material.dart';
import 'package:proyecto_rr_principal/mysql.dart';


class SearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search a Subject')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showSearch(
              context: context,
              delegate: SubjectSearchDelegate(),
            );
          },
          child: Text('Search for Teachers'),
        ),
      ),
    );
  }
}



class SubjectSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: getTeachersBySubject(query),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final teachers = snapshot.data;

        if (teachers == null || teachers.isEmpty) {
          return Center(child: Text('No teachers found for this subject'));
        }

        return ListView.builder(
          itemCount: teachers.length,
          itemBuilder: (context, index) {
            final teacher = teachers[index];
            return ListTile(
              title: Text(teacher['name']),
              subtitle: Text(teacher['subject']),
              onTap: () {
                close(context, teacher);
              },
            );
          },
        );
      },
    );
  }


  Future<List<Map<String, dynamic>>> getTeachersBySubject(String subject) async {
    final conn = await MySQLHelper.connect();
    final result = await conn.query(
      'SELECT t.name, t.subject FROM teachers t WHERE t.subject LIKE ?',
      ['%$subject%'],
    );
    await conn.close();

    return result.map((row) => row.fields).toList();
  }
}