import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:scoped_model/scoped_model.dart';
import '../utils.dart';
import 'Appointments.dart';
import 'AppointmentsModel.dart';
import 'AppointmentsEntry.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';

class AppointmentsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    EventList<Event> markedDateMap = EventList<Event>();
    for (Appointment app in appointmentsModel.entityList) {
      DateTime date = toDate(app.date);
      markedDateMap.add(
          date,
          Event(
              date: date,
              icon: Container(decoration: BoxDecoration(color: Colors.black))));
    }
    return ScopedModel<AppointmentsModel>(
      model: AppointmentsModel(),
      child: Column(children: <Widget>[
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            child: CalendarCarousel<Event>(
              thisMonthDayBorderColor: Colors.grey,
              daysHaveCircularBorder: false,
              markedDatesMap: markedDateMap,
              onDayPressed: (DateTime date, List<Event> events) {
                _showAppointments(date, context);
              },
            ),
          ),
        ),
      ]),
    );
  }
}

void _showAppointments(DateTime date, BuildContext context) async {
  showModalBottomSheet(
      builder: (BuildContext context, Widget child, AppointmentsModel model) {
    return Column();
  });
}
