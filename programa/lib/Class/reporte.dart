class Reporte {
  final String nombre;
  final String descripcion;
  final DateTime fecha;
  final String imagenUrl;
  final String nombreUsuario;
  final String contactoUsuario;
  final bool PersonalUdec;
  final bool tipoObjeto;
  bool estado;
  final String ubicacion;

  Reporte({
    required this.nombre,
    required this.fecha,
    required this.imagenUrl,
    this.descripcion = '',
    this.nombreUsuario = '',
    this.contactoUsuario = '',
    required this.PersonalUdec,
    required this.tipoObjeto,
    required this.estado,
    required this.ubicacion,
  });

  Reporte copyWith({
    String? nombre,
    String? descripcion,
    DateTime? fecha,
    String? imagenUrl,
    bool? encontrado,
    String? nombreUsuario,
    String? contactoUsuario,
    bool? PersonalUdec,
    bool? tipoObjeto,
    required bool estado,
    String? ubicacion,
  }) {
    return Reporte(
      nombre: nombre ?? this.nombre,
      fecha: fecha ?? this.fecha,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      descripcion: descripcion ?? this.descripcion,
      nombreUsuario: nombreUsuario ?? this.nombreUsuario,
      contactoUsuario: contactoUsuario ?? this.contactoUsuario,
      PersonalUdec: PersonalUdec ?? this.PersonalUdec,
      tipoObjeto: tipoObjeto ?? this.tipoObjeto,
      estado: estado,
      ubicacion: ubicacion ?? this.ubicacion,
    );
  }
}
