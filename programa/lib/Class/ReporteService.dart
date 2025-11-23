import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:programa/Class/reporte.dart';

class ReporteService extends ChangeNotifier {
  final List<Reporte> _reportes = [];
  List<Reporte> get reportes => _reportes;

  final Map<Reporte, Reporte> _historialRecuperados = {};

  Map<Reporte, Reporte> get historialRecuperados => _historialRecuperados;

  void agregarNuevoReporte(Reporte reporte) {
    _reportes.add(reporte);
    print('¡REPORTE RECIBIDO EN SERVICIO! Total actual: ${_reportes.length}');
    notifyListeners();
  }

  void actualizarEstadoReporte(Reporte reporte, bool nuevoEstado) {
    final index = _reportes.indexOf(reporte);

    //  Verificar que el reporte exista en nuestra lista
    if (index != -1) {
      //  Crear una NUEVA copia del reporte con el estado actualizado
      final reporteActualizado = reporte.copyWith(estado: nuevoEstado);

      //  Reemplazar el reporte antiguo por el nuevo en la lista
      _reportes[index] = reporteActualizado;

      print('Estado de reporte actualizado (con copyWith). Notificando...');
      notifyListeners();
    } else {
      print('Error: Se intentó actualizar un reporte que no está en la lista.');
    }
  }

  void finalizarReporte(Reporte reportePerdido, Reporte reporteHallazgo) {
    _historialRecuperados[reportePerdido] = reporteHallazgo;

    print(
      "¡Caso cerrado! Se vinculó ${reportePerdido.nombre} con su hallazgo.",
    );
    notifyListeners();
  }

  void eliminarReporte(Reporte reporteParaBorrar) {
    _reportes.remove(reporteParaBorrar);
    notifyListeners(); // ¡Muy importante! Avisa a la pantalla que refresque la lista
  }
}
