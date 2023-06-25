import 'package:bifrost_ui/Sites/site_actions.dart';
import 'package:flutter/material.dart';


class SiteListPage extends StatelessWidget {
  final List<SiteDTO> sites;

  const SiteListPage({Key? key, required this.sites}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sites'),
      ),
      body: ListView.separated(
        itemCount: sites.length,
        separatorBuilder: (context, index) => Divider(color: Colors.grey[800]),
        itemBuilder: (context, index) {
          return SiteTile(site: sites[index]);
        },
      ),
    );
  }
}

class SiteTile extends StatelessWidget {
  final SiteDTO site;

  const SiteTile({super.key, required this.site});


  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        site.siteName ?? '',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      subtitle: Text('Site status: ${site.siteStatus ?? ''}'),
      trailing: PopupMenuButton<String>(
        itemBuilder: (context) {
          return [
            const PopupMenuItem(
              value: 'view_edit',
              child: Text('View & Edit'),
            ),
            const PopupMenuItem(
              value: 'add_attendance',
              child: Text('Enter Attendance'),
            )
          ];
        },
        onSelected: (value) {
          if (value == 'view_edit') {
            // Perform action for View & Edit
          }else if (value == 'add_attendance') {
            // Perform action for View & Edit
          }
        },
      ),
    );
  }
}
