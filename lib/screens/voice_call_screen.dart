import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class VoiceCallScreen extends StatefulWidget {
  final String doctorName;
  final String roomId;

  const VoiceCallScreen({super.key, required this.doctorName, required this.roomId});

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> {
  bool _muted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07111F),
      appBar: AppBar(backgroundColor: Colors.transparent, foregroundColor: Colors.white, title: Text('Voice Consultation', style: GoogleFonts.poppins(fontWeight: FontWeight.w700))),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(radius: 64, backgroundColor: Colors.white24, child: Icon(Icons.person_rounded, color: Colors.white, size: 70)),
              const SizedBox(height: 20),
              Text(widget.doctorName, style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
              Text('Waiting for doctor to join...', style: GoogleFonts.poppins(color: Colors.white70)),
              const SizedBox(height: 60),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                IconButton(onPressed: () => setState(() => _muted = !_muted), icon: Icon(_muted ? Icons.mic_off_rounded : Icons.mic_rounded, color: Colors.white), style: IconButton.styleFrom(backgroundColor: AppTheme.bgCard2, padding: const EdgeInsets.all(16))),
                const SizedBox(width: 28),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.call_end_rounded, color: Colors.white), style: IconButton.styleFrom(backgroundColor: AppTheme.danger, padding: const EdgeInsets.all(16))),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}