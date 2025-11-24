import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:programa/Class/ReporteService.dart';
import 'package:programa/Class/reporte.dart';
import 'package:programa/components/Mapa_Selecionado.dart';

import 'package:provider/provider.dart';

class AgregarReporteScreen extends StatefulWidget {
  final bool personalUdec; // true=Estudiante, false=Persona externa
  final bool esEncontrado; // true=Encontrado, false=Perdido

  const AgregarReporteScreen({
    super.key,
    required this.esEncontrado,
    required this.personalUdec,
  });
  @override
  State<AgregarReporteScreen> createState() => _AgregarReporteScreenState();
}

class _AgregarReporteScreenState extends State<AgregarReporteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _nombreUsuarioController = TextEditingController();
  final _contactoUsuarioController = TextEditingController();
  final _imagenUrlController = TextEditingController();
  final _ubicacionManualController = TextEditingController(); // <--- CAMBIO

  DateTime _fechaSeleccionada = DateTime.now();
  bool _encontrado = false;
  LatLng? _ubicacionGPS;

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _nombreUsuarioController.dispose();
    _contactoUsuarioController.dispose();
    _imagenUrlController.dispose();
    _ubicacionManualController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
      });
    }
  }

  Future<void> _seleccionarUbicacion() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapaSeleccionScreen()),
    );

    if (resultado != null && resultado is LatLng) {
      setState(() {
        _ubicacionGPS = resultado;

        // 1. Preparamos la etiqueta con las coordenadas
        String etiquetaGPS =
            " [GPS: ${resultado.latitude.toStringAsFixed(5)}, ${resultado.longitude.toStringAsFixed(5)}]";

        // 2. Obtenemos lo que el usuario ya había escrito
        String textoActual = _ubicacionManualController.text;

        // 3. Si ya existía una etiqueta GPS vieja, la quitamos para actualizarla
        if (textoActual.contains(" [GPS:")) {
          textoActual = textoActual.split(" [GPS:")[0];
        }

        // 4. Escribimos el resultado final en el campo de texto
        if (textoActual.isEmpty) {
          _ubicacionManualController.text = "Ubicación GPS$etiquetaGPS";
        } else {
          _ubicacionManualController.text = "$textoActual$etiquetaGPS";
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("¡Ubicación precisa guardada y escrita!")),
      );
    }
  }

  void _agregarReporte() {
    if (_formKey.currentState!.validate()) {
      String ubicacionFinal = _ubicacionManualController.text;

      final nuevoReporte = Reporte(
        nombre: _nombreController.text,
        fecha: _fechaSeleccionada,
        imagenUrl: _imagenUrlController.text.isEmpty
            ? 'https://via.placeholder.com/150'
            : _imagenUrlController.text,
        descripcion: _descripcionController.text,
        nombreUsuario: _nombreUsuarioController.text,
        contactoUsuario: _contactoUsuarioController.text,
        PersonalUdec: true,
        estado: false,
        tipoObjeto: _encontrado,
        ubicacion: ubicacionFinal, // Se guarda lo que se ve en pantalla
      );

      Provider.of<ReporteService>(
        context,
        listen: false,
      ).agregarNuevoReporte(nuevoReporte);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Reporte agregado')));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Reporte'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Reporte
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del objeto *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                  hintText: 'Describe el objeto...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: _seleccionarFecha,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_fechaSeleccionada.day}/${_fechaSeleccionada.month}/${_fechaSeleccionada.year}',
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller:
                          _ubicacionManualController, // Aquí se mostrará el GPS
                      decoration: const InputDecoration(
                        labelText: 'Ubicación / Referencia',
                        hintText: 'Ej: Sala 204...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.place),
                      ),
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    children: [
                      IconButton.filled(
                        onPressed:
                            _seleccionarUbicacion, // Llama a la función del mapa
                        style: IconButton.styleFrom(
                          backgroundColor: _ubicacionGPS != null
                              ? Colors.green
                              : Colors.blue,
                        ),
                        icon: const Icon(
                          Icons.my_location,
                          color: Colors.white,
                        ),
                        tooltip: 'Ubicación Precisa',
                      ),
                      Text(
                        _ubicacionGPS != null ? "¡Listo!" : "GPS",
                        style: TextStyle(
                          fontSize: 10,
                          color: _ubicacionGPS != null
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _imagenUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL de la imagen (opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image),
                  hintText: 'https://ejemplo.com/imagen.jpg',
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Información de contacto',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _nombreUsuarioController,
                decoration: const InputDecoration(
                  labelText: 'Tu nombre',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _contactoUsuarioController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono o email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.contact_phone),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              Card(
                child: SwitchListTile(
                  title: const Text('¿Encontrado?'),
                  subtitle: Text(
                    _encontrado ? 'Objeto encontrado' : 'Objeto perdido',
                  ),
                  value: _encontrado,
                  onChanged: (value) {
                    setState(() {
                      _encontrado = value;
                    });
                  },
                  secondary: Icon(
                    _encontrado ? Icons.check_circle : Icons.search,
                    color: _encontrado ? Colors.green : Colors.orange,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _agregarReporte,
                icon: const Icon(Icons.add),
                label: const Text('Agregar Reporte'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
