import 'package:flutter/material.dart';
import '../../../../mysql.dart';
import 'package:proyecto_rr_principal/widget/home_page.dart';

void paymentPage(BuildContext context, int availabilityId, int studentId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return PaymentBottomSheet(
        availabilityId: availabilityId,
        studentId: studentId,
      );
    },
  );
}

class PaymentBottomSheet extends StatefulWidget {

  final int studentId;
  final int availabilityId;

  PaymentBottomSheet({required this.availabilityId, required this.studentId});

  @override
  _PaymentBottomSheetState createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<PaymentBottomSheet> {
  String selectedPayment = "Amazon Pay";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Seleccionar método de pago",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 15),

          _buildPaymentOption("Amazon Pay", "assets/images/amazon_payment.png"),
          _buildPaymentOption("Apple Pay", "assets/images/apple_payment.png"),
          _buildPaymentOption("Paypal", "assets/images/paypal.png"),
          _buildPaymentOption("Google Pay", "assets/images/google_payment.png"),

          Divider(),
          _buildPriceRow("Sub-Total", "\$300.50"),
          _buildPriceRow("Shipping Fee", "\$15.00"),
          _buildPriceRow("Total Payment", "\$380.50", isTotal: true),

          SizedBox(height: 15),


          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              minimumSize: Size(double.infinity, 50),
            ),
            onPressed: () {
              Navigator.pop(context);
              _bookClass(widget.availabilityId, widget.studentId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Payment Confirmed with $selectedPayment!",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  duration: Duration(
                    seconds: 2,
                  ),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text("Confirm payment"),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String title, String imagePath) {
    return GestureDetector(
      onTap: () {
        setState(() => selectedPayment = title);
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: Border.all(color: selectedPayment == title ? Colors.blue : Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(
                    selectedPayment == title ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: selectedPayment == title ? Colors.blue : Colors.grey,
                  ),
                  SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      title,
                      style: TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Image.asset(
              imagePath,
              height: 40,
              width: 75,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.error, color: Colors.red, size: 30);
              },
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildPriceRow(String label, String price, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(price, style: TextStyle(fontSize: 16, color: isTotal ? Colors.green : Colors.black)),
        ],
      ),
    );
  }

  Future<void> _bookClass(int availabilityId, int studentId) async {
    try {
      final conn = await MySQLHelper.connect();
      await conn.query(
        'UPDATE events SET status = "pending", student_id = ? WHERE id = ?',
        [studentId, availabilityId],
      );
      
      print('WIDget: ${widget.availabilityId} y sin widget: ${availabilityId}');
      await conn.close();

      print('Clase reservada correctamente');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Waiting for teacher to accept the event!'),
        ),
      );

      setState(() {
      });

    } catch (e) {
      print('Error al reservar la clase: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error Booking Class, please try again!'),
        ),
      );
    }
  }
}
