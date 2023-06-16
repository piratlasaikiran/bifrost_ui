import 'package:bifrost_ui/Sites/site_actions.dart';
import 'package:bifrost_ui/Sites/site_list_page.dart';
import 'package:flutter/material.dart';

import 'add_site_dialog.dart';

class SiteOptionsPage extends StatelessWidget {
  const SiteOptionsPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Site Actions'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCircularButton(
              icon: Icons.add,
              label: 'Create Site',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const AddSiteDialog();
                  },
                );
              },
              color: Colors.blue,
              borderColor: Colors.white,
            ),
            const SizedBox(height: 16.0),
            _buildCircularButton(
              icon: Icons.list,
              label: 'View Sites',
              onTap: () async {
                SiteActions siteActions = SiteActions();
                List<SiteDTO> siteDTOs = await siteActions.getAllSites();
                Future.microtask(() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SiteListPage(sites: siteDTOs),
                    ),
                  );
                });
              },
              color: Colors.blue,
              borderColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
    required Color borderColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180.0,
        height: 180.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(color: borderColor, width: 2.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48.0,
              color: Colors.white,
            ),
            const SizedBox(height: 8.0),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
