import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../widgets/user_card.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});
  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final ApiService _apiService = ApiService();
  
  // a) Gunakan TextEditingController untuk input pencarian
  final TextEditingController _searchController = TextEditingController();
  
  List<User> _allUsers = []; // Menyimpan data asli dari API
  List<User> _filteredUsers = []; // Menyimpan data hasil pencarian
  
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final users = await _apiService.getUsers();
      setState(() {
        _allUsers = users;
        _filteredUsers = users; // Saat awal, data tersaring sama dengan semua data
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // b & c) Filter daftar user dan update secara real-time
  void _filterUsers(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredUsers = _allUsers;
      });
    } else {
      setState(() {
        _filteredUsers = _allUsers.where((user) {
          final nameLower = user.name.toLowerCase();
          final emailLower = user.email.toLowerCase();
          final searchLower = query.toLowerCase();
          
          // Pencarian berdasarkan nama ATAU email
          return nameLower.contains(searchLower) || emailLower.contains(searchLower);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengguna'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _searchController.clear();
              _loadUsers();
            },
            tooltip: 'Muat ulang',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat data...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Terjadi Kesalahan',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadUsers,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // a) TextField pencarian di atas list
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            onChanged: _filterUsers, // Memicu filter secara real-time saat diketik
            decoration: InputDecoration(
              labelText: 'Cari Pengguna',
              hintText: 'Masukkan nama atau email...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filterUsers('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        
        // Menampilkan list user (sisa layar)
        Expanded(
          child: _filteredUsers.isEmpty
              ? const Center(child: Text('Tidak ada pengguna yang cocok'))
              : RefreshIndicator(
                  onRefresh: _loadUsers,
                  child: ListView.builder(
                    itemCount: _filteredUsers.length, // c) Menggunakan list yang sudah difilter
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      return UserCard(
                        user: user,
                        onTap: () {
                          _showUserDetail(user);
                        },
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  void _showUserDetail(User user) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Username: ${user.username}'),
            Text('Email: ${user.email}'),
            Text('Telepon: ${user.phone}'),
            Text('Website: ${user.website}'),
            Text('Perusahaan: ${user.companyName}'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}