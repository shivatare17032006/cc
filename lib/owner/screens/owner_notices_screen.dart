import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../models/owner_complaint.dart';

class OwnerNoticesScreen extends StatefulWidget {
  const OwnerNoticesScreen({super.key});

  @override
  State<OwnerNoticesScreen> createState() => _OwnerNoticesScreenState();
}

class _OwnerNoticesScreenState extends State<OwnerNoticesScreen> {
  List<OwnerComplaint> _complaints = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final list = await ApiService.getOwnerComplaints();
      if (!mounted) return;
      setState(() {
        _complaints = list.map(OwnerComplaint.fromJson).toList();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _replyToComplaint(OwnerComplaint complaint) async {
    final controller = TextEditingController(text: complaint.ownerReply);
    final result = await showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Reply to ${complaint.complaintId}'),
          content: TextField(
            controller: controller,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Write reply for student',
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Send Reply'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result == null || result.isEmpty) {
      return;
    }

    try {
      final updatedMap = await ApiService.replyToComplaint(
        complaintId: complaint.id,
        reply: result,
        status: 'Resolved',
      );

      final updated = OwnerComplaint.fromJson(updatedMap);

      if (!mounted) return;
      setState(() {
        final index = _complaints.indexWhere((c) => c.id == complaint.id);
        if (index >= 0) {
          _complaints[index] = updated;
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _loadComplaints, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_complaints.isEmpty) {
      return const Center(child: Text('No student notices/complaints found'));
    }

    return RefreshIndicator(
      onRefresh: _loadComplaints,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _complaints.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, index) {
          final complaint = _complaints[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${complaint.complaintId} • ${complaint.type}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text('Student: ${complaint.studentName} (${complaint.studentEmail})'),
                  Text('Priority: ${complaint.priority}'),
                  Text('Status: ${complaint.status}'),
                  const SizedBox(height: 8),
                  Text(complaint.description),
                  if (complaint.ownerReply.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.orange.shade100),
                      ),
                      child: Text('Your reply: ${complaint.ownerReply}'),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: () => _replyToComplaint(complaint),
                      icon: const Icon(Icons.reply),
                      label: Text(
                        complaint.ownerReply.isEmpty ? 'Reply' : 'Edit Reply',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      body: _buildBody(),
    );
  }
}
