import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final String adminEmail;
  final VoidCallback onLogout; // Menerima fungsi logout

  const ProfilePage({
    super.key,
    required this.adminEmail,
    required this.onLogout, // Tambahkan di constructor
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Header Profil
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.deepPurple,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(width: 20),
                  // --- PERUBAHAN DI SINI: Menambahkan Expanded ---
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Admin Utama",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Text email sekarang akan wrap jika terlalu panjang
                        Text(
                          adminEmail,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow
                              .ellipsis, // Opsi tambahan jika ingin ellipsis
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Informasi Laundry
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildInfoTile(
                  icon: Icons.store_mall_directory_rounded,
                  title: "Nama Laundry",
                  subtitle: "Fena Laundry",
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _buildInfoTile(
                  icon: Icons.location_on_rounded,
                  title: "Alamat",
                  subtitle: "Jl. Merdeka No. 123, Jakarta",
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _buildInfoTile(
                  icon: Icons.phone_rounded,
                  title: "Telepon",
                  subtitle: "0812-3456-7890",
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Pengaturan Akun (Card kosong di kode Anda, saya isi dengan placeholder)
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            //
          ),

          // Tombol Logout
          const SizedBox(height: 20),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.red[50], // Warna latar yang sedikit merah
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
              onTap: onLogout, // Memanggil fungsi logout saat diklik
            ),
          ),
          const SizedBox(height: 80), // Padding tambahan untuk Bottom Nav Bar
        ],
      ),
    );
  }

  // Widget helper untuk baris informasi
  ListTile _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),
    );
  }

  // Widget helper untuk baris aksi
  ListTile _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      onTap: onTap,
    );
  }
}
