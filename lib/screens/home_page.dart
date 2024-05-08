import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'signaling.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Signaling? _signaling;
  List<dynamic> _peers = [];
  String? _selfId;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  bool _inCalling = false;
  Session? _session;
  bool _waitAccept = false;

  @override
  initState() {
    super.initState();
    initRenderers();
    _connect(context);
  }

  @override
  void deactivate() {
    super.deactivate();
    _signaling?.close();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
  }

  void initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  void _connect(BuildContext context) async {
    _signaling ??= Signaling('localhost', context)..connect();
    _signaling?.onSignalingStateChange = (SignalingState state) {
      switch (state) {
        case SignalingState.connectionClosed:
        case SignalingState.connectionError:
        case SignalingState.connectionOpen:
          break;
      }
    };

    _signaling?.onCallStateChange = (Session session, CallState state) async {
      switch (state) {
        case CallState.callStateNew:
          setState(() {
            _session = session;
          });
          break;
        case CallState.callStateRinging:
          bool? accept = await _showAcceptDialog();
          if (accept!) {
            _accept();
            setState(() {
              _inCalling = true;
            });
          } else {
            _reject();
          }
          break;
        case CallState.callStateBye:
          if (_waitAccept) {
            print('peer reject');
            _waitAccept = false;
            Navigator.of(context).pop(false);
          }
          setState(() {
            _localRenderer.srcObject = null;
            _remoteRenderer.srcObject = null;
            _inCalling = false;
            _session = null;
          });
          break;
        case CallState.callStateInvite:
          _waitAccept = true;
          _showInviteDialog();
          break;
        case CallState.callStateConnected:
          if (_waitAccept) {
            _waitAccept = false;
            Navigator.of(context).pop(false);
          }
          setState(() {
            _inCalling = true;
          });

          break;
      }
    };

    _signaling?.onPeersUpdate = ((event) {
      setState(() {
        _selfId = event['self'];
        _peers = event['peers'];
      });
    });

    _signaling?.onLocalStream = ((stream) {
      _localRenderer.srcObject = stream;
      setState(() {});
    });

    _signaling?.onAddRemoteStream = ((_, stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });

    _signaling?.onRemoveRemoteStream = ((_, stream) {
      _remoteRenderer.srcObject = null;
    });
  }

  Future<bool?> _showAcceptDialog() {
    return showDialog<bool?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("New Call"),
          content: Text("Accept?"),
          actions: <Widget>[
            MaterialButton(
              child: Text(
                'Reject',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            MaterialButton(
              child: Text(
                'Accept',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showInviteDialog() {
    return showDialog<bool?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Invited User"),
          content: Text("Waiting"),
          actions: <Widget>[
            TextButton(
              child: Text("cancel"),
              onPressed: () {
                Navigator.of(context).pop(false);
                _hangUp();
              },
            ),
          ],
        );
      },
    );
  }

  void _invitePeer(BuildContext context, String peerId, bool useScreen) async {
    if (_signaling != null && peerId != _selfId) {
      _signaling?.invite(peerId, 'video', useScreen);
    }
  }

  void _accept() {
    if (_session != null) {
      _signaling?.accept(_session!.sid, 'video');
    }
  }

  void _reject() {
    if (_session != null) {
      _signaling?.reject(_session!.sid);
    }
  }

  void _hangUp() {
    if (_session != null) {
      _signaling?.bye(_session!.sid);
    }
  }

  void _switchCamera() {
    _signaling?.switchCamera();
  }

  void _muteMic() {
    _signaling?.muteMic();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebRTC with Flutter'),
      ),
      body: SafeArea(
        child: _inCalling
            ? OrientationBuilder(
                builder: (context, orientation) {
                  return Stack(
                    children: <Widget>[
                      Positioned(
                        left: 0.0,
                        right: 0.0,
                        top: 0.0,
                        bottom: 0.0,
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          decoration:
                              const BoxDecoration(color: Colors.black54),
                          child: RTCVideoView(_remoteRenderer),
                        ),
                      ),
                      Positioned(
                        left: 20.0,
                        top: 20.0,
                        child: Container(
                          width: orientation == Orientation.portrait
                              ? 90.0
                              : 120.0,
                          height: orientation == Orientation.portrait
                              ? 120.0
                              : 90.0,
                          decoration:
                              const BoxDecoration(color: Colors.black54),
                          child: RTCVideoView(_localRenderer, mirror: true),
                        ),
                      ),
                    ],
                  );
                },
              )
            : ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(0.0),
                itemCount: (_peers.length),
                itemBuilder: (context, i) {
                  var peer = _peers[i];
                  var self = (peer['id'] == _selfId);
                  return ListBody(
                    children: <Widget>[
                      ListTile(
                        title: Text(self
                            ? peer['name'] +
                                ', ID: ${peer['id']} ' +
                                ' [Your self]'
                            : peer['name'] + ', ID: ${peer['id']} '),
                        onTap: null,
                        trailing: SizedBox(
                          width: 100.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              if (!self)
                                IconButton(
                                  icon: Icon(
                                      self ? Icons.close : Icons.videocam,
                                      color: self ? Colors.grey : Colors.black),
                                  onPressed: () =>
                                      _invitePeer(context, peer['id'], false),
                                  tooltip: 'Video calling',
                                ),
                            ],
                          ),
                        ),
                        subtitle: Text('[' + peer['user_agent'] + ']'),
                      ),
                      const Divider(),
                    ],
                  );
                },
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _inCalling
          ? SizedBox(
              width: 240.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FloatingActionButton(
                    tooltip: 'Camera',
                    onPressed: _switchCamera,
                    child: const Icon(Icons.switch_camera),
                  ),
                  FloatingActionButton(
                    onPressed: _hangUp,
                    tooltip: 'Hangup',
                    backgroundColor: Colors.pink,
                    child: const Icon(Icons.call_end),
                  ),
                  FloatingActionButton(
                    tooltip: 'Mute Mic',
                    onPressed: _muteMic,
                    child: const Icon(Icons.mic_off),
                  )
                ],
              ),
            )
          : null,
    );
  }
}
