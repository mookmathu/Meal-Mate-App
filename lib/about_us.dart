import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: const Color(0xFF203F9A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'About Us',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF203F9A)),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Team Members / สมาชิกในทีม',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF203F9A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildMemberInfo(
                        '6621601026',
                        'นางสาว ปริศนา คำมี',
                        'เลขที่ 25',
                      ),
                      const SizedBox(height: 12),
                      _buildMemberInfo(
                        '6621604831',
                        'นางสาว นุสนีย์ มะแอเคียน',
                        'เลขที่ 55',
                      ),
                      const SizedBox(height: 12),
                      _buildMemberInfo(
                        '6621604874',
                        'นางสาว มธุรดา มีปาน',
                        'เลขที่ 59',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberInfo(String id, String name, String number) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
            ),
            child: ClipOval(
              child: Container(
                color: Color(0xFFEFE8E0),
                child: const Icon(
                  Icons.person,
                  size: 30,
                  color: Color(0xFF203F9A),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Member Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  id,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF203F9A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF203F9A),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                Text(
                  number,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color(0xFF203F9A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
