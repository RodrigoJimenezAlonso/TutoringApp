import 'package:flutter/material.dart';
import 'feedback_controller.dart';

class FeedbackScreen extends StatefulWidget{
  final String teacherID;
  const FeedbackScreen({Key? key, required this.teacherID}):super(key: key);

  @override
  _FeedbackScreenState createState()=> _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen>{
  double _rating  = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitted = false;

  void _submitFeedback() async{
    if(_isSubmitted)return;

    if(_rating == 0){
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
        content: Text('Please add a rating'),
      ));
      return;
    }
    setState(()=> _isSubmitted = true);
    try{
      await FeedbackController.submitFeedback(
          widget.teacherID,
          "123456",
          //studentId, reemplazar con el id del alumno actual
          _rating,
          _commentController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thank you for your comment!')),
      );
      Navigator.pop(context);
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed sending feedback'),),
      );
    }finally{
      setState(()=> _isSubmitted = false);
    }

  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Give your rating'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'value your experience',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index){
                return IconButton(
                      icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.yellow[700]
                    ),
                  onPressed: (){
                        setState(() {
                          _rating = index + 1.0;
                        });
                  },
                );
              }),
            ),
            TextFormField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: 'comment (optional)',
              ),
              maxLines: 3,
              validator: (value){
                if(value != null && value.length > 300){
                  return 'Comment is too long(MAX 300 characters)';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
                onPressed: _submitFeedback,
                child: Text('send rating')
            ),
          ],
        ),
      ),
    );
  }
}

