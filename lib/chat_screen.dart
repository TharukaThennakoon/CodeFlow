import 'package:flutter/material.dart';
import 'models.dart';

class ChatScreen extends StatefulWidget {
  final Project project;
  final User currentUser;
  final Function(Project) onProjectUpdate;
  final VoidCallback onAddMember;
  final VoidCallback onToggleSidebar;
  final VoidCallback onShowMembers;
  
  const ChatScreen({
    super.key,
    required this.project,
    required this.currentUser,
    required this.onProjectUpdate,
    required this.onAddMember,
    required this.onToggleSidebar,
    required this.onShowMembers,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _codeTitleController = TextEditingController();
  bool _isCodeMode = false;
  String _selectedLanguage = 'typescript';
  
  final List<String> _languages = [
    'plaintext', 'typescript', 'javascript', 'python', 'csharp', 
    'java', 'go', 'rust', 'sql', 'html', 'css', 'json', 'dart'
  ];
  
  final ScrollController _scrollController = ScrollController();
  final ScrollController _codeScrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }
  
  @override
  void didUpdateWidget(ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.project.messages.length != widget.project.messages.length) {
      _scrollToBottom();
    }
  }
  
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  
  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    final newMessage = Message(
      id: DateTime.now().toString(),
      sender: widget.currentUser.name,
      senderId: widget.currentUser.id,
      content: _messageController.text,
      timestamp: DateTime.now(),
      type: _isCodeMode ? MessageType.code : MessageType.text,
      language: _isCodeMode ? _selectedLanguage : null,
      codeTitle: _isCodeMode && _codeTitleController.text.isNotEmpty 
          ? _codeTitleController.text 
          : null,
    );
    
