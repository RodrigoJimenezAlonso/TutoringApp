import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_rr_principal/screens/Settings/settings.dart';
import 'dead_end_screen.dart';


class BillingDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final SettingsProvider themeProvider = Provider.of<SettingsProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode == true ? Colors.grey[900] : Colors.grey[100],
      appBar: AppBar(
        title: Text("Billing Details", style: TextStyle(color: themeProvider.isDarkMode == true ? Colors.white : Colors.black)),
        backgroundColor: themeProvider.isDarkMode == true ? Colors.black : Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: themeProvider.isDarkMode == true ? Colors.white : Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Saved Payment Methods"),
            SizedBox(height: 10),

            _buildPaymentMethodCard(context, "Apple Pay", "**** 1234", "assets/images/apple_payment.png"),
            _buildPaymentMethodCard(context, "PayPal", "your.name@example.com", "assets/images/paypal.png"),

            SizedBox(height: 10),
            _addPaymentMethodButton(context),

            Divider(height: 40),

            _sectionTitle("Billing Address"),
            SizedBox(height: 10),

            _buildBillingAddress(
              context,
              name: "your Name",
              address: "Birmingham B15 2TT",
              phone: "+44 0121 414 3344",
            ),

            SizedBox(height: 20),

            _editBillingDetailsButton(context),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildPaymentMethodCard(BuildContext context, String type, String detail, String imagePath) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Image.asset(
          imagePath,
          height: 40,
          width: 50,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.payment, color: Colors.blue, size: 40);
          },
        ),
        title: Text(type, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Text(detail, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DeadEndScreen()),
          );
        },
      ),
    );
  }

  Widget _addPaymentMethodButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DeadEndScreen()),
        );
      }, // Placeholder
      icon: Icon(Icons.add, color: Colors.white),
      label: Text("Add Payment Method", style: TextStyle(fontSize: 16, color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: Size(double.infinity, 50),
      ),
    );
  }

  Widget _buildBillingAddress(BuildContext context, {required String name, required String address, required String phone}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.location_on, color: Colors.redAccent, size: 40),
        title: Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Text("$address\nPhone: $phone", style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DeadEndScreen()),
          );
        }, // Placeholder for future edit function
      ),
    );
  }

  Widget _editBillingDetailsButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DeadEndScreen()),
        );
      }, // Placeholder
      child: Text("Edit Billing Details", style: TextStyle(fontSize: 16, color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: Size(double.infinity, 50),
      ),
    );
  }
}
