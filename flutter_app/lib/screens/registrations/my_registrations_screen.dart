import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/registration.dart';
import '../../services/api_service.dart';
import '../events/event_detail_screen.dart';

class MyRegistrationsScreen extends StatefulWidget {
  const MyRegistrationsScreen({super.key});

  @override
  State<MyRegistrationsScreen> createState() => _MyRegistrationsScreenState();
}

class _MyRegistrationsScreenState extends State<MyRegistrationsScreen> {
  List<Registration> _registrations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final user = ApiService.instance.currentUser!;
      final regs = await ApiService.instance.getRegistrations(user.id);
      setState(() { _registrations = regs; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _cancelRegistration(Registration reg) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancelar inscripción'),
        content: Text('¿Cancelar inscripción a "${reg.eventTitle}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sí, cancelar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ApiService.instance.deleteRegistration(reg.id);
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$e'), backgroundColor: Colors.red));
      }
    }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'upcoming': return Colors.blue;
      case 'ongoing': return Colors.green;
      case 'finished': return Colors.grey;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'upcoming': return 'Próximo';
      case 'ongoing': return 'En curso';
      case 'finished': return 'Finalizado';
      case 'cancelled': return 'Cancelado';
      default: return status ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Mis inscripciones')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _registrations.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('No tenés inscripciones todavía'),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _registrations.length,
                    itemBuilder: (context, index) {
                      final reg = _registrations[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          title: Text(reg.eventTitle ?? 'Evento',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (reg.eventStartDate != null)
                                Text(DateFormat('dd/MM/yyyy HH:mm').format(reg.eventStartDate!.toLocal())),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _statusColor(reg.eventStatus).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(_statusLabel(reg.eventStatus),
                                    style: TextStyle(
                                        color: _statusColor(reg.eventStatus), fontSize: 12)),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                                onPressed: () async {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) => EventDetailScreen(eventId: reg.eventId)),
                                  );
                                  _loadData();
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                                onPressed: () => _cancelRegistration(reg),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
