import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms and Conditions'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms and Conditions',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _buildSectionTitle('1. Introduction'),
            _buildSectionContent(
              'Welcome to DoseDash. By using our mobile application and services, you agree to be bound by the following terms and conditions. Please read them carefully. If you do not agree to these terms, please do not use our services.',
            ),
            SizedBox(height: 20),
            _buildSectionTitle('2. General'),
            _buildSectionContent(
              '2.1. Service Description: DoseDash is a medicine delivery service available in Colombo, Sri Lanka. Our platform allows pharmacies to list and sell their medicines, and patients to browse, select, and purchase medicines online and pay through Stripe. Delivery and medicine purchases are managed by DoseDash within a 15 km radius of patient users to ensure quick and convenient delivery within 1 hour.\n'
              '2.2. Eligibility: By using DoseDash, you confirm that you are at least 18 years old and legally capable of entering into binding contracts"',
            ),
            SizedBox(height: 20),
            _buildSectionTitle('3. Account Registration'),
            _buildSectionContent(
              '3.1. Pharmacy Accounts: Pharmacies must be licensed to sell pharmaceutical products and provide valid business information. Pharmacies must create a business profile, providing accurate and up-to-date business details, including business registration information, contact details, and location.\n'
              '3.2. Patient Accounts: Patients must provide accurate personal information, including their name, contact information, email, and address, which is set by selecting a location in Google Maps integrated within the app. The address field is populated using the Geocoding API.\n'
              '3.4. Delivery Personnel (DP) Accounts: Delivery personnel must provide personal information, vehicle details, banking details, and select their address using Google Maps within the app. Their address is set using the Geocoding API, and their live location is tracked using the Geolocation API for accurate delivery management.\n'
              '3.5. Account Security: You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.',
            ),
            SizedBox(height: 20),
            SizedBox(height: 20),
            _buildSectionTitle('4. Use of the Service'),
            _buildSectionContent(
              '4.1. Pharmacy Responsibilities: Pharmacies may use the platform to list and sell pharmaceutical products and must fulfill orders accurately and in a timely manner. Pharmacies are responsible for ensuring that all listed medicines comply with applicable laws and regulations. They must provide accurate product descriptions, pricing, and stock availability.\n'
              '4.2. Patient Responsibilities: Patient users (customers) may use the app to browse, purchase, and receive pharmaceutical products. Patients are responsible for providing accurate delivery information and ensuring availability for receiving deliveries within the specified timeframe.\n'
              '4.3. Delivery Personnel Responsibilities:  Delivery personnel must have a valid driver\'s license and insurance and must comply with all applicable laws and regulations. They are responsible for the safe and timely delivery of orders.\n'
              '4.4. Prohibited Activities: Users must not use the platform for any illegal activities, including but not limited to the sale or purchase of controlled substances without a valid prescription.',
            ),
            SizedBox(height: 20),
            _buildSectionTitle('5. Orders and Payments'),
            _buildSectionContent(
              '5.1. Order Placement: Patients can browse and select medicines from listed pharmacies. Orders must be confirmed by the pharmacy before processing.\n'
              '5.2. Stripe Payment Gateway: All payments on the platform are processed securely through Stripe. By using our platform, you agree to comply with Stripe\'s terms and conditions.\n'
              '5.3. Order Confirmation: An order confirmation will be sent to the patient and the pharmacy once an order is placed.',
            ),
            SizedBox(height: 20),
            _buildSectionTitle('6. Delivery'),
            _buildSectionContent(
              '6.1. Delivery Timeframe: DoseDash guarantees delivery within one hour of order confirmation, subject to traffic and other unforeseen circumstances. Any disputes related to delivery, including delays or issues with the delivery personnel, should be reported to support@dosedash.lk . We will work with all parties involved to resolve the issue promptly.\n'
              '6.2. Delivery Fee: A delivery fee may be charged and will be disclosed at the time of order placement.\n'
              '6.3. Delivery Responsibility: DoseDash is responsible for the delivery of medicines from the pharmacy to the patient.\n'
              '6.4. Delivery Personnel: Delivery personnel are responsible for picking up orders from the pharmacy and delivering them to the patient within the specified timeframe. Delivery personnel must comply with all applicable laws and regulations and must maintain a professional and courteous demeanor at all times.',
            ),
            SizedBox(height: 20),
            _buildSectionTitle('7. Cancellations and Returns'),
            _buildSectionContent(
              '7.1. Order Cancellations: Orders can be canceled by the patient before dispatch. Once the delivery process has started, cancellations are not allowed.\n'
              '7.2. Returns and Refunds: Returns and refunds are subject to the pharmacy\'s return policy. In case of incorrect or damaged products, contact the pharmacy directly.',
            ),
            SizedBox(height: 20),
            _buildSectionTitle('8. Privacy Policy'),
            _buildSectionContent(
              '8.1. Data Collection: We collect personal and business details for account creation and service provision. This information will be used in accordance with our privacy policy.\n'
              '8.2. Data Security: We implement appropriate measures to protect your data from unauthorized access, alteration, disclosure, or destruction.\n'
              '8.3. Location Data: Location data collected through the Geolocation API and other services is used solely for the purpose of providing and improving our delivery services. We do not share this data with third parties without your consent, except as necessary to provide our services.',
            ),
            SizedBox(height: 20),
            _buildSectionTitle('9. Liability'),
            _buildSectionContent(
              '9.1. Service Limitation: DoseDash is not liable for any indirect, incidental, or consequential damages arising from the use of our services.\n'
              '9.2. Pharmacy Responsibility: Pharmacies are responsible for the quality, legality, and safety of their products.\n'
              '9.3. Medical Advice Disclaimer: DoseDash does not provide medical advice, diagnosis, or treatment. The content on our platform is for informational purposes only and should not be used as a substitute for professional medical advice.',

            ),
            SizedBox(height: 20),
            _buildSectionTitle('10. Modifications'),
            _buildSectionContent(
              '10.1. Changes to Terms: DoseDash reserves the right to modify these terms and conditions at any time. Changes will be effective upon posting on our platform. Continued use of our services constitutes acceptance of the modified terms.',
            ),
            SizedBox(height: 20),
            _buildSectionTitle('11. Governing Law'),
            _buildSectionContent(
              '11.1. Jurisdiction: These terms and conditions are governed by the laws of Sri Lanka. Any disputes arising from these terms will be subject to the exclusive jurisdiction of the courts in Colombo, Sri Lanka.',
            ),
            SizedBox(height: 20),
            _buildSectionTitle('12. Contact Information'),
            _buildSectionContent(
              '12.1. Customer Support: For any questions or concerns regarding these terms, please contact us at support@dosedash.lk.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSectionContent(String content) {
    return Text(
      content,
    );
  }
}
