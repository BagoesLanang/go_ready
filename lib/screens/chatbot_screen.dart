import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../theme/colors.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // List buat nyimpen history chat: map isinya 'role' (user/ai) dan 'text'
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  @override
  void initState() {
    super.initState();
    _initChatbot();
  }

  // --- LOGIC SETUP GEMINI AI ---
  void _initChatbot() {
    // Inject persona asisten ke Gemini pake systemInstruction
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: 'AIzaSyAWfeALDIleYqp8R9twkKmV_77uFaQOcmo',
      systemInstruction: Content.system(
        'Kamu adalah asisten pintar untuk rekomendasi barang bawaan. '
        'Kamu hanya boleh menjawab hal yang berkaitan dengan packing, barang bawaan, outfit traveling, persiapan pergi, saran barang. '
        'Jika user bertanya di luar topik tersebut (misal: sejarah, matematika, politik, coding, dll), KAMU HARUS MENOLAK UNTUK MENJAWAB.'
        'DILARANG KERAS menggunakan format markdown. '
        'JANGAN PERNAH memunculkan simbol bintang (*) di jawabanmu. ' // 🔥 Kasih instruksi galak
        'Gunakan angka (1, 2, 3) atau strip (-) saja untuk membuat list barang.',
      ),
    );

    // Pake fitur chat session biar dia inget konteks obrolan
    _chatSession = _model.startChat();

    // Greeting awal dari AI
    setState(() {
      _messages.add({
        'role': 'ai',
        'text':
            'Halo brok! Mau ada plan kemana nih hari ini? Sini gw bantu list barang bawaannya biar gak ada yang ketinggalan!',
      });
    });
  }

  // --- LOGIC KIRIM PESAN ---
  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _isLoading = true;
    });
    _chatController.clear();
    _scrollToBottom();

    try {
      final response = await _chatSession.sendMessage(Content.text(text));

      String rawReply =
          response.text ?? 'Waduh, gw agak nge-blank nih. Coba ulangin bro.';
      String cleanReply = rawReply.replaceAll(
        '*',
        '',
      ); // Ngubah bintang satu jadi bullet point bulet

      setState(() {
        _messages.add({'role': 'ai', 'text': cleanReply.trim()});
      });
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'ai',
          'text':
              'Koneksi lagi trouble nih, cek API Key atau jaringan lu ya. Error: $e',
        });
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Packing Assistant',
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.grey),
        elevation: 0.5,
      ),
      body: Column(
        children: [
          // Area Chat
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['role'] == 'user';

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.primaryBlue : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      message['text']!,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Loading Indicator
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: CircularProgressIndicator(),
            ),

          // Area Input Text
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _chatController,
                      decoration: InputDecoration(
                        hintText: '...',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF3F4F6),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (text) => _sendMessage(text),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _sendMessage(_chatController.text),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
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