    final updatedProject = widget.project;
    updatedProject.messages.add(newMessage);
    widget.onProjectUpdate(updatedProject);
    _messageController.clear();
    _codeTitleController.clear();
    
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollToBottom();
    });
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    _codeTitleController.dispose();
    _scrollController.dispose();
    _codeScrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      body: Column(
        children: [
          // Chat header - Modern and clean
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF27005D),
                  const Color(0xFF9400FF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF27005D).withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                if (isSmallScreen)
                  IconButton(
                    onPressed: widget.onToggleSidebar,
                    icon: const Icon(Icons.menu, color: Colors.white, size: 22),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                if (isSmallScreen) const SizedBox(width: 4),
                
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.chat, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.project.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      GestureDetector(
                        onTap: widget.onShowMembers,
                        child: Row(
                          children: [
                            const Icon(Icons.people_outline, color: Colors.white70, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.project.members.length} members',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: widget.onAddMember,
                        icon: const Icon(Icons.person_add, color: Colors.white, size: 20),
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                      IconButton(
                        onPressed: widget.onShowMembers,
                        icon: const Icon(Icons.group, color: Colors.white, size: 20),
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Messages area - Soft background
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFF5F0FF),
                    const Color(0xFFF0EAFF),
                  ],
                ),
              ),
              child: ListView.builder(
                controller: _scrollController,
                reverse: true,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemCount: widget.project.messages.length,
                itemBuilder: (context, index) {
                  final message = widget.project.messages[widget.project.messages.length - 1 - index];
                  final isOwnMessage = message.senderId == widget.currentUser.id;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Align(
                      alignment: isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: isOwnMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          if (!isOwnMessage)
                            Padding(
                              padding: const EdgeInsets.only(left: 8, bottom: 4),
                              child: Text(
                                message.sender,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF9400FF),
                                ),
                              ),
                            ),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: screenWidth * 0.8,
                            ),
                            child: Container(
                              padding: message.type == MessageType.code 
                                  ? const EdgeInsets.all(14) 
                                  : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: message.type == MessageType.code
                                    ? const LinearGradient(
                                        colors: [Color(0xFF1A0033), Color(0xFF27005D)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : (isOwnMessage 
                                        ? const LinearGradient(
                                            colors: [Color(0xFF9400FF), Color(0xFF7A00CC)],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )
                                        : null),
                                color: message.type == MessageType.code
                                    ? null
                                    : (isOwnMessage ? null : Colors.white),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: Radius.circular(isOwnMessage ? 16 : 4),
                                  bottomRight: Radius.circular(isOwnMessage ? 4 : 16),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF27005D).withOpacity(0.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: message.type == MessageType.code
                                  ? _buildCodeMessage(message, isSmallScreen)
                                  : Text(
                                      message.content,
                                      style: TextStyle(
                                        color: isOwnMessage ? Colors.white : const Color(0xFF27005D),
                                        fontSize: isSmallScreen ? 14 : 15,
                                        height: 1.4,
                                      ),
                                      softWrap: true,
                                    ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8, top: 6),
                            child: Text(
                              _formatTime(message.timestamp),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFFAED2FF),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Input area - Modern and clean
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF27005D).withOpacity(0.06),
                  blurRadius: 15,
                  offset: const Offset(0, -4),
                ),
              ],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Toggle buttons and language selector
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildToggleButton('Chat', !_isCodeMode, isSmallScreen),
                      const SizedBox(width: 8),
                      _buildToggleButton('Code', _isCodeMode, isSmallScreen),
                      const SizedBox(width: 8),
                      if (_isCodeMode)
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: isSmallScreen ? 90 : 110,
                          ),
                          child: DropdownButton<String>(
                            value: _selectedLanguage,
                            items: _languages.map((lang) {
                              return DropdownMenuItem(
                                value: lang,
                                child: Text(
                                  lang.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedLanguage = value!;
                              });
                            },
                            underline: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF9400FF), Color(0xFF27005D)],
                                ),
                              ),
                            ),
                            isExpanded: true,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF27005D),
                              fontWeight: FontWeight.w600,
                            ),
                            iconSize: 16,
                          ),
                        ),
                    ],
                  ),
                ),
                
                if (_isCodeMode) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: _codeTitleController,
                    style: const TextStyle(color: Color(0xFF27005D), fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Title (optional)',
                      hintStyle: TextStyle(
                        color: const Color(0xFFAED2FF).withOpacity(0.7),
                        fontSize: 12,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F0FF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF9400FF), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      isDense: true,
                      prefixIcon: const Icon(Icons.title, color: Color(0xFF9400FF), size: 18),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                
                // Message input with send button - Modern design
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F0FF),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: const Color(0xFF9400FF).withOpacity(0.15),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          style: const TextStyle(
                            color: Color(0xFF27005D), 
                            fontSize: 14,
                          ),
                          maxLines: 4,
                          minLines: 1,
                          onSubmitted: (_) => _sendMessage(),
                          decoration: InputDecoration(
                            hintText: _isCodeMode ? 'Paste your code here...' : 'Type a message...',
                            hintStyle: TextStyle(
                              color: const Color(0xFF27005D).withOpacity(0.35),
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            isDense: true,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _messageController.text.trim().isEmpty 
                                ? [const Color(0xFFAED2FF).withOpacity(0.5), const Color(0xFFAED2FF).withOpacity(0.3)]
                                : [const Color(0xFF9400FF), const Color(0xFF7A00CC)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            if (!_messageController.text.trim().isEmpty)
                              BoxShadow(
                                color: const Color(0xFF9400FF).withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: _messageController.text.trim().isEmpty ? null : _sendMessage,
                          icon: Icon(
                            Icons.send_rounded,
                            color: _messageController.text.trim().isEmpty 
                                ? const Color(0xFFAED2FF) 
                                : Colors.white,
                            size: 20,
                          ),
                          padding: const EdgeInsets.all(10),
                          constraints: const BoxConstraints(minWidth: 42, minHeight: 42),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildToggleButton(String text, bool isActive, bool isSmallScreen) {
    return GestureDetector(
      onTap: () => setState(() => _isCodeMode = !_isCodeMode),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 16 : 20,
          vertical: isSmallScreen ? 6 : 8,
        ),
        decoration: BoxDecoration(
          gradient: isActive 
              ? const LinearGradient(
                  colors: [Color(0xFF27005D), Color(0xFF9400FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Colors.transparent, Colors.transparent],
                ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.transparent : const Color(0xFF9400FF),
            width: 1.5,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF9400FF),
            fontWeight: FontWeight.w600,
            fontSize: isSmallScreen ? 12 : 13,
          ),
        ),
      ),
    );
  }
  
  Widget _buildCodeMessage(Message message, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9400FF), Color(0xFF7A00CC)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                message.language?.toUpperCase() ?? 'CODE',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            if (message.codeTitle != null && message.codeTitle!.isNotEmpty) ...[
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message.codeTitle!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFAED2FF),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Container(
          constraints: BoxConstraints(
            maxHeight: isSmallScreen ? 150 : 200,
            minHeight: 40,
          ),
          child: SingleChildScrollView(
            controller: _codeScrollController,
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0020),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF9400FF).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: SelectableText(
                  message.content,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: Color(0xFFB8B0FF),
                    height: 1.6,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (message.content.split('\n').length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '${message.content.split('\n').length} lines',
              style: const TextStyle(
                fontSize: 9,
                color: Color(0xFF9400FF),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
  
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${time.day}/${time.month}/${time.year}';
  }
}