import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../constants/app_strings.dart';
import '../../data/models/quotation_model.dart';
import 'currency_formatter.dart';

class PdfGenerator {
  static Future<Uint8List> generateQuotationPdf(QuotationModel quotation) async {
    final pdf = pw.Document();

    final fontRegular = await PdfGoogleFonts.poppinsRegular();
    final fontBold = await PdfGoogleFonts.poppinsBold();
    final fontItalic = await PdfGoogleFonts.poppinsItalic();

    pw.ImageProvider? logoImage;
    try {
      logoImage = await imageFromAssetBundle('assets/images/ajs-penawaran.png');
    } catch (_) {
      try {
        logoImage = await imageFromAssetBundle('assets/images/logo.png');
      } catch (_) {}
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
          italic: fontItalic,
        ),
        build: (pw.Context context) {
          return [
            // Header Section (Kop Surat)
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (logoImage != null) ...[
                  pw.Container(
                    width: 50,
                    height: 50,
                    margin: const pw.EdgeInsets.only(right: 10),
                    child: pw.Image(logoImage),
                  ),
                ],
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        AppStrings.companyAbbr,
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#1A3A5C'),
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        AppStrings.companyDefaultName,
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#1A3A5C'),
                        ),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        AppStrings.companyTagline,
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontStyle: pw.FontStyle.italic,
                          color: PdfColors.grey800,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        AppStrings.companyDefaultAddress,
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontStyle: pw.FontStyle.italic,
                          color: PdfColors.grey800,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        AppStrings.companyContactInfo,
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontStyle: pw.FontStyle.italic,
                          color: PdfColors.grey800,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 12),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#1A3A5C'),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                      ),
                      child: pw.Text(
                        'PENAWARAN HARGA',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      'No: ${quotation.quotationNumber}',
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Tanggal: ${CurrencyFormatter.formatDate(quotation.createdAt)}',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Divider(thickness: 1.5, color: PdfColor.fromHex('#1A3A5C')),
            pw.SizedBox(height: 12),

            // Client Info Card
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F8FAFC'),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'KEPADA YTH:',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    quotation.client.name,
                    style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                  ),
                  if (quotation.client.address.isNotEmpty) ...[
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Alamat: ${quotation.client.address}',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ],
                  if (quotation.client.phone.isNotEmpty) ...[
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Telp: ${quotation.client.phone}',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ],
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // Itemized Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: {
                0: const pw.FixedColumnWidth(28),  // No
                1: const pw.FlexColumnWidth(4),   // Uraian Pekerjaan
                2: const pw.FixedColumnWidth(45),  // Satuan
                3: const pw.FixedColumnWidth(45),  // Vol
                4: const pw.FlexColumnWidth(2),   // Harga Satuan
                5: const pw.FlexColumnWidth(2.2), // Jumlah
              },
              children: [
                // Table Header
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColor.fromHex('#1A3A5C')),
                  children: [
                    _buildCell('No', align: pw.Alignment.center, isHeader: true),
                    _buildCell('Uraian Pekerjaan', align: pw.Alignment.centerLeft, isHeader: true),
                    _buildCell('Sat', align: pw.Alignment.center, isHeader: true),
                    _buildCell('Vol', align: pw.Alignment.center, isHeader: true),
                    _buildCell('Harga Satuan', align: pw.Alignment.centerRight, isHeader: true),
                    _buildCell('Jumlah', align: pw.Alignment.centerRight, isHeader: true),
                  ],
                ),
                // Table Data Rows
                ...quotation.items.asMap().entries.map((entry) {
                  final index = entry.key + 1;
                  final item = entry.value;
                  return pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: index % 2 == 0 ? PdfColor.fromHex('#F8FAFC') : PdfColors.white,
                    ),
                    children: [
                      _buildCell('$index', align: pw.Alignment.center),
                      _buildCell(item.description, align: pw.Alignment.centerLeft),
                      _buildCell(item.unit, align: pw.Alignment.center),
                      _buildCell(CurrencyFormatter.formatNumber(item.qty), align: pw.Alignment.center),
                      _buildCell(CurrencyFormatter.formatRupiah(item.unitPrice), align: pw.Alignment.centerRight),
                      _buildCell(CurrencyFormatter.formatRupiah(item.total), align: pw.Alignment.centerRight),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 12),

            // Summary Calculation & Notes
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Left Column: Notes
                pw.Expanded(
                  flex: 5,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (quotation.notes != null && quotation.notes!.trim().isNotEmpty) ...[
                        pw.Text(
                          'Catatan / Syarat & Ketentuan:',
                          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(6),
                          decoration: pw.BoxDecoration(
                            color: PdfColor.fromHex('#F1F5F9'),
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                          ),
                          child: pw.Text(
                            quotation.notes!,
                            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                pw.SizedBox(width: 16),

                // Right Column: Summary Totals
                pw.Expanded(
                  flex: 5,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    child: pw.Column(
                      children: [
                        _buildSummaryRow('Subtotal', CurrencyFormatter.formatRupiah(quotation.subtotal)),
                        if (quotation.discountPercent > 0)
                          _buildSummaryRow(
                            'Diskon (${CurrencyFormatter.formatNumber(quotation.discountPercent)}%)',
                            '- ${CurrencyFormatter.formatRupiah(quotation.discountAmount)}',
                          ),
                        if (quotation.taxPercent > 0)
                          _buildSummaryRow(
                            'PPN (${CurrencyFormatter.formatNumber(quotation.taxPercent)}%)',
                            CurrencyFormatter.formatRupiah(quotation.taxAmount),
                          ),
                        pw.Divider(thickness: 1, color: PdfColors.grey400),
                        _buildSummaryRow(
                          'TOTAL HARGA',
                          CurrencyFormatter.formatRupiah(quotation.grandTotal),
                          isBold: true,
                          color: PdfColor.fromHex('#1A3A5C'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            pw.Spacer(),

            // Signature & Footer
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Klien / Pemesan,', style: const pw.TextStyle(fontSize: 9)),
                    pw.SizedBox(height: 45),
                    pw.Text(
                      '( ${quotation.client.name} )',
                      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Hormat Kami,', style: const pw.TextStyle(fontSize: 9)),
                    pw.Text(AppStrings.companyDefaultName, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                    pw.SizedBox(height: 45),
                    pw.Text(
                      '( Management )',
                      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildCell(
    String text, {
    pw.Alignment align = pw.Alignment.centerLeft,
    bool isHeader = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 6),
      child: pw.Align(
        alignment: align,
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: isHeader ? 8 : 8,
            fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: isHeader ? PdfColors.white : PdfColors.black,
          ),
        ),
      ),
    );
  }

  static pw.Widget _buildSummaryRow(
    String title,
    String value, {
    bool isBold = false,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: isBold ? 10 : 8.5,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color ?? PdfColors.black,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: isBold ? 10 : 8.5,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color ?? PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> printOrSharePdf(QuotationModel quotation) async {
    final pdfBytes = await generateQuotationPdf(quotation);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Penawaran_${quotation.quotationNumber.replaceAll('/', '_')}',
    );
  }

  static Future<void> sharePdf(QuotationModel quotation) async {
    final pdfBytes = await generateQuotationPdf(quotation);
    final sanitizedNo = quotation.quotationNumber.replaceAll('/', '_');
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'Penawaran_$sanitizedNo.pdf',
    );
  }
}
