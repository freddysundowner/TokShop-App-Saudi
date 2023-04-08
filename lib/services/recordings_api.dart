import 'dart:convert';

import 'client.dart';
import 'end_points.dart';

class RecordingsAPI {
  getUserRecordings(String uid, {String limit = "15"}) async {
    var recordings = await DbBase().databaseRequest(
        "$userRecordings$uid?limit=$limit", DbBase().getRequestType);

    return jsonDecode(recordings);
  }

  getRecordingById(String uid) async {
    var recordings = await DbBase()
        .databaseRequest(recordingById + uid, DbBase().getRequestType);

    return jsonDecode(recordings)["recording"];
  }

  deleteRecording(String recordingId) async {
    var recording = await DbBase().databaseRequest(
        "$recordings/$recordingId", DbBase().deleteRequestType);

    return jsonDecode(recording);
  }
}
