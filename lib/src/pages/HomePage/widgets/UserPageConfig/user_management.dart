import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../text_styles.dart';
import 'package:flutter_application_1/services/fortnite_api.dart';

class UserManagement extends StatefulWidget {
  const UserManagement({super.key});

  @override
  _UserManagementState createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<UserRecord> _users = [];
  List<UserRecord> _filteredUsers = [];
  User? _currentUser;
  final TextEditingController _searchController = TextEditingController();
  bool _showActiveUsers = true;
  bool _showBannedUsers = false;
  bool _showAllUsers = true;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _fetchUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterUsers);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();
      setState(() {
        _users = usersSnapshot.docs
            .map((doc) => UserRecord.fromDocument(doc))
            .where((user) => user.uid != _currentUser?.uid)
            .toList();
        _filterUsers();
      });
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _users.where((user) {
        final matchesQuery = user.firstName.toLowerCase().contains(query) ||
                             user.lastName.toLowerCase().contains(query) ||
                             user.email.toLowerCase().contains(query);
        if (_showAllUsers) {
          return matchesQuery;
        }
        final matchesStatus = _showActiveUsers ? user.status == 1 : user.status == 0;
        final matchesBanned = _showBannedUsers ? user.banned : true;
        return matchesQuery && matchesStatus && matchesBanned;
      }).toList();
    });
  }

  Future<void> _deleteUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({'status': 0});
      _fetchUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario marcado como eliminado')),
      );
    } catch (e) {
      print('Error deleting user: $e');
    }
  }

  Future<void> _deleteUserPermanently(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
      _fetchUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario eliminado definitivamente')),
      );
    } catch (e) {
      print('Error deleting user permanently: $e');
    }
  }

  Future<void> _updateUserRole(String uid, String role) async {
    try {
      await _firestore.collection('users').doc(uid).update({'role': role});
      _fetchUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rol actualizado a $role')),
      );
    } catch (e) {
      print('Error updating user role: $e');
    }
  }

  Future<void> _restrictUser(String uid, int days) async {
    try {
      final banEndDate = DateTime.now().add(Duration(days: days));
      await _firestore.collection('users').doc(uid).update({
        'banned': true,
        'banEndDate': banEndDate,
      });
      _fetchUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuario restringido por $days días')),
      );
    } catch (e) {
      print('Error restricting user: $e');
    }
  }

  Future<void> _unrestrictUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'banned': false,
        'banEndDate': null,
      });
      _fetchUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario desbaneado')),
      );
    } catch (e) {
      print('Error unrestricting user: $e');
    }
  }

  Future<void> _reactivateUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({'status': 1});
      _fetchUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario reactivado')),
      );
    } catch (e) {
      print('Error reactivating user: $e');
    }
  }

  Future<void> _resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Correo de restablecimiento de contraseña enviado')),
      );
    } catch (e) {
      print('Error resetting password: $e');
    }
  }

  void _editUser(UserRecord user) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController firstNameController = TextEditingController(text: user.firstName);
        final TextEditingController lastNameController = TextEditingController(text: user.lastName);
        final TextEditingController emailController = TextEditingController(text: user.email);

        return AlertDialog(
          title: const Text('Editar Usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                style: const TextStyle(color: Colors.black),
              ),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Apellido'),
                style: const TextStyle(color: Colors.black),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                style: const TextStyle(color: Colors.black),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _firestore.collection('users').doc(user.uid).update({
                    'firstName': firstNameController.text,
                    'lastName': lastNameController.text,
                    'email': emailController.text,
                  });
                  _fetchUsers();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Usuario actualizado')),
                  );
                } catch (e) {
                  print('Error editing user: $e');
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Administrador de Usuarios', style: TextStyles.subtitle),
        const SizedBox(height: 10),
        ExpansionTile(
          title: const Text('Filtrar:'),
          backgroundColor: const Color(0xFF6D60AF),
          collapsedBackgroundColor: const Color(0xFF6D60AF),
          textColor: Colors.white,
          iconColor: Colors.white,
          collapsedTextColor: Colors.white,
          collapsedIconColor: Colors.white,
          children: [
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children: [
                FilterChip(
                  label: const Text('Activos'),
                  selected: _showActiveUsers && !_showAllUsers,
                  onSelected: (selected) {
                    setState(() {
                      _showActiveUsers = selected;
                      _showAllUsers = false;
                      _filterUsers();
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Eliminados'),
                  selected: !_showActiveUsers && !_showAllUsers,
                  onSelected: (selected) {
                    setState(() {
                      _showActiveUsers = !selected;
                      _showAllUsers = false;
                      _filterUsers();
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Restringidos'),
                  selected: _showBannedUsers && !_showAllUsers,
                  onSelected: (selected) {
                    setState(() {
                      _showBannedUsers = selected;
                      _showAllUsers = false;
                      _filterUsers();
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Todos'),
                  selected: _showAllUsers,
                  onSelected: (selected) {
                    setState(() {
                      _showAllUsers = selected;
                      _showActiveUsers = !selected;
                      _showBannedUsers = !selected;
                      _filterUsers();
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            labelText: 'Buscar usuarios',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredUsers.length,
            itemBuilder: (context, index) {
              final user = _filteredUsers[index];
              final profileImageUrl = user.profileImageId != null
                  ? FortniteApi.getImageUrl(user.profileImageId!)
                  : 'assets/user_image.png';
              return Card(
                color: user.status == 0 ? Colors.red : null, // Color rojo para usuarios inactivos
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(profileImageUrl),
                  ),
                  title: Text(
                    '${user.firstName} ${user.lastName}',
                    style: TextStyles.bodyText,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.email, style: TextStyles.bodyText), // Mostrar el correo del usuario
                      Text('UID: ${user.uid}', style: TextStyles.bodyText),
                      Text('Banned: ${user.banned}', style: TextStyles.bodyText),
                      if (user.banned && user.banEndDate != null)
                        Text('Restricción hasta: ${user.banEndDate}', style: TextStyles.bodyText),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'delete':
                          _deleteUser(user.uid);
                          break;
                        case 'deletePermanently':
                          _deleteUserPermanently(user.uid);
                          break;
                        case 'edit':
                          _editUser(user);
                          break;
                        case 'assignRole':
                          _updateUserRole(user.uid, user.role == 'admin' ? 'user' : 'admin');
                          break;
                        case 'restrict':
                          _restrictUser(user.uid, 7); // Restringir por 7 días
                          break;
                        case 'unrestrict':
                          _unrestrictUser(user.uid);
                          break;
                        case 'reactivate':
                          _reactivateUser(user.uid);
                          break;
                        case 'resetPassword':
                          _resetPassword(user.email);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      if (user.status == 1)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Eliminar'),
                        )
                      else
                        const PopupMenuItem(
                          value: 'reactivate',
                          child: Text('Reactivar cuenta'),
                        ),
                      if (user.status == 0)
                        const PopupMenuItem(
                          value: 'deletePermanently',
                          child: Text('Eliminar Definitivamente'),
                        ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Editar'),
                      ),
                      PopupMenuItem(
                        value: 'assignRole',
                        child: Text(user.role == 'admin' ? 'Revocar privilegios de administrador' : 'Asignar Rol de Admin'),
                      ),
                      if (!user.banned)
                        const PopupMenuItem(
                          value: 'restrict',
                          child: Text('Restringir (7 días)'),
                        )
                      else
                        const PopupMenuItem(
                          value: 'unrestrict',
                          child: Text('Desbanear'),
                        ),
                      const PopupMenuItem(
                        value: 'resetPassword',
                        child: Text('Restablecer Contraseña'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class UserRecord {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final bool banned;
  final int status;
  final DateTime? banEndDate;
  final String? profileImageId;

  UserRecord({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.banned,
    required this.status,
    this.banEndDate,
    this.profileImageId,
  });

  factory UserRecord.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserRecord(
      uid: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      banned: data['banned'] ?? false,
      status: data['status'] ?? 1,
      banEndDate: data['banEndDate'] != null ? (data['banEndDate'] as Timestamp).toDate() : null,
      profileImageId: data['profileImageId'],
    );
  }
}