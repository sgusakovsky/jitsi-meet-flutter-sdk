import 'dart:io';
import 'package:jitsi_meet_govar_flutter_sdk/src/method_response.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class JitsiAudioRecorder {
  final _recorder = AudioRecorder();

  Future<String> _getRecordingPath() async {
    final directory = await getTemporaryDirectory();
    return "${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a";
  }

  Future<MethodResponse> startRecording() async {
    if (!(await _recorder.hasPermission())) {
      return MethodResponse(isSuccess: false, message: 'User does not have microphone permissions');
    }

    final filePath = await _getRecordingPath();

    const config = RecordConfig();

    await _recorder.start(config, path: filePath);
    return MethodResponse(isSuccess: true, message: "Recording has started at path: $filePath");
  }

  Future<String?> stopRecording() async {
    if (await _recorder.isRecording()) {
      final path = await _recorder.stop();
      return path;
    }
    return null;
  }


}