import 'package:flutter_test/flutter_test.dart';
import 'package:hamza_rmb/features/customs_clearance/data/models/clearance_request_model.dart';
import 'package:hamza_rmb/features/customs_clearance/presentation/providers/customs_clearance_provider.dart';

void main() {
  group('ClearanceRequestModel API Payload Tests', () {
    test('Serializes into POST /clearance/requests payload format', () {
      final now = DateTime.parse('2026-09-30T17:10:00.000Z');
      const item = ClearanceItem(
        id: 'itm-1',
        productName: 'Smart Watches',
        description: 'AMOLED touch screen',
        category: 'Electronics',
        quantity: 350,
        unit: 'pieces',
        purchaseValue: 24.5,
        currency: 'USD',
        countryOfManufacture: 'China',
        weight: 120.0,
        volume: 1.8,
        hsCode: '8517.62',
      );

      final doc = ClearanceDocument(
        id: 'doc-invoice',
        documentType: 'Commercial Invoice',
        fileName: 'INV-SZ-2026-9081.pdf',
        fileUrl: 'https://storage.hamza-rmb.com/docs/INV-SZ-2026-9081.pdf',
        status: 'Uploaded',
        uploadedAt: now,
        isNotAvailable: false,
      );

      const address = ClearanceDeliveryAddress(
        fullName: 'Bello Al-Hassan',
        phone: '+234 803 123 4567',
        address: 'Plot 14, Commercial Avenue, Ikeja',
        city: 'Ikeja',
        state: 'Lagos State',
        instructions: 'Call receiving officer',
      );

      final model = ClearanceRequestModel(
        id: 'clr-req-1775059636000',
        requestNumber: 'CLR-2026-001005',
        customerId: 'HZ-88912',
        shipmentType: 'Sea',
        originCountry: 'China',
        portOfEntry: 'Apapa Port',
        shipmentStatus: 'In transit',
        shippingLine: 'COSCO Shipping Lines',
        billOfLadingNumber: 'COSU632819001',
        containerNumber: 'CSQU3091823',
        status: ClearanceStatus.submitted,
        deliveryPreference: 'Deliver to me',
        deliveryAddress: address,
        items: const [item],
        documents: [doc],
        createdAt: now,
        updatedAt: now,
      );

      final json = model.toJson();

      expect(json['shipmentType'], 'Sea');
      expect(json['originCountry'], 'China');
      expect(json['portOfEntry'], 'Apapa Port');
      expect(json['customerId'], 'HZ-88912');
      expect(json['status'], ClearanceStatus.submitted);
      expect(json['deliveryPreference'], 'Deliver to me');
      expect(json['deliveryAddress']['fullName'], 'Bello Al-Hassan');
      expect(json['items'], isNotEmpty);
      expect(json['items'][0]['productName'], 'Smart Watches');
      expect(json['items'][0]['purchaseValue'], 24.5);
      expect(json['documents'], isNotEmpty);
      expect(json['documents'][0]['fileName'], 'INV-SZ-2026-9081.pdf');
    });

    test('Parses GET /clearance/requests and GET /clearance/requests/:id responses correctly', () {
      final sampleApiResponse = {
        'id': 'clr-req-1775059636000',
        'requestNumber': 'CLR-2026-001005',
        'customerId': 'HZ-88912',
        'shipmentType': 'Sea',
        'originCountry': 'China',
        'portOfEntry': 'Apapa Port',
        'status': 'CLEARANCE_PROCESSING',
        'billOfLadingNumber': 'COSU632819001',
        'containerNumber': 'CSQU3091823',
        'totalValueUsd': 8575,
        'createdAt': '2026-09-30T17:15:00.000Z',
        'items': [
          {
            'id': 'itm-1',
            'productName': 'Smart Watches & Fitness Trackers',
            'category': 'Electronics',
            'quantity': 350,
            'unit': 'pieces',
            'value': 24.5,
            'currency': 'USD',
            'countryOfManufacture': 'China',
          }
        ],
        'documents': [
          {
            'id': 'doc-1',
            'documentType': 'Commercial Invoice',
            'fileName': 'INV-SZ-2026-9081.pdf',
            'fileUrl': 'https://res.cloudinary.com/demo/image/upload/sample.pdf',
            'status': 'Accepted',
            'isMissingNoted': false,
          }
        ]
      };

      final parsed = ClearanceRequestModel.fromJson(sampleApiResponse);

      expect(parsed.id, 'clr-req-1775059636000');
      expect(parsed.requestNumber, 'CLR-2026-001005');
      expect(parsed.shipmentType, 'Sea');
      expect(parsed.items.length, 1);
      expect(parsed.items.first.productName, 'Smart Watches & Fitness Trackers');
      expect(parsed.items.first.purchaseValue, 24.5);
      expect(parsed.documents.length, 1);
      expect(parsed.documents.first.fileName, 'INV-SZ-2026-9081.pdf');
      expect(parsed.documents.first.fileUrl, contains('cloudinary'));
    });

    test('CustomsClearanceState includes submitted requests in activeRequests and filteredRequests', () {
      final now = DateTime.now();
      final req1 = ClearanceRequestModel(
        id: 'clr-req-001',
        requestNumber: 'CLR-2026-000001',
        shipmentType: 'Sea',
        status: ClearanceStatus.submitted,
        portOfEntry: 'Apapa Port',
        createdAt: now,
        updatedAt: now,
      );
      final req2 = ClearanceRequestModel(
        id: 'clr-req-002',
        requestNumber: 'CLR-2026-000002',
        shipmentType: 'Air',
        status: ClearanceStatus.completed,
        portOfEntry: 'Murtala Muhammed Airport',
        createdAt: now,
        updatedAt: now,
      );
      final req3 = ClearanceRequestModel(
        id: 'draft-001',
        requestNumber: 'DRAFT',
        shipmentType: 'Land',
        status: ClearanceStatus.draft,
        portOfEntry: 'Seme Border',
        createdAt: now,
        updatedAt: now,
      );

      final state = CustomsClearanceState(requests: [req1, req2, req3]);

      // All requests
      expect(state.requests.length, 3);
      expect(state.filteredRequests.length, 3);

      // Active requests should include submitted requests
      expect(state.activeRequests.length, 1);
      expect(state.activeRequests.first.id, 'clr-req-001');

      // Completed requests
      expect(state.completedRequests.length, 1);
      expect(state.completedRequests.first.id, 'clr-req-002');

      // Latest active request
      expect(state.latestActiveRequest?.id, 'clr-req-001');
    });
  });
}
