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
              '1.1. Service Description: DoseDash is a medicine delivery service available in Colombo, Sri Lanka. Our platform allows pharmacies to list and sell their medicines, and patients to browse, select, and purchase medicines online with cash on delivery. Delivery is managed by DoseDash and will be completed within one hour.\n'
              '1.2. Eligibility: By using DoseDash, you confirm that you are at least 18 years old and legally capable of entering into binding contracts.',
            ),
            SizedBox(height: 20),
            _buildSectionTitle('3. Account Registration'),
            _buildSectionContent(
              '2.1. Pharmacy Accounts: Pharmacies must create a business profile, providing accurate and up-to-date business details, including business registration information, contact details, and location.\n'
              '2.2. Patient Accounts: Patients (customers) must create a personal profile, providing accurate and up-to-date personal details, including name, address, and contact information.\n'
              '2.3. Account Security: You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.',
            ),
            SizedBox(height: 20),
            _buildSectionTitle('4. Use of the Service'),
            _buildSectionContent(
              '3.1. Pharmacy Responsibilities: Pharmacies are responsible for ensuring that all listed medicines comply with applicable laws and regulations. They must provide accurate product descriptions, pricing, and stock availability.\n'
              '3.2. Patient Responsibilities: Patients are responsible for providing accurate delivery information and ensuring availability for receiving deliveries within the specified timeframe.\n'
              '3.3. Prohibited Activities: Users must not use the platform for any illegal activities, including but not limited to the sale or purchase of controlled substances without a valid prescription.',
            ),
            SizedBox(height: 20),
            _buildSectionTitle('5. Orders and Payments'),
            _buildSectionContent(
              '4.1. Order Placement: Patients can browse and select medicines from listed pharmacies. Orders must be confirmed by the pharmacy before processing.\n'
              '4.2. Payment Method: Payments for medicines will be made via cash on delivery.\n'
              '4.3. Order Confirmation: An order confirmation will be sent to the patient and the pharmacy once an order is placed.',
            ),
            SizedBox(height: 20),
            _buildSectionTitle('6. Delivery'),
            _buildSectionContent(
              '5.1. Delivery Timeframe: DoseDash guarantees delivery within one hour of order confirmation, subject to traffic and other unforeseen circumstances.\n'
              '5.2. Delivery Fee: A delivery fee may be charged and will be disclosed at the time of order placement.\n'
              '5.3. Delivery Responsibility: DoseDash is responsible for the delivery of medicines from the pharmacy to the patient.',
            ),
            SizedBox(height: 20),
            _buildSectionTitle('7. Cancellations and Returns'),
            _buildSectionContent(
              '6.1. Order Cancellations: Orders can be canceled by the patient before dispatch. Once the delivery process has started, cancellations are not allowed.\n'
              '6.2. Returns and Refunds: Returns and refunds are subject to the pharmacy’s return policy. In case of incorrect or damaged products, contact the pharmacy directly.',
            ),
            SizedBox(height: 20),
            _buildSectionTitle('8. Privacy Policy'),
            _buildSectionContent(
              '7.1. Data Collection: We collect personal and business details for account creation and service provision. This information will be used in accordance with our privacy policy.\n'
              '7.2. Data Security: We implement appropriate measures to protect your data from unauthorized access, alteration, disclosure, or destruction.',
            ),
            SizedBox(height: 20),
            _buildSectionTitle('9. Liability'),
            _buildSectionContent(
              '8.1. Service Limitation: DoseDash is not liable for any indirect, incidental, or consequential damages arising from the use of our services.\n'
              '8.2. Pharmacy Responsibility: Pharmacies are responsible for the quality, legality, and safety of their products.',
            ),
            SizedBox(height: 20),
            _buildSectionTitle('10. Modifications'),
            _buildSectionContent(
              '9.1. Changes to Terms: DoseDash reserves the right to modify these terms and conditions at any time. Changes will be effective upon posting on our platform. Continued use of our services constitutes acceptance of the modified terms.',
            ),
            SizedBox(height: 20),
            _buildSectionTitle('11. Governing Law'),
            _buildSectionContent(
              '10.1. Jurisdiction: These terms and conditions are governed by the laws of Sri Lanka. Any disputes arising from these terms will be subject to the exclusive jurisdiction of the courts in Colombo, Sri Lanka.',
            ),
            SizedBox(height: 20),
            _buildSectionTitle('12. Contact Information'),
            _buildSectionContent(
              '11.1. Customer Support: For any questions or concerns regarding these terms, please contact us at support@dosedash.lk.',
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
