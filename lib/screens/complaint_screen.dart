import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({super.key});

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  String _complaintType = 'Food Quality';
  String _priority = 'Medium';
  bool _isAnonymous = false;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;

  final List<_ComplaintRecord> _submittedComplaints = [];

  final List<String> _complaintTypes = [
    'Food Quality',
    'Service Issue',
    'Delivery Problem',
    'Cleanliness',
    'Other',
  ];

  final List<String> _priorityOptions = ['Low', 'Medium', 'High'];

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _loadComplaints() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final complaintMaps = await ApiService.getComplaints();
      final complaints = complaintMaps
          .map(_ComplaintRecord.fromJson)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (!mounted) return;
      setState(() {
        _submittedComplaints
          ..clear()
          ..addAll(complaints);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final suffix = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} $hour:$minute $suffix';
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  void _showSnackBar(String message, {required Color backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  BoxDecoration _cardDecoration({
    required double shadowAlpha,
    required double spreadRadius,
    required double blurRadius,
  }) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withValues(alpha: shadowAlpha),
          spreadRadius: spreadRadius,
          blurRadius: blurRadius,
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required Widget child,
    required double shadowAlpha,
    required double spreadRadius,
    required double blurRadius,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(
        shadowAlpha: shadowAlpha,
        spreadRadius: spreadRadius,
        blurRadius: blurRadius,
      ),
      child: child,
    );
  }

  InputDecoration _fieldDecoration({
    required String labelText,
    String? hintText,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }

  Widget _buildDropdownSection({
    required String title,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(15),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                items: options
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      ),
                    )
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return _buildSectionCard(
      shadowAlpha: 0.1,
      spreadRadius: 5,
      blurRadius: 10,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Submit a Complaint',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'We value your feedback and will address your concerns promptly.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                _buildDropdownSection(
                  title: 'Complaint Type',
                  value: _complaintType,
                  options: _complaintTypes,
                  onChanged: (value) {
                    setState(() {
                      _complaintType = value!;
                    });
                  },
                ),
                const SizedBox(width: 12),
                _buildDropdownSection(
                  title: 'Priority',
                  value: _priority,
                  options: _priorityOptions,
                  onChanged: (value) {
                    setState(() {
                      _priority = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Submit as anonymous'),
              value: _isAnonymous,
              onChanged: (value) {
                setState(() {
                  _isAnonymous = value;
                });
              },
            ),
            const SizedBox(height: 10),
            if (!_isAnonymous)
              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.emailAddress,
                decoration: _fieldDecoration(
                  labelText: 'Contact Email (optional)',
                  prefixIcon: Icons.email_outlined,
                ),
                validator: (value) {
                  final trimmed = (value ?? '').trim();
                  if (trimmed.isNotEmpty && !trimmed.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
            if (!_isAnonymous) const SizedBox(height: 20),
            const Text(
              'Describe Your Complaint',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: _fieldDecoration(
                labelText: '',
                hintText: 'Please provide details about your complaint...',
              ),
              validator: (value) {
                final trimmed = (value ?? '').trim();
                if (trimmed.isEmpty) {
                  return 'Please describe your complaint';
                }
                if (trimmed.length < 10) {
                  return 'Please provide at least 10 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitComplaint,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade500,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Submit Complaint',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintListItem(_ComplaintRecord complaint, int index) {
    final statusColor = complaint.status == 'Resolved' ? Colors.green : Colors.blue;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  complaint.ticketId,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  complaint.status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text(complaint.type)),
              Chip(
                label: Text('Priority: ${complaint.priority}'),
                backgroundColor: _priorityColor(complaint.priority).withValues(alpha: 0.15),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            complaint.description,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'Submitted: ${_formatDateTime(complaint.createdAt)}',
            style: const TextStyle(color: Colors.black54),
          ),
          Text(
            complaint.isAnonymous
                ? 'Contact: Anonymous'
                : 'Contact: ${complaint.contactEmail.isEmpty ? 'Not provided' : complaint.contactEmail}',
            style: const TextStyle(color: Colors.black54),
          ),
          if (complaint.status != 'Resolved') ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () => _markResolved(index),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Mark Resolved'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecentComplaintsCard() {
    return _buildSectionCard(
      shadowAlpha: 0.08,
      spreadRadius: 3,
      blurRadius: 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Complaints',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 12),
          if (_submittedComplaints.isEmpty)
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: _loadComplaints,
                            child: const Text('Retry'),
                          ),
                        ],
                      )
                    : const Text(
                        'No complaints submitted yet. Your submitted complaints will appear here.',
                        style: TextStyle(color: Colors.grey),
                      )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _submittedComplaints.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildComplaintListItem(_submittedComplaints[index], index);
              },
            ),
        ],
      ),
    );
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final complaintMap = await ApiService.submitComplaint(
        type: _complaintType,
        description: _descriptionController.text.trim(),
        priority: _priority,
        isAnonymous: _isAnonymous,
        contactEmail: _isAnonymous ? '' : _contactController.text.trim(),
      );

      final record = _ComplaintRecord.fromJson(complaintMap);
      if (!mounted) return;

      setState(() {
        _submittedComplaints.insert(0, record);
        _complaintType = 'Food Quality';
        _priority = 'Medium';
        _isAnonymous = false;
        _descriptionController.clear();
        _contactController.clear();
        _formKey.currentState!.reset();
      });

      _showSnackBar(
        'Complaint submitted. Ticket: ${record.ticketId}',
        backgroundColor: Colors.green.shade700,
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(
        e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: Colors.red.shade700,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _markResolved(int index) async {
    final complaint = _submittedComplaints[index];
    if (complaint.status == 'Resolved') {
      return;
    }

    try {
      final updated = await ApiService.resolveComplaint(complaint.id);
      if (!mounted) return;

      setState(() {
        _submittedComplaints[index] = _ComplaintRecord.fromJson(updated);
      });
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(
        e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: Colors.red.shade700,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildFormCard(),
            const SizedBox(height: 20),
            _buildRecentComplaintsCard(),
          ],
        ),
      ),
    );
  }
}

class _ComplaintRecord {
  _ComplaintRecord({
    required this.id,
    required this.ticketId,
    required this.type,
    required this.description,
    required this.priority,
    required this.createdAt,
    required this.contactEmail,
    required this.isAnonymous,
    this.status = 'Open',
  });

  factory _ComplaintRecord.fromJson(Map<String, dynamic> json) {
    return _ComplaintRecord(
      id: (json['_id'] ?? '').toString(),
      ticketId: (json['complaintId'] ?? 'CMP-UNKNOWN').toString(),
      type: (json['type'] ?? 'Other').toString(),
      description: (json['description'] ?? '').toString(),
      priority: (json['priority'] ?? 'Medium').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ?? DateTime.now(),
      contactEmail: (json['contactEmail'] ?? '').toString(),
      isAnonymous: json['isAnonymous'] == true,
      status: (json['status'] ?? 'Open').toString(),
    );
  }

  final String id;
  final String ticketId;
  final String type;
  final String description;
  final String priority;
  final DateTime createdAt;
  final String contactEmail;
  final bool isAnonymous;
  String status;
}