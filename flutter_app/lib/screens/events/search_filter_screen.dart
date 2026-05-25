import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../services/api_service.dart';

class SearchFilterScreen extends StatefulWidget {
  final int? initialCategoryId;
  final String initialSearch;

  const SearchFilterScreen({
    super.key,
    this.initialCategoryId,
    this.initialSearch = '',
  });

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  late final TextEditingController _searchController;
  int? _selectedCategoryId;
  List<Category> _categories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialSearch);
    _selectedCategoryId = widget.initialCategoryId;
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await ApiService.instance.getCategories();
      setState(() { _categories = cats; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _apply() {
    Navigator.of(context).pop({
      'search': _searchController.text.trim(),
      'categoryId': _selectedCategoryId,
    });
  }

  void _clear() {
    setState(() {
      _searchController.clear();
      _selectedCategoryId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar y filtrar'),
        actions: [
          TextButton(
            onPressed: _clear,
            child: const Text('Limpiar'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Buscar por título',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Filtrar por categoría',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      children: [
                        RadioListTile<int?>(
                          title: const Text('Todas las categorías'),
                          value: null,
                          groupValue: _selectedCategoryId,
                          onChanged: (v) => setState(() => _selectedCategoryId = v),
                        ),
                        ..._categories.map((cat) => RadioListTile<int?>(
                              title: Text(cat.name),
                              subtitle: cat.description != null ? Text(cat.description!) : null,
                              value: cat.id,
                              groupValue: _selectedCategoryId,
                              onChanged: (v) => setState(() => _selectedCategoryId = v),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _apply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Aplicar filtros', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
