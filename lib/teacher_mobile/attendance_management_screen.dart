import 'package:flutter/material.dart';

class AttendanceManagementScreen extends StatefulWidget {
  const AttendanceManagementScreen({super.key});

  @override
  State<AttendanceManagementScreen> createState() => _AttendanceManagementScreenState();
}

class _AttendanceManagementScreenState extends State<AttendanceManagementScreen> {
  String? _selectedClass;
  DateTime _selectedDate = DateTime.now();

  final List<String> _classes = ['Matemáticas 1A', 'Historia 2B', 'Ciencias 3C'];
  final Map<String, bool> _studentAttendance = {};

  // Placeholder student data
  final Map<String, List<String>> _studentsByClass = {
    'Matemáticas 1A': ['Juan Pérez', 'María García', 'Carlos López'],
    'Historia 2B': ['Ana Torres', 'Pedro Ramírez', 'Sofía Castro'],
    'Ciencias 3C': ['Luis Herrera', 'Elena Vargas', 'Miguel Soto'],
  };

  @override
  void initState() {
    super.initState();
    _initializeAttendance();
  }

  void _initializeAttendance() {
    _studentAttendance.clear();
    if (_selectedClass != null && _studentsByClass.containsKey(_selectedClass)) {
      for (var student in _studentsByClass[_selectedClass]!) {
        _studentAttendance[student] = false; // Default to absent
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Re-initialize attendance for the new date if needed (for persistence later)
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Asistencia'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedClass,
              hint: const Text('Selecciona una clase'),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                labelText: 'Clase',
              ),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedClass = newValue;
                  _initializeAttendance(); // Initialize attendance for the newly selected class
                });
              },
              items: _classes.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Fecha seleccionada: ${_selectedDate == null ? 'No seleccionada' : _selectedDate!.toLocal().toString().split(' ')[0]}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _selectDate(context),
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Seleccionar Fecha'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_selectedClass != null) // Only show student list if a class is selected
              Expanded(
                child: ListView.builder(
                  itemCount: _studentsByClass[_selectedClass]!.length,
                  itemBuilder: (context, index) {
                    final studentName = _studentsByClass[_selectedClass]![index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: CheckboxListTile(
                        title: Text(studentName, style: Theme.of(context).textTheme.bodyLarge),
                        value: _studentAttendance[studentName],
                        onChanged: (bool? value) {
                          setState(() {
                            _studentAttendance[studentName] = value!;
                          });
                        },
                      ),
                    );
                  },
                ),
              )
            else
              const Expanded(
                child: Center(
                  child: Text('Por favor, selecciona una clase para ver la lista de estudiantes.'),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50), // Make button full width and a bit taller
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // Lógica para guardar la asistencia
                print('Asistencia guardada para ${_selectedClass} en ${(_selectedDate.toLocal().toString()).split(' ')[0]}:');
                _studentAttendance.forEach((student, isPresent) {
                  print('$student: ${isPresent ? 'Presente' : 'Ausente'}');
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Asistencia guardada!')),
                );
              },
              child: const Text('Guardar Asistencia'),
            ),
          ],
        ),
      ),
    );
  }
}