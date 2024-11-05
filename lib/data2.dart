import 'dart:convert';

class Data {
  final Map<String, dynamic> jsonData = {
    "Users": [
      {
        "id": "1",
        "name": "John Doe",
        "email": "john@example.com",
        "passwordHash": "hashedpassword123",
        "createdAt": "2024-08-10T12:00:00Z",
        "updatedAt": "2024-08-10T12:00:00Z"
      },
      {
        "id": "2",
        "name": "Jane Smith",
        "email": "jane@example.com",
        "passwordHash": "hashedpassword456",
        "createdAt": "2024-08-10T12:00:00Z",
        "updatedAt": "2024-08-10T12:00:00Z"
      },
      {
        "id": "3",
        "name": "Alice Johnson",
        "email": "alice@example.com",
        "passwordHash": "hashedpassword789",
        "createdAt": "2024-08-10T12:00:00Z",
        "updatedAt": "2024-08-10T12:00:00Z"
      },
      {
        "id": "4",
        "name": "Bob Brown",
        "email": "bob@example.com",
        "passwordHash": "hashedpassword012",
        "createdAt": "2024-08-10T12:00:00Z",
        "updatedAt": "2024-08-10T12:00:00Z"
      },
      {
        "id": "5",
        "name": "Charlie Davis",
        "email": "charlie@example.com",
        "passwordHash": "hashedpassword345",
        "createdAt": "2024-08-10T12:00:00Z",
        "updatedAt": "2024-08-10T12:00:00Z"
      },
      {
        "id": "6",
        "name": "Diana Evans",
        "email": "diana@example.com",
        "passwordHash": "hashedpassword678",
        "createdAt": "2024-08-10T12:00:00Z",
        "updatedAt": "2024-08-10T12:00:00Z"
      },
      {
        "id": "7",
        "name": "Eve Foster",
        "email": "eve@example.com",
        "passwordHash": "hashedpassword901",
        "createdAt": "2024-08-10T12:00:00Z",
        "updatedAt": "2024-08-10T12:00:00Z"
      },
      {
        "id": "8",
        "name": "Frank Green",
        "email": "frank@example.com",
        "passwordHash": "hashedpassword234",
        "createdAt": "2024-08-10T12:00:00Z",
        "updatedAt": "2024-08-10T12:00:00Z"
      },
      {
        "id": "9",
        "name": "Grace Harris",
        "email": "grace@example.com",
        "passwordHash": "hashedpassword567",
        "createdAt": "2024-08-10T12:00:00Z",
        "updatedAt": "2024-08-10T12:00:00Z"
      },
      {
        "id": "10",
        "name": "Henry Iverson",
        "email": "henry@example.com",
        "passwordHash": "hashedpassword890",
        "createdAt": "2024-08-10T12:00:00Z",
        "updatedAt": "2024-08-10T12:00:00Z"
      }
    ],
    "Events": [
      {
        "id": "1",
        "title": "Team Meeting",
        "description": "Monthly team sync-up meeting.",
        "startTime": "2024-08-15T10:00:00Z",
        "endTime": "2024-08-15T11:00:00Z",
        "location": "Conference Room 1",
        "isAllDay": false,
        "createdBy": "1",
        "attendees": [
          {
            "userId": "1",
            "status": "accepted"
          },
          {
            "userId": "2",
            "status": "tentative"
          }
        ],
        "createdAt": "2024-08-10T12:00:00Z",
        "updatedAt": "2024-08-10T12:00:00Z"
      },
      {
        "id": "2",
        "title": "Project Kickoff",
        "description": "Kickoff meeting for the new project.",
        "startTime": "2024-08-16T09:00:00Z",
        "endTime": "2024-08-16T10:00:00Z",
        "location": "Conference Room 2",
        "isAllDay": false,
        "createdBy": "3",
        "attendees": [
          {
            "userId": "3",
            "status": "accepted"
          },
          {
            "userId": "4",
            "status": "accepted"
          }
        ],
        "createdAt": "2024-08-10T12:00:00Z",
        "updatedAt": "2024-08-10T12:00:00Z"
      },
      {
        "id": "3",
        "title": "Client Presentation",
        "description": "Presentation to the client.",
        "startTime": "2024-08-17T14:00:00Z",
        "endTime": "2024-08-17T15:30:00Z",
        "location": "Conference Room 3",
        "isAllDay": false,
        "createdBy": "5",
        "attendees": [
          {
            "userId": "5",
            "status": "accepted"
          },
          {
            "userId": "6",
            "status": "accepted"
          }
        ],
        "createdAt": "2024-08-10T12:00:00Z",
        "updatedAt": "2024-08-10T12:00:00Z"
      },
      {
        "id": "4",
        "title": "Workshop",
        "description": "Hands-on workshop for the new software.",
        "startTime": "2024-08-18T13:00:00Z",
        "endTime": "2024-08-18T16:00:00Z",
        "location": "Conference Room 4",
        "isAllDay": false,
        "createdBy": "7",
        "attendees": [
          {
            "userId": "7",
            "status": "accepted"
          },
          {
            "userId": "8",
            "status": "accepted"
          }
        ],
        "createdAt": "2024-08-10T12:00:00Z",
        "updatedAt": "2024-08-10T12:00:00Z"
      },
      {
        "id": "5",
        "title": "Budget Review",
        "description": "Review of the quarterly budget.",
        "startTime": "2024-08-19T11:00:00Z",
        "endTime": "2024-08-19T12:00:00Z",
        "location": "Conference Room 5",
        "isAllDay": false,
        "createdBy": "9",
        "attendees": [
          {
            "userId": "9",
            "status": "accepted"
          },
          {
            "userId": "10",
            "status": "accepted"
          }
        ],
        "createdAt": "2024-08-10T12:00:00Z",
        "updatedAt": "2024-08-10T12:00:00Z"
      },
      {
        "id": "6",
        "title": "Team Lunch",
        "description": "Team lunch at a nearby restaurant.",
        "startTime": "2024-08-20T12:00:00Z",
        "endTime": "2024-08-20T13:30:00Z",
        "location": "Downtown Restaurant",
        "isAllDay": false,
        "createdBy": "1",
        "attendees": [
          {
            "userId": "1",
            "status": "accepted"
          },
          {
            "userId": "2",
            "status": "accepted"
          }
        ],
        "createdAt": "2024-08-10T12:00:00Z",
        "updatedAt": "2024-08-10T12:00:00Z"
      },
      {
        "id": "7",
        "title": "Strategy Meeting",
        "description": "Strategy planning for Q4.",
        "startTime": "2024-08-21T09:30:00Z",
        "endTime": "2024-08-21T11:00:00Z",
        "location": "Conference Room 6",
        "isAllDay": false,
        "createdBy": "3",
        "attendees": [
          {
            "userId": "3",
            "status": "accepted"
          },
          {
            "userId": "4",
            "status": "accepted"
          }
        ],
        "createdAt": "2024-08-10T12:00:00Z",
        "updatedAt": "2024-08-10T12:00:00Z"
      },
      {
        "id": "8",
        "title": "Product Demo",
        "description": "Demonstration of the new product features.",
        "startTime": "2024-08-22T10:00:00Z",
        "endTime": "2024-08-22T11:30:00Z",
        "location": "Conference Room 7",
        "isAllDay": false,
        "createdBy": "5",
        "attendees": [
          {
            "userId": "5",
            "status": "accepted"
          },
          {
            "userId": "6",
            "status": "accepted"
          }
        ],
        "createdAt": "2024-08-10T12:00:00Z",
        "updatedAt": "2024-08-10T12:00:00Z"
      },
      {
        "id": "9",
        "title": "HR Training",
        "description": "Mandatory HR training session.",
        "startTime": "2024-08-23T14:00:00Z",
        "endTime": "2024-08-23T16:00:00Z",
        "location": "Conference Room 8",
        "isAllDay": false,
        "createdBy": "7",
        "attendees": [
          {
            "userId": "7",
            "status": "accepted"
          },
          {
            "userId": "8",
            "status": "accepted"
          }
        ],
        "createdAt": "2024-08-10T12:00:00Z",
        "updatedAt": "2024-08-10T12:00:00Z"
      },
      {
        "id": "10",
        "title": "All-Hands Meeting",
        "description": "Monthly all-hands meeting.",
        "startTime": "2024-08-24T10:00:00Z",
        "endTime": "2024-08-24T11:00:00Z",
        "location": "Main Auditorium",
        "isAllDay": false,
        "createdBy": "9",
        "attendees": [
          {
            "userId": "9",
            "status": "accepted"
          },
          {
            "userId": "10",
            "status": "accepted"
          }
        ],
        "createdAt": "2024-08-10T12:00:00Z",
        "updatedAt": "2024-08-10T12:00:00Z"
      }
    ],
    "Calendars": [
      {
        "id": "1",
        "name": "Work Calendar",
        "ownerId": "1",
        "sharedWith": [
          {
            "userId": "2",
            "permissions": "read"
          }
        ],
        "events": [
          "1"
        ],
        "createdAt": "2024-08-10T12:00:00Z",
        "updatedAt": "2024-08-10T12:00:00Z"
      },
      {
        "id": "2",
        "name": "Project Calendar",
        "ownerId": "3",
        "sharedWith": [
          {
            "userId": "4",
            "permissions": "edit"
          }
        ],
        "events": [
          "2"
        ],
        "createdAt": "2024-08-10T12:00:00Z",
        "updatedAt": "2024-08-10T12:00:00Z"
      },
      {
        "id": "3",
        "name": "Client Calendar",
        "ownerId": "5",
        "sharedWith": [
          {
            "userId": "6",
            "permissions": "read"
          }
        ],
        "events": [
          "3"
        ],
        "createdAt": "2024-08-10T12:00:00Z",
        "updatedAt": "2024-08-10T12:00:00Z"
      },
      {
        "id": "4",
        "name": "Workshop Calendar",
        "ownerId": "7",
        "sharedWith": [
          {
            "userId": "8",
            "permissions": "edit"
          }
        ],
        "events": [
          "4"
        ],
        "createdAt": "2024-08-10T12:00:00Z",
        "updatedAt": "2024-08-10T12:00:00Z"
      },
      {
        "id": "5",
        "name": "Budget Calendar",
        "ownerId": "9",
        "sharedWith": [
          {
            "userId": "10",
            "permissions": "read"
          }
        ],
        "events": [
          "5"
        ],
        "createdAt": "2024-08-10T12:00:00Z",
        "updatedAt": "2024-08-10T12:00:00Z"
      },
      {
        "id": "6",
        "name": "Team Calendar",
        "ownerId": "1",
        "sharedWith": [
          {
            "userId": "2",
            "permissions": "edit"
          }
        ],
        "events": [
          "6"
        ],
        "createdAt": "2024-08-10T12:00:00Z",
        "updatedAt": "2024-08-10T12:00:00Z"
      },
      {
        "id": "7",
        "name": "Strategy Calendar",
        "ownerId": "3",
        "sharedWith": [
          {
            "userId": "4",
            "permissions": "read"
          }
        ],
        "events": [
          "7"
        ],
        "createdAt": "2024-08-10T12:00:00Z",
        "updatedAt": "2024-08-10T12:00:00Z"
      },
      {
        "id": "8",
        "name": "Product Calendar",
        "ownerId": "5",
        "sharedWith": [
          {
            "userId": "6",
            "permissions": "edit"
          }
        ],
        "events": [
          "8"
        ],
        "createdAt": "2024-08-10T12:00:00Z",
        "updatedAt": "2024-08-10T12:00:00Z"
      },
      {
        "id": "9",
        "name": "HR Calendar",
        "ownerId": "7",
        "sharedWith": [
          {
            "userId": "8",
            "permissions": "read"
          }
        ],
        "events": [
          "9"
        ],
        "createdAt": "2024-08-10T12:00:00Z",
        "updatedAt": "2024-08-10T12:00:00Z"
      },
      {
        "id": "10",
        "name": "All-Hands Calendar",
        "ownerId": "9",
        "sharedWith": [
          {
            "userId": "10",
            "permissions": "edit"
          }
        ],
        "events": [
          "10"
        ],
        "createdAt": "2024-08-10T12:00:00Z",
        "updatedAt": "2024-08-10T12:00:00Z"
      }
    ],
    "Notifications": [
      {
        "id": "1",
        "userId": "1",
        "eventId": "1",
        "type": "email",
        "message": "Reminder: Team Meeting starts at 10:00 AM",
        "sentAt": "2024-08-15T09:00:00Z",
        "status": "sent"
      },
      {
        "id": "2",
        "userId": "3",
        "eventId": "2",
        "type": "push",
        "message": "Reminder: Project Kickoff starts at 09:00 AM",
        "sentAt": "2024-08-16T08:30:00Z",
        "status": "sent"
      },
      {
        "id": "3",
        "userId": "5",
        "eventId": "3",
        "type": "sms",
        "message": "Reminder: Client Presentation starts at 02:00 PM",
        "sentAt": "2024-08-17T13:00:00Z",
        "status": "sent"
      },
      {
        "id": "4",
        "userId": "7",
        "eventId": "4",
        "type": "email",
        "message": "Reminder: Workshop starts at 01:00 PM",
        "sentAt": "2024-08-18T12:00:00Z",
        "status": "sent"
      },
      {
        "id": "5",
        "userId": "9",
        "eventId": "5",
        "type": "push",
        "message": "Reminder: Budget Review starts at 11:00 AM",
        "sentAt": "2024-08-19T10:00:00Z",
        "status": "sent"
      },
      {
        "id": "6",
        "userId": "1",
        "eventId": "6",
        "type": "sms",
        "message": "Reminder: Team Lunch starts at 12:00 PM",
        "sentAt": "2024-08-20T11:00:00Z",
        "status": "sent"
      },
      {
        "id": "7",
        "userId": "3",
        "eventId": "7",
        "type": "email",
        "message": "Reminder: Strategy Meeting starts at 09:30 AM",
        "sentAt": "2024-08-21T08:30:00Z",
        "status": "sent"
      },
      {
        "id": "8",
        "userId": "5",
        "eventId": "8",
        "type": "push",
        "message": "Reminder: Product Demo starts at 10:00 AM",
        "sentAt": "2024-08-22T09:00:00Z",
        "status": "sent"
      },
      {
        "id": "9",
        "userId": "7",
        "eventId": "9",
        "type": "sms",
        "message": "Reminder: HR Training starts at 02:00 PM",
        "sentAt": "2024-08-23T13:00:00Z",
        "status": "sent"
      },
      {
        "id": "10",
        "userId": "9",
        "eventId": "10",
        "type": "email",
        "message": "Reminder: All-Hands Meeting starts at 10:00 AM",
        "sentAt": "2024-08-24T09:00:00Z",
        "status": "sent"
      }
    ]
  };

  // Method to get the JSON data as a string
  String getJsonString() {
    return jsonEncode(jsonData);
  }

  // Method to get a specific user by ID
  Map<String, dynamic>? getUserById(String id) {
    return jsonData['Users'].firstWhere((user) => user['id'] == id,
        orElse: () => null);
  }

  // Method to get all events
  List<dynamic> getAllEvents() {
    return jsonData['Events'];
  }
}