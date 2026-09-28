import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class VideoCallScreen extends StatefulWidget {
  final String doctorName;
  final String roomId;

  const VideoCallScreen({super.key, required this.doctorName, required this.roomId});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool _muted = false;
  bool _cameraOff = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07111F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text('Video Consultation', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
              child: Center(
                child: _cameraOff
                    ? const Icon(Icons.videocam_off_rounded, color: Colors.white70, size: 72)
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 52,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            child: const Icon(Icons.person_rounded, color: Colors.white, size: 58),
                          ),
                          const SizedBox(height: 16),
                          Text(widget.doctorName, style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                          Text('Waiting for doctor to join...', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 28,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _callButton(_muted ? Icons.mic_off_rounded : Icons.mic_rounded, () => setState(() => _muted = !_muted)),
                _callButton(_cameraOff ? Icons.videocam_off_rounded : Icons.videocam_rounded, () => setState(() => _cameraOff = !_cameraOff)),
                _callButton(Icons.call_end_rounded, () => Navigator.pop(context), color: AppTheme.danger),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _callButton(IconData icon, VoidCallback onPressed, {Color? color}) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      style: IconButton.styleFrom(
        backgroundColor: color ?? AppTheme.bgCard2,
        padding: const EdgeInsets.all(16),
      ),
    );
  }
}