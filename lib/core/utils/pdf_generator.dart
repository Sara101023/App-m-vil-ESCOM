import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../features/ets/domain/entities/ets_entity.dart';
import 'turno_helper.dart';

class PdfGenerator {
  PdfGenerator._();

  static Future<void> generarYMostrarPdf(
    List<EtsEntity> lista, {
    String? nombreAlumno,
    String? boleta,
  }) async {
    final doc = pw.Document();

    // Cargar logos
    final ipnBytes =
        await rootBundle.load('assets/images/ipn_logo.png');
    final escomBytes =
        await rootBundle.load('assets/images/escom_logo.png');
    final ipnImage = pw.MemoryImage(ipnBytes.buffer.asUint8List());
    final escomImage = pw.MemoryImage(escomBytes.buffer.asUint8List());

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // ── Encabezado con logos ──────────────────
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Image(ipnImage, width: 60, height: 60),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'INSTITUTO POLITÉCNICO NACIONAL',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blueGrey700,
                    ),
                  ),
                  pw.Text(
                    'Escuela Superior de Cómputo',
                    style: pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.blueGrey700,
                    ),
                  ),
                ],
              ),
              pw.Image(escomImage, width: 70, height: 50),
            ],
          ),

          pw.SizedBox(height: 8),
          pw.Divider(color: PdfColors.blueGrey300, thickness: 1),
          pw.SizedBox(height: 8),

          // ── Título ────────────────────────────────
          pw.Center(
            child: pw.Text(
              'Comprobante de Examen a Título de Suficiencia',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blueGrey900,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),

          pw.SizedBox(height: 6),

          pw.Center(
            child: pw.Text(
              'Generado el ${_fechaHoy()}',
              style: pw.TextStyle(
                fontSize: 9,
                color: PdfColors.blueGrey400,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          ),

          pw.SizedBox(height: 12),

          // ── Datos del alumno ─────────────────────
          if (nombreAlumno != null || boleta != null)
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.blueGrey50,
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(
                    color: PdfColors.blueGrey200, width: 0.5),
              ),
              child: pw.Row(
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Alumno: ${nombreAlumno ?? 'N/A'}',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blueGrey800,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Boleta: ${boleta ?? 'N/A'}',
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.blueGrey600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          pw.SizedBox(height: 16),

          // ── Tabla ────────────────────────────────
          pw.Table(
            border: pw.TableBorder.all(
              color: PdfColors.blueGrey200,
              width: 0.5,
            ),
            columnWidths: {
              0: const pw.FlexColumnWidth(2.8),
              1: const pw.FlexColumnWidth(1.8),
              2: const pw.FlexColumnWidth(1.3),
              3: const pw.FlexColumnWidth(1.1),
              4: const pw.FlexColumnWidth(1.3),
              5: const pw.FlexColumnWidth(1.6),
              6: const pw.FlexColumnWidth(2.2),
            },
            children: [
              // Encabezado
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                    color: PdfColors.blueGrey800),
                children: [
                  _celdaHeader('Materia'),
                  _celdaHeader('Carrera'),
                  _celdaHeader('Fecha'),
                  _celdaHeader('Hora'),
                  _celdaHeader('Turno'),
                  _celdaHeader('Salón'),
                  _celdaHeader('Profesor'),
                ],
              ),
              // Filas
              ...lista.asMap().entries.map((entry) {
                final i = entry.key;
                final ets = entry.value;
                return pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: i.isEven
                        ? PdfColors.white
                        : PdfColors.blueGrey50,
                  ),
                  children: [
                    _celda(ets.materia),
                    _celda(ets.carrera.split(' - ').first),
                    _celda(ets.fecha),
                    _celda(ets.hora),
                    _celda(TurnoHelper.calcularTurno(ets.hora)),
                    _celda(ets.salon),
                    _celda(ets.profesor),
                  ],
                );
              }),
            ],
          ),

          pw.SizedBox(height: 12),

          pw.Text(
            'Total: ${lista.length} examen(es) registrado(s)',
            style: pw.TextStyle(
              fontSize: 9,
              color: PdfColors.blueGrey500,
              fontStyle: pw.FontStyle.italic,
            ),
          ),

          pw.SizedBox(height: 32),

          // ── Tiburoncito al final ──────────────────
          pw.Center(
            child: pw.Column(
              children: [
                pw.CustomPaint(
                  size: const PdfPoint(120, 60),
                  painter: (canvas, size) {
                    _dibujarTiburonPdf(canvas, size);
                  },
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  '¡Éxito!',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.teal700,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  '"Vive como si fueses a morir mañana. Aprende como si fueses a vivir siempre" Mahatma Gandhi',
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.blueGrey400,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => doc.save(),
      name: 'Comprobante_ETS_${boleta ?? 'alumno'}_${_fechaHoyArchivo()}.pdf',
    );
  }

  static void _dibujarTiburonPdf(PdfGraphics canvas, PdfPoint size) {
    final w = size.x;
    final h = size.y;
    final cx = w * 0.5;
    final cy = h * 0.5;

    // Color del cuerpo
    canvas.setFillColor(const PdfColor(0.29, 0.565, 0.643));

    // Cuerpo principal (elipse)
    canvas.drawEllipse(cx, cy, w * 0.35, h * 0.25);
    canvas.fillPath();

    // Vientre (elipse más clara)
    canvas.setFillColor(const PdfColor(0.72, 0.831, 0.863));
    canvas.drawEllipse(cx + w * 0.02, cy + h * 0.05, w * 0.25, h * 0.15);
    canvas.fillPath();

    // Cola superior
    canvas.setFillColor(const PdfColor(0.23, 0.478, 0.541));
    canvas
      ..moveTo(cx - w * 0.35, cy)
      ..lineTo(cx - w * 0.5, cy - h * 0.25)
      ..lineTo(cx - w * 0.3, cy - h * 0.05)
      ..closePath();
    canvas.fillPath();

    // Cola inferior
    canvas
      ..moveTo(cx - w * 0.35, cy)
      ..lineTo(cx - w * 0.5, cy + h * 0.25)
      ..lineTo(cx - w * 0.3, cy + h * 0.05)
      ..closePath();
    canvas.fillPath();

    // Aleta dorsal
    canvas
      ..moveTo(cx - w * 0.05, cy - h * 0.25)
      ..lineTo(cx, cy - h * 0.45)
      ..lineTo(cx + w * 0.1, cy - h * 0.25)
      ..closePath();
    canvas.fillPath();

    // Cabeza
    canvas.setFillColor(const PdfColor(0.29, 0.565, 0.643));
    canvas.drawEllipse(cx + w * 0.38, cy, w * 0.15, h * 0.28);
    canvas.fillPath();

    // Ojo abierto
    canvas.setFillColor(PdfColors.white);
    canvas.drawEllipse(cx + w * 0.35, cy - h * 0.1, 4, 4);
    canvas.fillPath();

    // Pupila guiñando (línea curva)
    canvas.setStrokeColor(const PdfColor(0.1, 0.1, 0.18));
    canvas.setLineWidth(1.5);
    canvas
      ..moveTo(cx + w * 0.32, cy - h * 0.1)
      ..curveTo(
        cx + w * 0.35, cy - h * 0.18,
        cx + w * 0.38, cy - h * 0.18,
        cx + w * 0.41, cy - h * 0.1,
      );
    canvas.strokePath();

    // Dientes
    canvas.setFillColor(PdfColors.white);
    for (int i = 0; i < 3; i++) {
      final tx = cx + w * 0.2 + i * 5.0;
      canvas
        ..moveTo(tx, cy + h * 0.08)
        ..lineTo(tx + 2.5, cy + h * 0.2)
        ..lineTo(tx + 5, cy + h * 0.08)
        ..closePath();
      canvas.fillPath();
    }
  }

  static pw.Widget _celdaHeader(String texto) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: pw.Text(
        texto,
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
    );
  }

  static pw.Widget _celda(String texto) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        texto,
        style: const pw.TextStyle(
            fontSize: 8, color: PdfColors.blueGrey900),
      ),
    );
  }

  static String _fechaHoy() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/'
        '${now.year}';
  }

  static String _fechaHoyArchivo() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';
  }
}