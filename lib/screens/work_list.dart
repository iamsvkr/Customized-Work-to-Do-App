import 'package:flutter/material.dart';
import 'package:horizontal_calendar_widget/date_helper.dart';
import 'package:horizontal_calendar_widget/horizontal_calendar.dart';
import 'package:work_pend/model/work.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const labelMonth = 'Month';
const labelDate = 'Date';
const labelWeekDay = 'Week Day';

class WorkList extends StatefulWidget {
  WorkList({Key key}) : super(key: key);

  @override
  _WorkListState createState() => _WorkListState();
}

class _WorkListState extends State<WorkList> {

  bool forceRender = false;
  DateTime firstDate = toDateMonthYear(DateTime.now());
  DateTime lastDate = toDateMonthYear(DateTime.now().add(Duration(days: 30)));
  String dateFormat = 'dd';
  String monthFormat = 'MMM';
  String weekDayFormat = 'EEE';
  List<String> order = [labelDate, labelWeekDay];

  Color defaultDecorationColor = Colors.transparent;
  BoxShape defaultDecorationShape = BoxShape.circle;
  bool isCircularRadiusDefault = true;

  Color selectedDecorationColor = Colors.amber;
  bool isCircularRadiusSelected = true;

  // Color disabledDecorationColor = Colors.grey;
  // BoxShape disabledDecorationShape = BoxShape.rectangle;
  // bool isCircularRadiusDisabled = true;

  int maxSelectedDateCount = 1;

  String day = DateTime.now().day.toString();
  String month = DateTime.now().month.toString();
  String year = DateTime.now().year.toString();

  final _title = TextEditingController();
  final _desc = TextEditingController();

  List<Work> work_list = [
    Work(title : "Vmware",desc: "Fill vmware form"),
    Work(title: "Coding", desc: "Practice coding")
  ];

  _submit(String title, String desc){
    Firestore.instance.collection(year).document(month).collection(day).add({
      "title" : title,
      "desc" : desc
    });
  }

  void onButtonPressed(BuildContext ctx){
    showModalBottomSheet(context: ctx, builder: (_){
      return Column(
        children: <Widget>[
          SizedBox(height: 20,),
          Container(
            padding: EdgeInsets.all(20),
            child: TextFormField(
              controller: _title,
              decoration: const InputDecoration(
                icon: Icon(Icons.title),
                hintText: 'Title',
                labelText: 'Title',
              ),
            ),
          ),
          SizedBox(height: 20,),
          Container(
            padding: EdgeInsets.all(20),
            child: TextFormField(
              controller: _desc,
              decoration: const InputDecoration(
                icon: Icon(Icons.description),
                hintText: 'Description',
                labelText: 'Description',
              ),
            ),
          ),
          SizedBox(height: 20,),
          RaisedButton(
            child: Text("Submit"),
            onPressed: (){
              _submit(_title.text.toString(), _desc.text.toString());
              Navigator.pop(context);
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding:
            EdgeInsets.symmetric(horizontal: 40.0, vertical: 8.0),
            color: Theme.of(context).primaryColor,
            textColor: Theme.of(context).primaryTextTheme.button.color,
          )
        ],
      );
    });
  }

  _delete(String title){
    Firestore.instance.collection(year).document(month).collection(day);
  }

  _createListTile(BuildContext ctx, DocumentSnapshot document){
    return ListTile(
      leading: Icon(Icons.arrow_forward_ios),
      title: Text(document['title']),
      subtitle: Text(document['desc']),
      trailing: InkWell(
        onTap: (){
          _delete(document['title']);
        },
        child: Icon(Icons.delete),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Work List"), 
        backgroundColor: Colors.cyan,
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(height: 16),
          HorizontalCalendar(
            key: forceRender ? UniqueKey() : Key('Calendar'),
            height: 70,
            padding: EdgeInsets.all(15),
            firstDate: firstDate,
            lastDate: lastDate,
            dateFormat: dateFormat,
            weekDayFormat: weekDayFormat,
            monthFormat: monthFormat,
            // defaultDecoration: BoxDecoration(
            //   color: defaultDecorationColor,
            //   shape: defaultDecorationShape,
            //   borderRadius: defaultDecorationShape == BoxShape.rectangle &&
            //           isCircularRadiusDefault
            //       ? BorderRadius.circular(80)
            //       : null,
            // ),
            selectedDecoration: BoxDecoration(
              color: Colors.teal[300],
              borderRadius: BorderRadius.circular(60),

            ),
            // disabledDecoration: BoxDecoration(
            //   color: disabledDecorationColor,
            //   shape: disabledDecorationShape,
            //   borderRadius: disabledDecorationShape == BoxShape.rectangle &&
            //           isCircularRadiusDisabled
            //       ? BorderRadius.circular(80)
            //       : null,
            // ),
            // isDateDisabled: (date) => date.weekday == 7,
            onDateSelected: (date){
              setState(() {
                day = date.day.toString();
                month = date.month.toString();
                year = date.year.toString();
              });
              print(day + " " + month+ " "+ year+" "+DateTime.now().year.toString());
            },
            labelOrder: order.map(toLabelType).toList(),
            maxSelectedDateCount: maxSelectedDateCount,
          ),
          SizedBox(height: 15,),
          Container(
            color: Colors.grey[400],
            padding: EdgeInsets.only(left: 15, top: 10, bottom: 10),
            child: Text("Work Logs"),
          ),
          Container(
            height: 200,
            child: StreamBuilder(
              stream: Firestore.instance.collection(year).document(month).collection(day).snapshots(),
              builder: (context, snapshot) {
                if(!snapshot.hasData)
                  return CircularProgressIndicator();
                else if(snapshot.data.documents.length == 0)
                  return Container(
                    padding: EdgeInsets.all(30),
                    child: Text("No Work Logs"),
                  );
                return ListView.builder(
                  itemExtent: 20.0,
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) =>
                    _createListTile(context, snapshot.data.documents[index])
                  ,
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: (){
          onButtonPressed(context);
        },
      ),
    );


  }
}

LabelType toLabelType(String label) {
  LabelType type;
  switch (label) {
    // case labelMonth:
    //   type = LabelType.month;
    //   break;
    case labelDate:
      type = LabelType.date;
      break;
    case labelWeekDay:
      type = LabelType.weekday;
      break;
  }
  return type;
}