import 'package:flutter_test/flutter_test.dart';
import 'package:hamza_rmb/features/account/data/models/ticket_model.dart';

void main() {
  group('Support Tickets API and Model Tests', () {
    test('TicketModel parses POST /support/tickets response', () {
      final json = {
        'id': 'tkt-801',
        'ticketNumber': 'TCK-20260816-102',
        'userId': 'usr-1002',
        'subject': 'Delay on package SF10928',
        'category': 'shipment',
        'status': 'open',
        'priority': 'medium',
        'description': 'Package has been at China hub for 3 days',
        'createdAt': '2026-09-24T12:00:00.000Z',
      };

      final ticket = TicketModel.fromJson(json);

      expect(ticket.id, 'tkt-801');
      expect(ticket.subject, 'Delay on package SF10928');
      expect(ticket.category, 'shipment');
      expect(ticket.priority, 'medium');
      expect(ticket.status, 'open');
      expect(ticket.description, 'Package has been at China hub for 3 days');
    });

    test('TicketModel supports threaded messages from GET /support/tickets/:id', () {
      final json = {
        'id': 'tkt-801',
        'subject': 'Delay on package SF10928',
        'category': 'shipment',
        'status': 'open',
        'priority': 'medium',
        'description': 'Package has been at China hub for 3 days',
        'createdAt': '2026-09-24T12:00:00.000Z',
        'messages': [
          {
            'id': 'msg-1',
            'sender': 'Customer',
            'message': 'Package has been at China hub for 3 days',
            'timestamp': '2026-09-24T12:00:00.000Z',
          },
          {
            'id': 'msg-2',
            'sender': 'Support',
            'message': 'We are expediting with Guangzhou hub dispatch.',
            'timestamp': '2026-09-24T12:30:00.000Z',
          },
        ],
      };

      final ticket = TicketModel.fromJson(json);

      expect(ticket.messages.length, 2);
      expect(ticket.messages[0].message, 'Package has been at China hub for 3 days');
      expect(ticket.messages[1].sender, 'Support');
    });

    test('Validates documented Category and Priority enums', () {
      const allowedCategories = [
        'shipment',
        'payment',
        'exchange',
        'procurement',
        'delivery',
        'account',
        'clearance',
        'other',
      ];
      const allowedPriorities = ['low', 'medium', 'high', 'urgent'];

      for (final cat in allowedCategories) {
        final t = TicketModel(
          id: 'test',
          subject: 'Test',
          category: cat,
          description: 'Desc',
          createdAt: DateTime.now(),
        );
        expect(t.category, cat);
      }

      for (final prio in allowedPriorities) {
        final t = TicketModel(
          id: 'test',
          subject: 'Test',
          priority: prio,
          description: 'Desc',
          createdAt: DateTime.now(),
        );
        expect(t.priority, prio);
      }
    });
  });
}
