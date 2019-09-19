import 'package:flutter/material.dart';
import 'package:snowwhite_manager/api.dart';

class TicketList extends StatefulWidget {
  @override
  _TicketListState createState() => _TicketListState();
}

class _TicketListState extends State<TicketList> {
  List<Ticket> tickets = [];

  @override
  Widget build(BuildContext context) {
    fetchFirst();
    return RefreshIndicator(
      onRefresh: () {
        tickets = [];
        return fetchFirst();
      },
      child: ListView.builder(
        itemBuilder: (context, i) {
          int length = tickets.length;
          if (i >= length) {
            tryFetchNext();
            return Container();
          }
          return TicketWidget(ticket: tickets[i]);
        },
        itemCount: tickets.length + 1,
        cacheExtent: 500,
      ),
    );
  }

  fetchFirst() async {
    if (this.tickets.length != 0) return;
    List<Ticket> tickets = await listTickets();
    setState(() {
      this.tickets.addAll(tickets);
    });
  }

  tryFetchNext() async {
    print(this.tickets.length);
    List<Ticket> tickets = await listTickets(offset: this.tickets.length);
    print(tickets.length);
    if (tickets.length == 0) return;
    setState(() {
      this.tickets.addAll(tickets);
    });
  }
}

class TicketWidget extends StatelessWidget {
  final Ticket ticket;

  const TicketWidget({Key key, this.ticket}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String time = ticket.created.toString();
    time = time.substring(0, time.length - 7);
    return ListTile(
        title: Text(ticket.name),
        subtitle: Text(ticket.number),
        trailing: Text(time));
  }
}
