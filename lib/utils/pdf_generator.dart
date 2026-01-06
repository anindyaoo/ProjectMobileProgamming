import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../model/transaction_model.dart';

class PdfGenerator {
  static Future<Uint8List> generatePdf({
    required int month,
    required int year,
    required double totalIncome,
    required double totalExpense,
    required double balance,
    required List<TransactionModel> transactions,
  }) async {
    final pdf = pw.Document();
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final monthName = DateFormat('MMMM', 'id_ID').format(DateTime(year, month));

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Laporan Keuangan',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Periode: $monthName $year',
                style: const pw.TextStyle(fontSize: 16),
              ),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildSummaryItem(
                    'Total Masuk',
                    totalIncome,
                    PdfColors.green,
                    currencyFormatter,
                  ),
                  _buildSummaryItem(
                    'Total Keluar',
                    totalExpense,
                    PdfColors.red,
                    currencyFormatter,
                  ),
                  _buildSummaryItem(
                    'Saldo Bersih',
                    balance,
                    PdfColors.blue,
                    currencyFormatter,
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                context: context,
                headers: ['Tanggal', 'Keterangan', 'Kategori', 'Nominal'],
                data: transactions.map((t) {
                  final isIncome = t.type == 'Pemasukan';
                  final nominal = currencyFormatter.format(t.amount);
                  return [
                    DateFormat('dd/MM/yyyy').format(t.date),
                    t.note.isNotEmpty ? t.note : t.category,
                    t.category,
                    isIncome ? '+ $nominal' : '- $nominal',
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey),
                cellAlignment: pw.Alignment.centerLeft,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.centerLeft,
                  3: pw.Alignment.centerRight,
                },
                border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildSummaryItem(
    String title,
    double value,
    PdfColor color,
    NumberFormat formatter,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          formatter.format(value),
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
