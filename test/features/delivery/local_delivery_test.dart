import 'package:flutter_test/flutter_test.dart';
import 'package:hamza_rmb/features/delivery/data/models/local_delivery_model.dart';
import 'package:hamza_rmb/features/home/data/models/delivery_vehicle_model.dart';

void main() {
  group('Local Delivery API and Model Tests', () {
    test('DeliveryVehicleModel parses GET /delivery/vehicles item correctly', () {
      final json = {
        'id': 'vh-001',
        'name': 'Express Motorbike',
        'type': 'motorbike',
        'description': 'Fastest for light packages up to 15kg.',
        'baseFare': 1000,
        'perKmRate': 150,
        'maxWeightKg': 15,
        'imageUrl': 'https://images.unsplash.com/photo-1558981806-ec527fa84c39',
        'isActive': true,
      };

      final vehicle = DeliveryVehicleModel.fromJson(json);

      expect(vehicle.id, 'vh-001');
      expect(vehicle.name, 'Express Motorbike');
      expect(vehicle.type, 'motorbike');
      expect(vehicle.baseFare, 1000.0);
      expect(vehicle.perKmRate, 150.0);
      expect(vehicle.maxWeightKg, 15.0);
      expect(vehicle.imageUrl, isNotEmpty);
      expect(vehicle.isActive, isTrue);
    });

    test('LocalDeliveryModel parses POST /delivery/request response with PIN', () {
      final json = {
        'id': 'del-801',
        'consolidationId': 'CON-10021',
        'deliveryAddress': '12 Lekki Phase 1, Lagos',
        'recipientName': 'Bayo Adebayo',
        'recipientPhone': '+2348011112222',
        'pickupPin': '4891',
        'status': 'requested',
        'createdAt': '2026-09-24T14:00:00.000Z',
      };

      final delivery = LocalDeliveryModel.fromJson(json);

      expect(delivery.id, 'del-801');
      expect(delivery.consolidationId, 'CON-10021');
      expect(delivery.deliveryAddress, '12 Lekki Phase 1, Lagos');
      expect(delivery.recipientName, 'Bayo Adebayo');
      expect(delivery.recipientPhone, '+2348011112222');
      expect(delivery.pickupPin, '4891');
      expect(delivery.status, 'requested');
    });

    test('LocalDeliveryModel handles optional consolidationId gracefully', () {
      final json = {
        'id': 'del-999',
        'deliveryAddress': 'Plot 4, Garki 2, Abuja',
        'recipientName': 'Aisha Bello',
        'recipientPhone': '+2348099887766',
        'pickupPin': '1234',
        'status': 'pending',
        'createdAt': '2026-09-25T10:00:00.000Z',
      };

      final delivery = LocalDeliveryModel.fromJson(json);

      expect(delivery.id, 'del-999');
      expect(delivery.consolidationId, isEmpty);
      expect(delivery.deliveryAddress, 'Plot 4, Garki 2, Abuja');
      expect(delivery.pickupPin, '1234');
    });

    test('LocalDeliveryModel parses user payload with full pickup and dropoff fields', () {
      final json = {
        'id': 'del-101',
        'pickupAddress': 'HamzaRMB Distribution Hub, Ikeja, Lagos',
        'pickupCity': 'Lagos',
        'pickupContactName': 'Warehouse Admin',
        'pickupPhone': '+2348090219021',
        'pickupEmail': 'pickup@logistics.com',
        'pickupLat': 6.5965,
        'pickupLng': 3.3421,
        'dropoffAddress': '42 Admiralty Way, Lekki Phase 1, Lagos',
        'dropoffCity': 'Lagos',
        'dropoffContactName': 'Bayo Adebayo',
        'dropoffPhone': '+2348011112222',
        'dropoffEmail': 'bayo@example.com',
        'dropoffLat': 6.4474,
        'dropoffLng': 3.4723,
        'customerEmail': 'customer@example.com',
        'customerPhone': '+2348012345678',
        'packageDescription': 'Electronics & Spare Parts',
        'imageUrls': [
          'https://example.com/item1.jpg',
          'https://example.com/item2.jpg'
        ],
        'vehicleId': 'veh-001',
        'vehicleType': 'motorbike',
        'distanceKm': 15,
        'paymentMethod': 'wallet',
        'pickupPin': '5566',
      };

      final delivery = LocalDeliveryModel.fromJson(json);

      expect(delivery.pickupAddress, 'HamzaRMB Distribution Hub, Ikeja, Lagos');
      expect(delivery.dropoffAddress, '42 Admiralty Way, Lekki Phase 1, Lagos');
      expect(delivery.dropoffContactName, 'Bayo Adebayo');
      expect(delivery.dropoffPhone, '+2348011112222');
      expect(delivery.packageDescription, 'Electronics & Spare Parts');
      expect(delivery.imageUrls.length, 2);
      expect(delivery.paymentMethod, 'wallet');
      expect(delivery.distanceKm, 15.0);
      expect(delivery.deliveryAddress, '42 Admiralty Way, Lekki Phase 1, Lagos');
      expect(delivery.recipientName, 'Bayo Adebayo');
      expect(delivery.recipientPhone, '+2348011112222');
    });
  });
}
