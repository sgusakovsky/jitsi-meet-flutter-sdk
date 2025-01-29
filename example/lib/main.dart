import 'package:flutter/material.dart';
import 'package:jitsi_meet_govar_flutter_sdk/jitsi_meet_govar_flutter_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _jitsiMeetPlugin = JitsiMeet();

  final _jitsiMeetListener = JitsiMeetEventListener(
    conferenceJoined: (url) {
      debugPrint("conferenceJoined: url: $url");
    },
    conferenceTerminated: (url, error) {
      debugPrint("conferenceTerminated: url: $url, error: $error");
    },
    conferenceWillJoin: (url) {
      debugPrint("conferenceWillJoin: url: $url");
    },
    participantJoined: (email, name, role, participantId) {
      debugPrint(
        "participantJoined: email: $email, name: $name, role: $role, "
            "participantId: $participantId",
      );
    },
    participantLeft: (participantId) {
      debugPrint("participantLeft: participantId: $participantId");
    },
    audioMutedChanged: (muted) {
      debugPrint("audioMutedChanged: isMuted: $muted");
    },
    videoMutedChanged: (muted) {
      debugPrint("videoMutedChanged: isMuted: $muted");
    },
    endpointTextMessageReceived: (senderId, message) {
      debugPrint(
          "endpointTextMessageReceived: senderId: $senderId, message: $message");
    },
    screenShareToggled: (participantId, sharing) {
      debugPrint(
        "screenShareToggled: participantId: $participantId, "
            "isSharing: $sharing",
      );
    },
    chatMessageReceived: (senderId, message, isPrivate, timestamp) {
      debugPrint(
        "chatMessageReceived: senderId: $senderId, message: $message, "
            "isPrivate: $isPrivate, timestamp: $timestamp",
      );
    },
    chatToggled: (isOpen) => debugPrint("chatToggled: isOpen: $isOpen"),
    participantsInfoRetrieved: (participantsInfo) {
      debugPrint(
          "participantsInfoRetrieved: participantsInfo: $participantsInfo, ");
    },
    readyToClose: () {
      debugPrint("readyToClose");
    },
  );

  @override
  void initState() {
    super.initState();
    _jitsiMeetPlugin.join(_jitsiMeetListener);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: const Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: double.infinity,
              height: 600,
              child: JitsiMeetWidget(room: 'https://meet.govar.online/govar_speaking_club'),
            ),
            SizedBox(
              width: double.infinity,
              height: 150,
              child: Text('Bottom bar'),
            )
          ],
        ),
      ),
    );
  }
}