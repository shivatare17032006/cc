class OwnerComplaint {
  const OwnerComplaint({
    required this.id,
    required this.complaintId,
    required this.type,
    required this.description,
    required this.priority,
    required this.status,
    required this.studentName,
    required this.studentEmail,
    required this.createdAt,
    required this.ownerReply,
  });

  factory OwnerComplaint.fromJson(Map<String, dynamic> json) {
    final student = (json['student'] as Map<String, dynamic>? ?? {});

    return OwnerComplaint(
      id: (json['_id'] ?? '').toString(),
      complaintId: (json['complaintId'] ?? '').toString(),
      type: (json['type'] ?? 'Other').toString(),
      description: (json['description'] ?? '').toString(),
      priority: (json['priority'] ?? 'Medium').toString(),
      status: (json['status'] ?? 'Open').toString(),
      studentName: (student['name'] ?? 'Anonymous').toString(),
      studentEmail: (student['email'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ?? DateTime.now(),
      ownerReply: (json['ownerReply'] ?? '').toString(),
    );
  }

  final String id;
  final String complaintId;
  final String type;
  final String description;
  final String priority;
  final String status;
  final String studentName;
  final String studentEmail;
  final DateTime createdAt;
  final String ownerReply;
}
