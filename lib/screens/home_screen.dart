import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/donation.dart';
import 'donation_form_screen.dart';
import 'donation_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Donation>> futureDonations;

  @override
  void initState() {
    super.initState();
    futureDonations = ApiService().getAllDonations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CMS Donasi')),
      body: FutureBuilder<List<Donation>>(
        future: futureDonations,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Donation donation = snapshot.data![index];
                return ListTile(
                  title: Text(donation.nama),
                  subtitle: Text('${donation.targetTerkumpul}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DonationDetailScreen(donation: donation),
                      ),
                    );
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DonationFormScreen(),
            ),
          ).then((_) {
            setState(() {
              futureDonations = ApiService().getAllDonations();
            });
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
