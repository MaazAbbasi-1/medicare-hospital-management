import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class AiChatScreen extends StatefulWidget {
  final String doctorName;
  final String problem;

  const AiChatScreen({super.key, required this.doctorName, required this.problem});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];

  @override
  void initState() {
    super.initState();
    _messages.add({'sender': 'AI Assistant', 'text': 'Hello! I can help you prepare for your consultation with ${widget.doctorName}. What would you like to discuss?'});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'sender': 'You', 'text': text});
      _messages.add({'sender': 'AI Assistant', 'text': 'Thanks for sharing. Please mention how long you have had this issue and contact your doctor for medical advice.'});
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: Text(
          'AI Health Chat',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, index) {
                final message = _messages[index];
                final isUser = message['sender'] == 'You';
                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(13),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? AppTheme.primary : AppTheme.bgCard,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      message['text']!,
                      style: GoogleFonts.poppins(
                        color: isUser ? Colors.white : AppTheme.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Ask a health question...',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _send,
                    icon: const Icon(Icons.send_rounded),
                    color: AppTheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}