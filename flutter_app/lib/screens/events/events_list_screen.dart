import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/event.dart';
import '../../models/category.dart';
import '../../services/api_service.dart';
import 'event_detail_screen.dart';
import 'event_form_screen.dart';
import '../registrations/my_registrations_screen.dart';

class EventsListScreen extends StatefulWidget {
  const EventsListScreen({super.key});

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  List<Event> _events = [];
  List<Category> _categories = [];
  bool _loading = true;
  String? _error;
  int? _selectedCategoryId;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        ApiService.instance.getEvents(
            categoryId: _selectedCategoryId,
            search: _searchController.text.isNotEmpty ? _searchController.text : null),
        ApiService.instance.getCategories(),
      ]);
      setState(() {
        _events = results[0] as List<Event>;
        _categories = results[1] as List<Category>;
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _loadEvents() async {
    try {
      final events = await ApiService.instance.getEvents(
          categoryId: _selectedCategoryId,
          search: _searchController.text.isNotEmpty ? _searchController.text : null);
      setState(() => _events = events);
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'upcoming': return 'Próximo';
      case 'ongoing': return 'En curso';
      case 'finished': return 'Finalizado';
      case 'cancelled': return 'Cancelado';
      default: return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'upcoming': return Colors.blue;
      case 'ongoing': return Colors.green;
      case 'finished': return Colors.grey;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ApiService.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventos Académicos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outlined),
            tooltip: 'Mis inscripciones',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MyRegistrationsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await ApiService.instance.logout();
              if (!mounted) return;
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar eventos...',
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _loadEvents();
                            },
                          )
                        : null,
                  ),
                  onSubmitted: (_) => _loadEvents(),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Todos'),
                        selected: _selectedCategoryId == null,
                        onSelected: (_) {
                          setState(() => _selectedCategoryId = null);
                          _loadEvents();
                        },
                      ),
                      const SizedBox(width: 8),
                      ..._categories.map((cat) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(cat.name),
                          selected: _selectedCategoryId == cat.id,
                          onSelected: (_) {
                            setState(() => _selectedCategoryId = cat.id);
                            _loadEvents();
                          },
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 8),
                            Text(_error!),
                            TextButton(onPressed: _loadData, child: const Text('Reintentar')),
                          ],
                        ),
                      )
                    : _events.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.event_busy, size: 64, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('No hay eventos disponibles'),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadData,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              itemCount: _events.length,
                              itemBuilder: (context, index) {
                                final event = _events[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () async {
                                      await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => EventDetailScreen(eventId: event.id),
                                        ),
                                      );
                                      _loadEvents();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  event.title,
                                                  style: theme.textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: _statusColor(event.status).withOpacity(0.15),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  _statusLabel(event.status),
                                                  style: TextStyle(
                                                      color: _statusColor(event.status),
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (event.description != null) ...[
                                            const SizedBox(height: 6),
                                            Text(
                                              event.description!,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(color: Colors.grey[600]),
                                            ),
                                          ],
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                              const SizedBox(width: 4),
                                              Text(
                                                DateFormat('dd/MM/yyyy HH:mm').format(event.startDate.toLocal()),
                                                style: const TextStyle(fontSize: 13, color: Colors.grey),
                                              ),
                                              const Spacer(),
                                              if (event.locationName != null) ...[
                                                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Flexible(
                                                  child: Text(
                                                    event.locationName!,
                                                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              if (event.categoryName != null) ...[
                                                const Icon(Icons.label_outline, size: 14, color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Text(event.categoryName!,
                                                    style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                                const Spacer(),
                                              ],
                                              const Icon(Icons.people_outline, size: 14, color: Colors.grey),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${event.registrationCount} inscriptos',
                                                style: const TextStyle(fontSize: 13, color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const EventFormScreen()),
          );
          if (created == true) _loadEvents();
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo evento'),
      ),
    );
  }
}
