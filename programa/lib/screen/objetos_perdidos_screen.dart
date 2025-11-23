import 'package:flutter/material.dart';
import 'package:programa/Class/ReporteService.dart';
import 'package:programa/Class/reporte_list.dart';
import 'package:programa/Styles/appBar.dart';
import 'package:provider/provider.dart';

class PerdidosScreen extends StatelessWidget {
  const PerdidosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReporteService>(
      builder: (context, reporteService, child) {
        final todosLosReportes = reporteService.reportes;

        // Filtramos: Solo pendientes (!estado) y que sean Perdidos (!tipoObjeto)
        final perdidos = todosLosReportes
            .where((r) => !r.estado && !r.tipoObjeto)
            .toList();

        return Scaffold(
          appBar: UdecAppBarRightLogo(title: "OBJETOS PERDIDOS"),
          body: ListaReportes(
            reportes: perdidos,
            onReporteChanged: (reporte, nuevoEstado) {
              // --- AQUÍ EMPIEZA LA CONFIRMACIÓN ---
              showDialog(
                context: context,
                builder: (BuildContext ctx) {
                  return AlertDialog(
                    title: const Text("Confirmación"),
                    content: const Text(
                      "¿Ya encontró el objeto por su cuenta?",
                    ),
                    actions: [
                      // CANCELAR (No hace nada)
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop(); // Cierra la ventana
                        },
                        child: const Text("No, cancelar"),
                      ),

                      //  SÍ (Borra el reporte)
                      TextButton(
                        onPressed: () {
                          //  Ejecutamos la eliminación
                          reporteService.eliminarReporte(reporte);

                          //  Cerramos la ventana
                          Navigator.of(ctx).pop();

                          //
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "¡Qué buena noticia! Reporte eliminado.",
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: const Text("Sí, lo encontré"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
