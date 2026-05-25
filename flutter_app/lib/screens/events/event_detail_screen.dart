import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/event.dart';
import '../../models/schedule.dart';
import '../../models/registration.dart';
import '../../services/api_service.dart';
import 'event_form_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final int eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  Event? _event;
  List<Schedule> _schedules = [];
  Registration? _myRegistration;
  bool _loading = true;
  bool _registrationLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final user = ApiService.instance.currentUser!;
      final results = await Future.wait([
        ApiService.instance.getEvent(widget.eventId),
        ApiService.instance.getSchedules(widget.eventId),
        ApiService.instance.getRegistrations(user.id),
      ]);
      final event = results[0] as Event;
      final schedules = results[1] as List<Schedule>;
      final registrations = results[2] as List<Registration>;
      setState(() {
        _event = event;
        _schedules = schedules;
        _myRegistration = registrations.where((r) => r.eventId == widget.eventId).firstOrNull;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _toggleRegistration() async {
    final user = ApiService.instance.currentUser!;
    setState(() => _registrationLoading = true);
    try {
      if (_myRegistration != null) {
        await ApiService.instance.deleteRegistration(_myRegistration!.id);
        setState(() => _myRegistration = null);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Inscripción cancelada')),
          );
        }
      } else {
        final reg = await ApiService.instance.createRegistration(user.id, widget.eventId);
        setState(() => _myRegistration = reg);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Inscripción exitosa'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _registrationLoading = false);
    }
  }

  Future<void> _deleteEvent() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar evento'),
        content: const Text('¿Estás seguro que querés eliminar este evento?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await ApiService.instance.deleteEvent(widget.eventId);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_event == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Evento no encontrado')),
      );
    }
    final event = _event!;
    final df = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(event.title, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => EventFormScreen(event: event)),
              );
              _loadData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteEvent,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.title,
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    if (event.description != null) ...[
                      const SizedBox(height: 8),
                      Text(event.description!, style: TextStyle(color: Colors.grey[600])),
                    ],
                    const Divider(height: 24),
                    _infoRow(Icons.calendar_today, 'Inicio', df.format(event.startDate.toLocal())),
                    const SizedBox(height: 8),
                    _infoRow(Icons.calendar_today_outlined, 'Fin', df.format(event.endDate.toLocal())),
                    if (event.locationName != null) ...[
                      const SizedBox(height: 8),
                      _infoRow(Icons.location_on, 'Lugar', event.locationName!),
                    ],
                    if (event.categoryName != null) ...[
                      const SizedBox(height: 8),
                      _infoRow(Icons.label, 'Categoría', event.categoryName!),
                    ],
                    if (event.maxAttendees != null) ...[
                      const SizedBox(height: 8),
                      _infoRow(Icons.people, 'Capacidad',
                          '${event.registrationCount}/${event.maxAttendees} inscriptos'),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _registrationLoading ? null : _toggleRegistration,
                        icon: _registrationLoading
                            ? const SizedBox(
                                width: 16, height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2))
                            : Icon(_myRegistration != null
                                ? Icons.bookmark_remove
                                : Icons.bookmark_add),
                        label: Text(_myRegistration != null
                            ? 'Cancelar inscripción'
                            : 'Inscribirse'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _myRegistration != null
                              ? Colors.red
                              : theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Agenda del evento', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_schedules.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text('Sin sesiones programadas')),
                ),
              )
            else
              ..._schedules.map((s) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Icon(Icons.mic, color: theme.colorScheme.primary),
                      ),
                      title: Text(s.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (s.speaker != null) Text('Ponente: ${s.speaker}'),
                          Text('${DateFormat('HH:mm').format(s.startTime.toLocal())} - ${DateFormat('HH:mm').format(s.endTime.toLocal())}'),
                          if (s.room != null) Text('Sala: ${s.room}'),
                        ],
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
