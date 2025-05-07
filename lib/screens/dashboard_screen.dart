import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const headerColor = Color(0xFF4D5BFF);

    Widget infoCard(String title, String value) {
      return Expanded(
        child: Container(
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.grey[600])),
              SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }

    Widget activityItem(String title, String subtitle, String timeInfo) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: headerColor, shape: BoxShape.circle),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: Text(timeInfo, style: TextStyle(color: Colors.grey)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: headerColor,
          padding: EdgeInsets.only(top: 48, bottom: 24, left: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('E‑DONATE', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('Dashboard', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              infoCard('Total galangan', '12'),
              infoCard('Total terkumpul', 'Rp 24.5M'),
            ],
          ),
        ),
        SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('Informasi Terkini', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Divider(height: 1),
                activityItem('Donasi baru', 'Rp 250,000', '2 hours ago'),
                activityItem('Penggalangan terbaru', 'Bantuan Banjir', '5 hours ago'),
                activityItem('Donasi yang baru dibuat', 'Beasiswa Pendidikan', 'yesterday'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
