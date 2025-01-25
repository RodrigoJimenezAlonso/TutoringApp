import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoCallScreen extends StatefulWidget{
  final String channelName;
  final String token;
  final int userId;

  VideoCallScreen({
    required this.userId,
    required this.token,
    required this.channelName,
  });

  @override
  _VideoCallScreenState createState()=> _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late RtcEngine _engine;
  int? _remoteUid;
  bool isEngineReady = false;

  @override
  void initState() {
    super.initState();
    _initAgoraEngine();
  }

  Future<void> _initAgoraEngine() async {
    await [Permission.camera, Permission.microphone].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(
      RtcEngineContext(
        appId: 'c42393923a754eba9a20b5c4ed70e0ce',
      ),
    );

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          print('Connecting to VideoCall... ${connection.channelId}');
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (connection, remoteUid, reason) {
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );

    await _engine.joinChannel(
      token: widget.token,
      channelId: widget.channelName,
      uid: widget.userId,
      options: ChannelMediaOptions(),
    );

    setState(() {
      isEngineReady = true;
    });
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isEngineReady) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Video Call'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Video Call'),
      ),
      body: Stack(
        children: [
          if (_remoteUid != null)
            AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: _engine,
                canvas: VideoCanvas(uid: _remoteUid),
                connection: RtcConnection(channelId: widget.channelName),
              ),
            )
          else
            Center(
              child: Text(
                'Waiting for Other User...',
                textAlign: TextAlign.center,
              ),
            ),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: 120,
              height: 150,
              child: AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: _engine,
                  canvas: const VideoCanvas(uid: 0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}