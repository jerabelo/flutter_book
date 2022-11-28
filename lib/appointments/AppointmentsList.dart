import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:scoped_model/scoped_model.dart';
import '../utils.dart';
import 'Appointments.dart';
import 'AppointmentsModel.dart';
import 'AppointmentsEntry.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';

class AppointmentsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    EventList<Event> markedDateMap = EventList<Event>(events: Map());
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
        FloatingActionButton(
          child: const Icon(
            Icons.add,
            color: Colors.black,
          ),
          onPressed: () {
            appointmentsModel.entityBeingEdited = Appointment();
            appointmentsModel.setStackIndex(1);
          },
        ),
      ]),
    );
  }
}

void _showAppointments(DateTime date, BuildContext context) async {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          children: <Widget>[
            Text(
              "${date.month}/${date.day}/${date.year}",
              style: TextStyle(height: 2, fontSize: 20, color: Colors.blue),
            ),
            Expanded(
                child: ListView.builder(
                    itemCount: appointmentsModel.entityList.length,
                    itemBuilder: (BuildContext context, int index) {
                      Appointment app = appointmentsModel.entityList[index];
                      if (app.date !=
                          "${date.year},${date.month},${date.day}") {
                        return Container(height: 0);
                      }
                      return Container(
                        child: ListTile(
                          title: Text("${app.title} (${app.time})"),
                          subtitle: Text(app.description),
                          tileColor: Colors.grey,
                        ),
                      );
                    }))
          ],
        );
      });
}
