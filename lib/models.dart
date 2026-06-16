class Project {
  final String id;
  String name;
  List<ProjectMember> members;
  List<Message> messages;
  String adminId;
  
  Project({
    required this.id,
    required this.name,
    required this.members,
    required this.messages,
    required this.adminId,
  });
}

class ProjectMember {
  final String id;
  final String name;
  final String email;
  MemberRole role;
  final String? avatarUrl;
  final DateTime joinedAt;
  
  ProjectMember({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
    required this.joinedAt,
  });
}

enum MemberRole {
  admin,
  member,
}

class Message {
  final String id;
  final String sender;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final String? language;
  final String? codeTitle;
  
  Message({
    required this.id,
    required this.sender,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.type,
    this.language,
    this.codeTitle,
  });
}

enum MessageType {
  text,
  code,
}

class User {
  final String id;
  String name;
  String email;
  String? avatarUrl;
  String? bio;
  final DateTime joinedAt;
  
  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.bio,
    required this.joinedAt,
  });
}