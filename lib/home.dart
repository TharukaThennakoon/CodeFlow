import 'package:flutter/material.dart';
import 'models.dart';
import 'chat_screen.dart';
import 'login.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  
  const HomeScreen({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<Project> projects = [];
  Project? selectedProject;
  bool isSidebarOpen = true;
  bool isMobile = false;
  late AnimationController _animationController;
  
  User currentUser = User(
    id: '1',
    name: 'Tharuka Thennakoon',
    email: 'tharukathennakoon214@gmail.com',
    joinedAt: DateTime.now(),
    bio: 'Full-stack developer | Flutter enthusiast',
  );
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    projects = [
      Project(
        id: '1',
        name: 'Project01',
        adminId: '1',
        members: [
          ProjectMember(
            id: '1',
            name: 'Tharuka Thennakoon',
            email: 'tharukathennakoon214@gmail.com',
            role: MemberRole.admin,
            joinedAt: DateTime.now(),
          ),
          ProjectMember(
            id: '2',
            name: 'John Doe',
            email: 'john@dev.io',
            role: MemberRole.member,
            joinedAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
          ProjectMember(
            id: '3',
            name: 'Jane Smith',
            email: 'jane@dev.io',
            role: MemberRole.member,
            joinedAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
        messages: [
          Message(
            id: '1',
            sender: 'Tharuka Thennakoon',
            senderId: '1',
            content: 'What is the error on it',
            timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
            type: MessageType.text,
          ),
        ],
      ),
      Project(
        id: '2',
        name: 'Mobile App',
        adminId: '1',
        members: [
          ProjectMember(
            id: '1',
            name: 'Tharuka Thennakoon',
            email: 'tharukathennakoon214@gmail.com',
            role: MemberRole.admin,
            joinedAt: DateTime.now(),
          ),
          ProjectMember(
            id: '4',
            name: 'Alice Johnson',
            email: 'alice@dev.io',
            role: MemberRole.member,
            joinedAt: DateTime.now().subtract(const Duration(days: 3)),
          ),
        ],
        messages: [],
      ),
    ];
    selectedProject = projects.first;
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _createProject() {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text(
            'Create Project',
            style: TextStyle(color: Color(0xFF27005D), fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: nameController,
            autofocus: true,
            style: const TextStyle(color: Color(0xFF27005D)),
            decoration: InputDecoration(
              hintText: 'Project name',
              hintStyle: TextStyle(color: const Color(0xFFAED2FF).withOpacity(0.6)),
              filled: true,
              fillColor: const Color(0xFFE4F1FF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF9400FF), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF9400FF))),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  setState(() {
                    final newProject = Project(
                      id: DateTime.now().toString(),
                      name: nameController.text.trim(),
                      adminId: currentUser.id,
                      members: [
                        ProjectMember(
                          id: currentUser.id,
                          name: currentUser.name,
                          email: currentUser.email,
                          role: MemberRole.admin,
                          joinedAt: DateTime.now(),
                        ),
                      ],
                      messages: [],
                    );
                    projects.add(newProject);
                    selectedProject = newProject;
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Create', style: TextStyle(color: Color(0xFF27005D), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
  
  void _deleteProject(Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete Project', style: TextStyle(color: Color(0xFF27005D), fontWeight: FontWeight.bold)),
        content: Text(
          'Delete "${project.name}"? This action cannot be undone.',
          style: const TextStyle(color: Color(0xFF9400FF)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF9400FF))),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                projects.remove(project);
                if (selectedProject == project) {
                  selectedProject = projects.isNotEmpty ? projects.first : null;
                }
              });
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Color(0xFF27005D), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
  
  void _addMember() {
    final emailController = TextEditingController();
    bool isInviteLink = false;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text('Add Member', style: TextStyle(color: Color(0xFF27005D), fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setStateDialog(() => isInviteLink = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: !isInviteLink ? const Color(0xFF27005D) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Email',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: !isInviteLink ? const Color(0xFFE4F1FF) : const Color(0xFF9400FF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setStateDialog(() => isInviteLink = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isInviteLink ? const Color(0xFF27005D) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Invite Link',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isInviteLink ? const Color(0xFFE4F1FF) : const Color(0xFF9400FF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (!isInviteLink)
                  TextField(
                    controller: emailController,
                    autofocus: true,
                    style: const TextStyle(color: Color(0xFF27005D)),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Member email',
                      hintStyle: TextStyle(color: const Color(0xFFAED2FF).withOpacity(0.6)),
                      prefixIcon: const Icon(Icons.email, color: Color(0xFF9400FF), size: 20),
                      filled: true,
                      fillColor: const Color(0xFFE4F1FF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF9400FF), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4F1FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'https://devsync.io/invite/${selectedProject?.id}',
                            style: const TextStyle(
                              color: Color(0xFF27005D),
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Invite link copied!'),
                                backgroundColor: Color(0xFF27005D),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy, color: Color(0xFF9400FF), size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Color(0xFF9400FF))),
              ),
              TextButton(
                onPressed: () {
                  if (emailController.text.trim().isNotEmpty && selectedProject != null) {
                    setState(() {
                      final newMember = ProjectMember(
                        id: DateTime.now().toString(),
                        name: emailController.text.split('@')[0],
                        email: emailController.text.trim(),
                        role: MemberRole.member,
                        joinedAt: DateTime.now(),
                      );
                      selectedProject!.members.add(newMember);
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add', style: TextStyle(color: Color(0xFF27005D), fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }
  
  void _showMembersDialog() {
    if (selectedProject == null) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFAED2FF),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Text(
                        'Team Members',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF27005D),
                        ),
                      ),
                      const Spacer(),
                      if (_isAdmin())
                        IconButton(
                          onPressed: _addMember,
                          icon: const Icon(Icons.person_add, color: Color(0xFF9400FF)),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: selectedProject!.members.length,
                    itemBuilder: (context, index) {
                      final member = selectedProject!.members[index];
                      final isAdmin = member.role == MemberRole.admin;
                      final isCurrentUser = member.id == currentUser.id;
                      final canManage = _isAdmin() && !isCurrentUser;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isAdmin 
                                ? const Color(0xFF27005D) 
                                : const Color(0xFFAED2FF),
                            child: Text(
                              member.name[0].toUpperCase(),
                              style: TextStyle(
                                color: isAdmin ? Colors.white : const Color(0xFF27005D),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            member.name,
                            style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF27005D)),
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                member.email,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color(0xFF9400FF),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (isAdmin)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  margin: const EdgeInsets.only(top: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF27005D),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Admin',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          trailing: canManage
                              ? PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert, color: Color(0xFF9400FF)),
                                  onSelected: (value) {
                                    if (value == 'remove') {
                                      _removeMember(member);
                                    } else if (value == 'make_admin') {
                                      _makeAdmin(member);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    if (!isAdmin)
                                      const PopupMenuItem(
                                        value: 'make_admin',
                                        child: Row(
                                          children: [
                                            Icon(Icons.admin_panel_settings, color: Color(0xFF27005D), size: 18),
                                            SizedBox(width: 8),
                                            Text('Make Admin', style: TextStyle(color: Color(0xFF27005D))),
                                          ],
                                        ),
                                      ),
                                    const PopupMenuItem(
                                      value: 'remove',
                                      child: Row(
                                        children: [
                                          Icon(Icons.person_remove, color: Color(0xFF27005D), size: 18),
                                          SizedBox(width: 8),
                                          Text('Remove Member', style: TextStyle(color: Color(0xFF27005D))),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  void _removeMember(ProjectMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Remove Member', style: TextStyle(color: Color(0xFF27005D), fontWeight: FontWeight.bold)),
        content: Text(
          'Remove "${member.name}" from this project?',
          style: const TextStyle(color: Color(0xFF9400FF)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF9400FF))),
          ),
          TextButton(
            onPressed: () {
              if (selectedProject != null) {
                setState(() {
                  selectedProject!.members.removeWhere((m) => m.id == member.id);
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Remove', style: TextStyle(color: Color(0xFF27005D), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
  
  void _makeAdmin(ProjectMember member) {
    if (selectedProject != null) {
      setState(() {
        final index = selectedProject!.members.indexWhere((m) => m.id == member.id);
        if (index != -1) {
          selectedProject!.members[index].role = MemberRole.admin;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${member.name} is now an admin'),
          backgroundColor: const Color(0xFF27005D),
        ),
      );
    }
  }
  
  bool _isAdmin() {
    if (selectedProject == null) return false;
    final member = selectedProject!.members.firstWhere(
      (m) => m.id == currentUser.id,
      orElse: () => ProjectMember(
        id: '',
        name: '',
        email: '',
        role: MemberRole.member,
        joinedAt: DateTime.now(),
      ),
    );
    return member.role == MemberRole.admin;
  }
  
  void _editProfile() {
    final nameController = TextEditingController(text: currentUser.name);
    final bioController = TextEditingController(text: currentUser.bio ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Edit Profile', style: TextStyle(color: Color(0xFF27005D), fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFFAED2FF).withOpacity(0.3),
              child: Text(
                currentUser.name[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF27005D),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              style: const TextStyle(color: Color(0xFF27005D)),
              decoration: InputDecoration(
                labelText: 'Display Name',
                labelStyle: const TextStyle(color: Color(0xFF9400FF)),
                filled: true,
                fillColor: const Color(0xFFE4F1FF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF9400FF), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bioController,
              style: const TextStyle(color: Color(0xFF27005D)),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Bio',
                labelStyle: const TextStyle(color: Color(0xFF9400FF)),
                filled: true,
                fillColor: const Color(0xFFE4F1FF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF9400FF), width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF9400FF))),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                currentUser.name = nameController.text;
                currentUser.bio = bioController.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: Color(0xFF27005D), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
  
  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Logout', style: TextStyle(color: Color(0xFF27005D), fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to logout?', style: TextStyle(color: Color(0xFF9400FF))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF9400FF))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text('Logout', style: TextStyle(color: Color(0xFF27005D), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    isMobile = screenWidth < 600;
    
    return Scaffold(
      backgroundColor: const Color(0xFFE4F1FF),
      body: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
    );
  }
  
  Widget _buildMobileLayout() {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isSidebarOpen ? MediaQuery.of(context).size.width : 0,
          child: isSidebarOpen ? _buildMobileSidebar() : const SizedBox(),
        ),
        if (!isSidebarOpen)
          Expanded(
            child: selectedProject != null
                ? ChatScreen(
                    project: selectedProject!,
                    currentUser: currentUser,
                    onProjectUpdate: (updatedProject) {
                      setState(() {
                        final index = projects.indexWhere((p) => p.id == updatedProject.id);
                        if (index != -1) {
                          projects[index] = updatedProject;
                          selectedProject = updatedProject;
                        }
                      });
                    },
                    onAddMember: _addMember,
                    onToggleSidebar: () => setState(() => isSidebarOpen = true),
                    onShowMembers: _showMembersDialog,
                  )
                : _buildEmptyState(),
          ),
      ],
    );
  }
  
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isSidebarOpen ? 280 : 0,
          child: isSidebarOpen ? _buildDesktopSidebar() : const SizedBox(),
        ),
        Expanded(
          child: selectedProject != null
              ? ChatScreen(
                  project: selectedProject!,
                  currentUser: currentUser,
                  onProjectUpdate: (updatedProject) {
                    setState(() {
                      final index = projects.indexWhere((p) => p.id == updatedProject.id);
                      if (index != -1) {
                        projects[index] = updatedProject;
                        selectedProject = updatedProject;
                      }
                    });
                  },
                  onAddMember: _addMember,
                  onToggleSidebar: () => setState(() => isSidebarOpen = false),
                  onShowMembers: _showMembersDialog,
                )
              : _buildEmptyState(),
        ),
      ],
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF27005D), Color(0xFF9400FF)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: Text(
                '</>',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE4F1FF),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Select or create a project',
            style: TextStyle(
              fontSize: 16,
              color: const Color(0xFF9400FF).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _createProject,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF27005D),
              foregroundColor: const Color(0xFFE4F1FF),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Create Project', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMobileSidebar() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE4F1FF))),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF27005D), Color(0xFF9400FF)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      '</>',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE4F1FF),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'devsync',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF27005D),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => setState(() => isSidebarOpen = false),
                  icon: const Icon(Icons.close, color: Color(0xFF9400FF)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),
          
          InkWell(
            onTap: _editProfile,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE4F1FF))),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFFAED2FF).withOpacity(0.3),
                    child: Text(
                      currentUser.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF27005D),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentUser.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF27005D),
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          currentUser.email,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9400FF),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.edit, color: Color(0xFF9400FF), size: 16),
                ],
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 4),
            child: Row(
              children: [
                const Text(
                  'Projects',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF27005D),
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _createProject,
                  icon: const Icon(Icons.add, size: 18, color: Color(0xFF9400FF)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                ),
              ],
            ),
          ),
          
          Expanded(
            flex: 2,
            child: projects.isEmpty
                ? Center(
                    child: Text(
                      'No projects yet',
                      style: TextStyle(
                        color: const Color(0xFFAED2FF).withOpacity(0.6),
                        fontSize: 13,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${projects.length} project${projects.length > 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 11,
                              color: const Color(0xFFAED2FF),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: ListView.builder(
                          itemCount: projects.length,
                          itemBuilder: (context, index) {
                            final project = projects[index];
                            return ListTile(
                              selected: selectedProject == project,
                              selectedTileColor: const Color(0xFFE4F1FF),
                              leading: const Icon(Icons.folder, color: Color(0xFF9400FF), size: 18),
                              title: Text(
                                project.name,
                                style: TextStyle(
                                  fontWeight: selectedProject == project ? FontWeight.bold : FontWeight.normal,
                                  color: const Color(0xFF27005D),
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        selectedProject = project;
                                        isSidebarOpen = false;
                                      });
                                    },
                                    icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF9400FF), size: 16),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                  ),
                                  IconButton(
                                    onPressed: () => _deleteProject(project),
                                    icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFF27005D)),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                  ),
                                ],
                              ),
                              onTap: () {
                                setState(() {
                                  selectedProject = project;
                                  isSidebarOpen = false;
                                });
                              },
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
          
          if (selectedProject != null) ...[
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.group, color: Color(0xFF9400FF), size: 18),
              title: const Text(
                'Team Members',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF27005D),
                  fontSize: 13,
                ),
              ),
              trailing: Text(
                '${selectedProject!.members.length}',
                style: const TextStyle(
                  color: Color(0xFF9400FF),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: _showMembersDialog,
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            ),
          ],
          
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Color(0xFF27005D), size: 18),
            title: const Text(
              'Logout',
              style: TextStyle(
                color: Color(0xFF27005D),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: _logout,
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
  
  Widget _buildDesktopSidebar() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF27005D).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE4F1FF))),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF27005D), Color(0xFF9400FF)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      '</>',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE4F1FF),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'devsync',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF27005D),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => setState(() => isSidebarOpen = false),
                  icon: const Icon(Icons.chevron_left, color: Color(0xFF9400FF)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),
          
          InkWell(
            onTap: _editProfile,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE4F1FF))),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFAED2FF).withOpacity(0.3),
                    child: Text(
                      currentUser.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF27005D),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentUser.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF27005D),
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          currentUser.email,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9400FF),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.edit, color: Color(0xFF9400FF), size: 16),
                ],
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 4),
            child: Row(
              children: [
                const Text(
                  'Projects',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF27005D),
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _createProject,
                  icon: const Icon(Icons.add, size: 20, color: Color(0xFF9400FF)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),
          
          Expanded(
            flex: 2,
            child: projects.isEmpty
                ? Center(
                    child: Text(
                      'No projects yet',
                      style: TextStyle(
                        color: const Color(0xFFAED2FF).withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${projects.length} project${projects.length > 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFFAED2FF),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: ListView.builder(
                          itemCount: projects.length,
                          itemBuilder: (context, index) {
                            final project = projects[index];
                            return ListTile(
                              selected: selectedProject == project,
                              selectedTileColor: const Color(0xFFE4F1FF),
                              leading: const Icon(Icons.folder, color: Color(0xFF9400FF), size: 20),
                              title: Text(
                                project.name,
                                style: TextStyle(
                                  fontWeight: selectedProject == project ? FontWeight.bold : FontWeight.normal,
                                  color: const Color(0xFF27005D),
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () => setState(() => selectedProject = project),
                                    icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF9400FF), size: 18),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  ),
                                  IconButton(
                                    onPressed: () => _deleteProject(project),
                                    icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFF27005D)),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  ),
                                ],
                              ),
                              onTap: () => setState(() => selectedProject = project),
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
          
          if (selectedProject != null) ...[
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.group, color: Color(0xFF9400FF), size: 20),
              title: const Text(
                'Team Members',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF27005D),
                  fontSize: 14,
                ),
              ),
              trailing: Text(
                '${selectedProject!.members.length}',
                style: const TextStyle(
                  color: Color(0xFF9400FF),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: _showMembersDialog,
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            ),
          ],
          
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Color(0xFF27005D), size: 20),
            title: const Text(
              'Logout',
              style: TextStyle(
                color: Color(0xFF27005D),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: _logout,
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}