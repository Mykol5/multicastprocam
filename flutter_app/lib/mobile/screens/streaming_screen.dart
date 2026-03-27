import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../providers/multicast_stream_provider.dart';

class StreamingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MultiCastStreamProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Now'),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              provider.stopStreaming();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.black,
              child: RTCVideoView(
                provider.localRenderer,
                mirror: true,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            color: Colors.grey.shade900,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text('LIVE', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    SizedBox(width: 20),
                    Icon(Icons.visibility, color: Colors.white),
                    SizedBox(width: 4),
                    Text('${provider.streamers.length} viewers', style: TextStyle(color: Colors.white)),
                  ],
                ),
                SizedBox(height: 10),
                Text('Room ID: ${provider.roomId}', style: TextStyle(color: Colors.white70)),
                SizedBox(height: 5),
                Text('Share this code with viewers', style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
