import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';  // Changed from webrtc

class StreamProvider extends ChangeNotifier {
  Socket? socket;
  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  MediaStream? remoteStream;
  
  bool isStreaming = false;
  bool isViewer = false;
  String roomId = '';
  String streamerName = '';
  List<Map<String, dynamic>> streamers = [];
  String? activeStreamerId;
  
  String get serverUrl {
    if (kReleaseMode) {
      return 'https://multicast-pro-signaling.onrender.com';
    }
    return 'http://localhost:3001';
  }
  
  final Map<String, dynamic> config = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
    ]
  };
  
  Future<void> initializeAsStreamer(String roomId, String name) async {
    this.roomId = roomId;
    this.streamerName = name;
    this.isStreaming = true;
    this.isViewer = false;
    
    await _connectToSocket();
    await _setupLocalStream();
    await _setupPeerConnectionForStreamer();
    
    notifyListeners();
  }
  
  Future<void> initializeAsViewer(String roomId) async {
    this.roomId = roomId;
    this.isViewer = true;
    this.isStreaming = false;
    
    await _connectToSocket();
    _setupSocketListenersForViewer();
    
    notifyListeners();
  }
  
  Future<void> _connectToSocket() async {
    socket = io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });
    
    socket!.onConnect((_) {
      print('Connected to signaling server');
      
      if (isStreaming) {
        socket!.emit('streamer-join', {
          'roomId': roomId,
          'streamerName': streamerName,
        });
      } else if (isViewer) {
        socket!.emit('viewer-join', roomId);
      }
    });
    
    socket!.onConnectError((data) => print('Connection error: $data'));
    socket!.onError((data) => print('Socket error: $data'));
  }
  
  Future<void> _setupLocalStream() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'facingMode': 'user',
        'width': {'ideal': 1280},
        'height': {'ideal': 720},
      }
    };
    
    try {
      localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      notifyListeners();
    } catch (e) {
      print('Error getting media: $e');
      rethrow;
    }
  }
  
  Future<void> _setupPeerConnectionForStreamer() async {
    peerConnection = await createPeerConnection(config);
    
    localStream!.getTracks().forEach((track) {
      peerConnection!.addTrack(track, localStream!);
    });
    
    socket!.on('offer', (data) async {
      await peerConnection!.setRemoteDescription(
        RTCSessionDescription(data['sdp']['sdp'], data['sdp']['type'])
      );
      
      final answer = await peerConnection!.createAnswer();
      await peerConnection!.setLocalDescription(answer);
      
      socket!.emit('answer', {
        'target': data['from'],
        'sdp': {
          'sdp': answer.sdp,
          'type': answer.type,
        },
        'streamerId': socket!.id,
      });
    });
    
    peerConnection!.onIceCandidate = (candidate) {
      if (candidate != null) {
        socket!.emit('ice-candidate', {
          'candidate': {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          },
        });
      }
    };
    
    peerConnection!.onIceConnectionState = (state) {
      print('ICE Connection State: $state');
    };
  }
  
  void _setupSocketListenersForViewer() {
    socket!.on('streamers-list', (List<dynamic> data) {
      streamers = List<Map<String, dynamic>>.from(data);
      if (streamers.isNotEmpty && activeStreamerId == null) {
        activeStreamerId = streamers[0]['streamerId'];
        _connectToStreamer(activeStreamerId!);
      }
      notifyListeners();
    });
    
    socket!.on('streamer-joined', (Map<String, dynamic> data) {
      streamers.add(data);
      notifyListeners();
    });
    
    socket!.on('streamer-left', (Map<String, dynamic> data) {
      streamers.removeWhere((s) => s['streamerId'] == data['streamerId']);
      if (activeStreamerId == data['streamerId']) {
        activeStreamerId = streamers.isNotEmpty ? streamers[0]['streamerId'] : null;
        if (activeStreamerId != null) {
          _connectToStreamer(activeStreamerId!);
        }
      }
      notifyListeners();
    });
    
    socket!.on('offer', (Map<String, dynamic> data) async {
      await _handleOffer(data);
    });
    
    socket!.on('answer', (Map<String, dynamic> data) async {
      if (peerConnection != null) {
        await peerConnection!.setRemoteDescription(
          RTCSessionDescription(data['sdp']['sdp'], data['sdp']['type'])
        );
      }
    });
    
    socket!.on('ice-candidate', (Map<String, dynamic> data) async {
      if (peerConnection != null && data['candidate'] != null) {
        await peerConnection!.addCandidate(
          RTCIceCandidate(
            data['candidate']['candidate'],
            data['candidate']['sdpMid'],
            data['candidate']['sdpMLineIndex'],
          )
        );
      }
    });
  }
  
  Future<void> _connectToStreamer(String streamerId) async {
    activeStreamerId = streamerId;
    
    if (peerConnection != null) {
      await peerConnection!.close();
    }
    
    peerConnection = await createPeerConnection(config);
    
    peerConnection!.onTrack = (event) {
      if (remoteStream != event.streams[0]) {
        remoteStream = event.streams[0];
        notifyListeners();
      }
    };
    
    peerConnection!.onIceCandidate = (candidate) {
      if (candidate != null) {
        socket!.emit('ice-candidate', {
          'target': streamerId,
          'candidate': {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          },
        });
      }
    };
    
    final offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);
    
    socket!.emit('offer', {
      'target': streamerId,
      'sdp': {
        'sdp': offer.sdp,
        'type': offer.type,
      },
      'streamerId': socket!.id,
    });
    
    notifyListeners();
  }
  
  Future<void> _handleOffer(Map<String, dynamic> data) async {
    if (peerConnection == null) {
      peerConnection = await createPeerConnection(config);
      
      peerConnection!.onTrack = (event) {
        if (remoteStream != event.streams[0]) {
          remoteStream = event.streams[0];
          notifyListeners();
        }
      };
    }
    
    await peerConnection!.setRemoteDescription(
      RTCSessionDescription(data['sdp']['sdp'], data['sdp']['type'])
    );
    
    final answer = await peerConnection!.createAnswer();
    await peerConnection!.setLocalDescription(answer);
    
    socket!.emit('answer', {
      'target': data['from'],
      'sdp': {
        'sdp': answer.sdp,
        'type': answer.type,
      },
      'streamerId': socket!.id,
    });
  }
  
  Future<RTCPeerConnection> createPeerConnection(Map<String, dynamic> config) async {
    return await createPeerConnection(config);
  }
  
  void switchStreamer(String streamerId) {
    if (activeStreamerId != streamerId) {
      _connectToStreamer(streamerId);
    }
  }
  
  void stopStreaming() {
    localStream?.getTracks().forEach((track) {
      track.stop();
    });
    peerConnection?.close();
    socket?.disconnect();
    isStreaming = false;
    notifyListeners();
  }
  
  @override
  void dispose() {
    stopStreaming();
    super.dispose();
  }
}
