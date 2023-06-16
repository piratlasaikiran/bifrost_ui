import 'package:bifrost_ui/Assets/asset_actions.dart';
import 'package:bifrost_ui/Assets/asset_list_page.dart';
import 'package:flutter/material.dart';


class AssetOptionsPage extends StatelessWidget {
  const AssetOptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asset Options'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCircularButton(
              icon: Icons.supervisor_account,
              label: 'Manage Assets',
              onTap: () async {
                AssetActions assetActions = AssetActions();
                List<AssetDTO> assetDTOs = await assetActions.getAllAssetLocations();
                Future.microtask(() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AssetListPage(assets: assetDTOs),
                    ),
                  );
                });
              },
              color: Colors.blue,
              borderColor: Colors.white,
            ),
            const SizedBox(height: 16.0),
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
