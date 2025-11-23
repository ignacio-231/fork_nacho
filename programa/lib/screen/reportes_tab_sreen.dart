import 'package:flutter/material.dart';
import 'package:programa/Class/ReporteService.dart';
import 'package:programa/Class/reporte.dart';
import 'package:programa/Class/reporte_list.dart';
import 'package:programa/Styles/Text.dart';
import 'package:programa/screen/agregar_reporte_screen.dart';
import 'package:provider/provider.dart';

// 1. Cambiamos a StatefulWidget para usar TabController
class ReportesTabsScreen extends StatefulWidget {
  const ReportesTabsScreen({super.key});

  @override
  State<ReportesTabsScreen> createState() => _ReportesTabsScreenState();
}

class _ReportesTabsScreenState extends State<ReportesTabsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Inicializamos el controlador con 3 pestañas
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReporteService>(
      builder: (context, reporteService, child) {
        final todos = reporteService.reportes;

        // --- 2. LÓGICA DE FILTRADO REORGANIZADA ---

        final listaPerdidos =
            todos.where((r) => !r.estado && !r.tipoObjeto).toList()
              ..sort((a, b) => b.fecha.compareTo(a.fecha));

        final listaEncontrados =
            todos.where((r) => !r.estado && r.tipoObjeto).toList()
              ..sort((a, b) => b.fecha.compareTo(a.fecha));

        // Pestaña 3: NOTIFICADOS (Historial / Resueltos, de reporte de objetos perdidos)
        final listaNotificadosPerdidos =
            todos.where((r) => r.estado && !r.tipoObjeto).toList()
              ..sort((a, b) => b.fecha.compareTo(a.fecha));
        final listaNotificadosEncontrados =
            todos.where((r) => r.estado && r.tipoObjeto).toList()
              ..sort((a, b) => b.fecha.compareTo(a.fecha));
        int cantidadPerdidos = listaNotificadosPerdidos.length;
        int cantidadEncontrados = listaNotificadosEncontrados.length;
        print(cantidadEncontrados);
        print(cantidadPerdidos);
        return Scaffold(
          appBar: AppBar(
            title: const Text("Reportes de Objetos"),
            bottom: TabBar(
              controller: _tabController, // Asignamos el controlador
              indicatorColor: Colors.blue,
              tabs: const [
                Tab(text: "Perdidos"),
                Tab(text: "Encontrados"),
                Tab(text: "Notificados"), // Aquí llegarán los resueltos
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController, // Asignamos el controlador aquí también
            children: [
              // TAB 1: Perdidos
              ListaReportes(
                reportes: listaPerdidos,

                onReporteChanged: (reporte, nuevoEstado) {
                  if (listaNotificadosPerdidos.length ==
                      listaNotificadosEncontrados.length) {
                    reporteService.actualizarEstadoReporte(
                      reporte,
                      nuevoEstado,
                    );
                    if (nuevoEstado) _tabController.animateTo(1);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "⚠️ No puedes validar más 'Perdidos'.\n"
                          "Necesitas validar un reporte de 'Objeto Encontrado' para mantener el balance.",
                        ),
                        backgroundColor:
                            Colors.orange, // Naranja de advertencia
                        duration: Duration(seconds: 3),
                      ),
                    );
                    _tabController.animateTo(2);
                  }
                  // Agrega esta condición para saltar a la pestaña de encotrado
                },
              ),

              // TAB 2: Encontrados (Hallazgos)
              ListaReportes(
                reportes: listaEncontrados,
                onReporteChanged: (reporte, nuevoEstado) {
                  if (listaNotificadosEncontrados.length <
                      listaNotificadosPerdidos.length) {
                    reporteService.actualizarEstadoReporte(
                      reporte,
                      nuevoEstado,
                    );
                    if (nuevoEstado) _tabController.animateTo(2);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "⚠️ No puedes validar más 'Encontrados'.\n"
                          "Primero debe validarse un reporte de 'Objeto Perdido'.",
                        ),
                        backgroundColor:
                            Colors.orange, // Naranja de advertencia
                        duration: Duration(seconds: 3),
                      ),
                    );
                  } //Para saltar a la pestaña de notifaciones
                },
              ),

              // TAB 3: Notificados (Aquí caen los que marcaste con check)
              Row(
                children: [
                  Expanded(
                    child: ListaReportes(
                      reportes: listaNotificadosPerdidos,
                      onReporteChanged: (reporte, nuevoEstado) {
                        // Si le quitas el check, vuelve a su lista original
                        reporteService.actualizarEstadoReporte(
                          reporte,
                          nuevoEstado,
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(
                      Icons.swap_horiz, // <--- El icono de flechas -> <-
                      color:
                          Colors.grey, // Color sugerido para que no distraiga
                      size: 30,
                    ),
                  ),
                  Expanded(
                    child: ListaReportes(
                      reportes: listaNotificadosEncontrados,
                      onReporteChanged: (reporte, nuevoEstado) {
                        reporteService.actualizarEstadoReporte(
                          reporte,
                          nuevoEstado,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AgregarReporteScreen(
                    personalUdec: true,
                    esEncontrado: false,
                  ),
                ),
              );
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
