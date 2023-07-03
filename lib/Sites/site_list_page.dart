import 'package:bifrost_ui/Sites/site_actions.dart';
import 'package:bifrost_ui/Sites/site_edit_page.dart';
import 'package:flutter/material.dart';

import '../Attendance/attendance_options.dart';


class SiteListPage extends StatefulWidget {
  final List<SiteDTO> sites;

  const SiteListPage({Key? key, required this.sites}) : super(key: key);

  @override
  _SiteListPage createState() => _SiteListPage();
}

class _SiteListPage extends State<SiteListPage> {
  List <SiteDTO> filteredSites = [];

  TextEditingController siteNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredSites = widget.sites;
  }

  @override
  void dispose() {
    siteNameController.dispose();
    super.dispose();
  }

  void applyFilters() {
    setState(() {
      final filterSiteName = siteNameController.text.toLowerCase();

      filteredSites = widget.sites.where((site) {
        final siteName = site.siteName.toLowerCase();

        return siteName.contains(filterSiteName);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sites'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: TextField(
                          controller: siteNameController,
                          onChanged: (_) => applyFilters(),
                          decoration: const InputDecoration(labelText: 'Site Name'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey[800]),
          Expanded(
            child: ListView.builder(
                itemCount: filteredSites.length,
                itemBuilder: (context, index) {
                  final site = filteredSites[index];
                  return Column(
                      children: [
                        ListTile(
                          title: Text(
                            site.siteName ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          subtitle: Text('Mob: ${site.siteStatus ?? ''}'),
                          trailing: PopupMenuButton<String>(
                            itemBuilder: (context) {
                              return [
                                const PopupMenuItem(
                                  value: 'view_edit',
                                  child: Text('View & Edit'),
                                ),
                                const PopupMenuItem(
                                  value: 'manage_attendance',
                                  child: Text('Manage Attendance'),
                                )
                              ];
                            },
                            onSelected: (value) {
                              if (value == 'view_edit') {
                                Future.microtask(() {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EditSiteDialog(site: site),
                                    ),
                                  );
                                });
                              }else if (value == 'manage_attendance') {
                                Future.microtask(() {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const AttendanceOptionsPage(),
                                    ),
                                  );
                                });
                              }
                            },
                          ),
                        ),
                        const Divider(
                          color: Colors.grey,
                          thickness: 1.0,
                        ),
                      ]
                  );
                }
            ),
          ),
        ],
      ),
    );
  }
}
