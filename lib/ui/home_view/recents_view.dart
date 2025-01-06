import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:revo/extentions/datetime.dart';
import 'package:revo/extentions/theme.dart';
import 'package:revo/modal/call_log_data.dart';
import 'package:revo/services/contact_service.dart';
import 'package:revo/ui/contactinfo_view.dart';
import 'package:revo/utils/circle_profile.dart';
import 'package:revo/utils/calltypes.dart';

class RecentsView extends StatefulWidget {
  const RecentsView({super.key});

  @override
  State<RecentsView> createState() => _RecentsViewState();
}

class _RecentsViewState extends State<RecentsView> {
  late final ScrollController _controller;
  int _prevDate = -1;

  @override
  void initState() {
    _controller = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var callLogs = ContactService().callLogs;
    return FutureBuilder(
        future: ContactService().initialize(),
        builder: (context, snapshot) {
          return Scrollbar(
            trackVisibility: true,
            thickness: 2.5,
            interactive: true,
            radius: Radius.circular(30),
            controller: _controller,
            child: ListView.builder(
              itemCount: callLogs.length,
              controller: _controller,
              itemBuilder: (context, i) {
                Widget w = drawLog(context, callLogs, i);
                _prevDate = callLogs[i].date.weekday;
                return w;
              },
            ),
          );
        });
  }

  Widget drawLog(BuildContext context, List<CallLogData> callLogs, int index) {
    bool showDateHeader = index == 0 ||
        callLogs[index].date.weekday != callLogs[index - 1].date.weekday;
    CallLogData log = callLogs[index];
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showDateHeader)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 50, 0, 0),
            child: Text(
              log.date.getContextAwareDate(),
              style: GoogleFonts.cabin(
                fontSize: 20,
                color: context.colorScheme.primary,
              ),
            ),
          ),
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          leading: CircleProfile(
            name: log.name ?? '',
            profile: log.profile,
            size: 30,
          ),
          title: Text(
            getDisplayName(log),
            style: GoogleFonts.cabin(
              fontSize: 16,
              color: context.colorScheme.onSurface.withAlpha(200),
            ),
          ),
          trailing: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: context.colorScheme.primary.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ContactInfoView(ContactService()
                      .contacts
                      .where((c) => c.displayName == log.name)
                      .first),
                ));
              },
              icon: Icon(Icons.arrow_forward_ios,
                  color: context.colorScheme.primary, size: 20),
            ),
          ),
          subtitle: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    getCallIcon(log.type),
                    color: getCallColor(log.type, context),
                    size: 16,
                  ),
                  SizedBox(width: 5),
                  Text(
                    log.date.getContextAwareDateTime(),
                    style: GoogleFonts.cabin(
                      fontSize: 12,
                      color: getCallColor(log.type, context),
                    ),
                  ),
                ],
              ),
              Text(
                log.simDisplayName,
                style: GoogleFonts.cabin(fontSize: 12, color: Colors.blueGrey),
              ),
            ],
          ),
          onTap: () async {},
        ),
      ],
    );
  }
}
