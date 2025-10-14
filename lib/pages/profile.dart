import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class ProfilePage extends StatefulWidget {
  final String adminEmail;
  final VoidCallback onLogout;

  const ProfilePage({
    super.key,
    required this.adminEmail,
    required this.onLogout,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    _getDeviceInfo();
  }

  // Fungsi yang diperbarui untuk mendukung semua platform
  Future<void> _getDeviceInfo() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    Map<String, dynamic> deviceData = <String, dynamic>{};

    try {
      if (kIsWeb) {
        deviceData = _readWebBrowserInfo(await deviceInfo.webBrowserInfo);
      } else if (Platform.isAndroid) {
        deviceData = _readAndroidDeviceInfo(await deviceInfo.androidInfo);
      } else if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfo.iosInfo);
      } else if (Platform.isWindows) {
        deviceData = _readWindowsDeviceInfo(await deviceInfo.windowsInfo);
      } else if (Platform.isLinux) {
        deviceData = _readLinuxDeviceInfo(await deviceInfo.linuxInfo);
      } else if (Platform.isMacOS) {
        deviceData = _readMacOsDeviceInfo(await deviceInfo.macOsInfo);
      }
    } catch (e) {
      deviceData = {"Error": "Gagal mendapatkan info perangkat."};
    }

    if (mounted) {
      setState(() {
        _deviceData = deviceData;
      });
    }
  }

  // Fungsi helper untuk setiap platform
  Map<String, dynamic> _readAndroidDeviceInfo(AndroidDeviceInfo info) {
    return {
      'Device': info.model,
      'OS Version': 'Android ${info.version.release}',
      'SDK Version': info.version.sdkInt,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo info) {
    return {
      'Device': info.name,
      'Model': info.model,
      'OS': '${info.systemName} ${info.systemVersion}',
    };
  }

  Map<String, dynamic> _readWindowsDeviceInfo(WindowsDeviceInfo info) {
    return {
      'Platform': 'Windows',
      'Computer Name': info.computerName,
      'Build': info.buildNumber,
    };
  }

  Map<String, dynamic> _readLinuxDeviceInfo(LinuxDeviceInfo info) {
    return {
      'Platform': 'Linux',
      'Name': info.prettyName,
      'Build ID': info.buildId ?? 'N/A',
    };
  }

  Map<String, dynamic> _readMacOsDeviceInfo(MacOsDeviceInfo info) {
    return {
      'Platform': 'macOS',
      'Computer Name': info.computerName,
      'Model': info.model,
    };
  }

  Map<String, dynamic> _readWebBrowserInfo(WebBrowserInfo info) {
    return {
      'Platform': 'Web',
      'Browser': info.browserName.name,
      'User Agent': info.userAgent ?? 'N/A',
    };
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Card Header Profil
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
                        Text(
                          widget.adminEmail,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Card Informasi Perangkat
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.smartphone, color: Colors.deepPurple),
                  title: Text(
                    "Informasi Perangkat",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _deviceData.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          children: _deviceData.entries
                              .map(
                                (entry) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        entry.key,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          '${entry.value}',
                                          textAlign: TextAlign.end,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                ),
              ],
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

          // Tombol Logout
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.red[50],
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
              onTap: widget.onLogout,
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

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
}
