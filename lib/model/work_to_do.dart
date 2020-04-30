import 'package:flutter/material.dart';
import 'package:work_pend/model/work.dart';

class WorkToDo {
  DateTime date;
  List<Work> work_list;

  WorkToDo ({
    @required this.date,
    this.work_list
  });
}