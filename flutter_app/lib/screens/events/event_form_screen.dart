import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/event.dart';
import '../../models/category.dart';
import '../../models/location.dart';
import '../../services/api_service.dart';

class EventFormScreen extends StatefulWidget {
  final Event? event;
  const EventFormScreen({super.key, this.event});

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  int? _selectedCategoryId;
  int? _selectedLocationId;
  int? _maxAttendees;
  String _status = 'upcoming';
  List<Category> _categories = [];
  List<Location> _locations = [];
  bool _loading = false;
  bool _loadingData = true;

  bool get _isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final e = widget.event!;
      _titleController.text = e.title;
      _descriptionController.text = e.description ?? '';
      _startDate = e.startDate;
      _endDate = e.endDate;
      _selectedCategoryId = e.categoryId;
      _selectedLocationId = e.locationId;
      _maxAttendees = e.maxAttendees;
      _status = e.status;
    }
    _loadOptions();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadOptions() async {
    try {
      final results = await Future.wait([
        ApiService.instance.getCategories(),
        ApiService.instance.getLocations(),
      ]);
      setState(() {
        _categories = results[0] as List<Category>;
        _locations = results[1] as List<Location>;
        _loadingData = false;
      });
    } catch (_) {
      setState(() => _loadingData = false);
    }
  }

  Future<void> _pickDateTime(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
          isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now())),
    );
    if (time == null) return;
    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() => isStart ? _startDate = dt : _endDate = dt);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccioná las fechas del evento'), backgroundColor: Colors.orange),
      );
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La fecha de fin debe ser después del inicio'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _loading = true);
    final user = ApiService.instance.currentUser!;
    final data = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      'startDate': _startDate!.toIso8601String(),
      'endDate': _endDate!.toIso8601String(),
      'categoryId': _selectedCategoryId,
      'locationId': _selectedLocationId,
      'organizerId': user.id,
      'maxAttendees': _maxAttendees,
      'status': _status,
    };

    try {
      if (_isEditing) {
        await ApiService.instance.updateEvent(widget.event!.id, data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Evento actualizado'), backgroundColor: Colors.green),
          );
          Navigator.of(context).pop();
        }
      } else {
        await ApiService.instance.createEvent(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Evento creado'), backgroundColor: Colors.green),
          );
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Editar evento' : 'Nuevo evento')),
      body: _loadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Título del evento *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.event),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: Text(_startDate == null
                          ? 'Fecha y hora de inicio *'
                          : DateFormat('dd/MM/yyyy HH:mm').format(_startDate!)),
                      subtitle: const Text('Toca para seleccionar'),
                      tileColor: Colors.grey[50],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.grey)),
                      onTap: () => _pickDateTime(true),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today_outlined),
                      title: Text(_endDate == null
                          ? 'Fecha y hora de fin *'
                          : DateFormat('dd/MM/yyyy HH:mm').format(_endDate!)),
                      subtitle: const Text('Toca para seleccionar'),
                      tileColor: Colors.grey[50],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.grey)),
                      onTap: () => _pickDateTime(false),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.label),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Sin categoría')),
                        ..._categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                      ],
                      onChanged: (v) => setState(() => _selectedCategoryId = v),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _selectedLocationId,
                      decoration: const InputDecoration(
                        labelText: 'Lugar',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Sin lugar definido')),
                        ..._locations.map((l) => DropdownMenuItem(value: l.id, child: Text(l.name))),
                      ],
                      onChanged: (v) => setState(() => _selectedLocationId = v),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _maxAttendees?.toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Capacidad máxima',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.people),
                        hintText: 'Dejar vacío para sin límite',
                      ),
                      onChanged: (v) => _maxAttendees = int.tryParse(v),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _status,
                      decoration: const InputDecoration(
                        labelText: 'Estado',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.flag),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'upcoming', child: Text('Próximo')),
                        DropdownMenuItem(value: 'ongoing', child: Text('En curso')),
                        DropdownMenuItem(value: 'finished', child: Text('Finalizado')),
                        DropdownMenuItem(value: 'cancelled', child: Text('Cancelado')),
                      ],
                      onChanged: (v) => setState(() => _status = v ?? 'upcoming'),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(_isEditing ? 'Guardar cambios' : 'Crear evento',
                              style: const TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
