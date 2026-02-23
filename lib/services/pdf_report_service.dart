import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/housemaid.dart';
import '../models/sub_agent.dart';
import '../models/transaction_model.dart';
import '../models/maid_status.dart';

class PdfReportService {
  static final _fmt = DateFormat('dd MMM yyyy');
  static final _moneyFmt = NumberFormat('#,##0.00');

  // ── Maid Report ──────────────────────────────────────────────────────────
  static Future<void> generateMaidReport({
    required Housemaid maid,
    required SubAgent agent,
    required List<TransactionModel> transactions,
    required String symbol,
  }) async {
    final pdf = pw.Document();
    final totalPaid =
        transactions.fold<double>(0, (s, t) => s + t.amount);
    final remaining = maid.totalCommission - totalPaid;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (ctx) => _buildHeader('Maid Payment Report'),
        footer: (ctx) => _buildFooter(ctx),
        build: (ctx) => [
          _buildMaidInfoSection(maid, agent),
          pw.SizedBox(height: 16),
          _buildFinancialSummary(
            commission: maid.totalCommission,
            paid: totalPaid,
            remaining: remaining,
            symbol: symbol,
          ),
          pw.SizedBox(height: 16),
          _buildTransactionTable(transactions, symbol),
          pw.SizedBox(height: 20),
          _buildBalanceBanner(remaining, symbol),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
    );
  }

  // ── Agent Report ──────────────────────────────────────────────────────────
  static Future<void> generateAgentReport({
    required SubAgent agent,
    required List<Housemaid> maids,
    required List<TransactionModel> allTransactions,
    required String symbol,
  }) async {
    final pdf = pw.Document();

    double totalCommission = 0;
    double totalPaid = 0;
    for (final m in maids) {
      totalCommission += m.totalCommission;
      totalPaid += allTransactions
          .where((t) => t.maidId == m.id)
          .fold<double>(0, (s, t) => s + t.amount);
    }
    final totalPending = totalCommission - totalPaid;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (ctx) => _buildHeader('Sub-Agent Report'),
        footer: (ctx) => _buildFooter(ctx),
        build: (ctx) => [
          _buildAgentInfoSection(agent),
          pw.SizedBox(height: 16),
          _buildFinancialSummary(
            commission: totalCommission,
            paid: totalPaid,
            remaining: totalPending,
            symbol: symbol,
          ),
          pw.SizedBox(height: 16),
          ...maids.map((m) {
            final mTxs = allTransactions
                .where((t) => t.maidId == m.id)
                .toList()
              ..sort((a, b) => b.date.compareTo(a.date));
            final mPaid =
                mTxs.fold<double>(0, (s, t) => s + t.amount);
            final mRemaining = m.totalCommission - mPaid;
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  color: PdfColors.green50,
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8, vertical: 6),
                  child: pw.Row(
                    mainAxisAlignment:
                        pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(m.name,
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 12)),
                      pw.Text(m.status.label,
                          style: const pw.TextStyle(
                              color: PdfColors.green800,
                              fontSize: 10)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 4),
                _buildTransactionTable(mTxs, symbol),
                pw.Row(
                  mainAxisAlignment:
                      pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                        'Remaining: $symbol${_moneyFmt.format(mRemaining)}',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: mRemaining > 0
                                ? PdfColors.orange700
                                : PdfColors.green700)),
                    pw.Text(
                        'Paid: $symbol${_moneyFmt.format(mPaid)}',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green700)),
                  ],
                ),
                pw.SizedBox(height: 16),
                pw.Divider(color: PdfColors.grey300),
                pw.SizedBox(height: 8),
              ],
            );
          }),
          _buildBalanceBanner(totalPending, symbol),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
    );
  }

  // ── Shared builders ───────────────────────────────────────────────────────
  static pw.Widget _buildHeader(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'AGENTRY',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.green800,
              ),
            ),
            pw.Text(
              _fmt.format(DateTime.now()),
              style: const pw.TextStyle(
                  color: PdfColors.grey600, fontSize: 10),
            ),
          ],
        ),
        pw.Text(
          title,
          style: const pw.TextStyle(
              color: PdfColors.grey700, fontSize: 13),
        ),
        pw.Divider(color: PdfColors.green700, thickness: 2),
        pw.SizedBox(height: 8),
      ],
    );
  }

  static pw.Widget _buildFooter(pw.Context ctx) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text('Generated by Agentry',
            style: const pw.TextStyle(
                color: PdfColors.grey400, fontSize: 9)),
        pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}',
            style: const pw.TextStyle(
                color: PdfColors.grey400, fontSize: 9)),
      ],
    );
  }

  static pw.Widget _buildMaidInfoSection(
      Housemaid maid, SubAgent agent) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(color: PdfColors.grey200),
      ),
      padding: const pw.EdgeInsets.all(12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _infoRow('Name', maid.name),
          _infoRow('Passport ID', maid.passportId),
          _infoRow('Sub-Agent', agent.name),
          _infoRow('Status', maid.status.label),
        ],
      ),
    );
  }

  static pw.Widget _buildAgentInfoSection(SubAgent agent) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(color: PdfColors.grey200),
      ),
      padding: const pw.EdgeInsets.all(12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _infoRow('Name', agent.name),
          _infoRow('Contact', agent.contact),
          if (agent.notes.isNotEmpty) _infoRow('Notes', agent.notes),
        ],
      ),
    );
  }

  static pw.Widget _buildFinancialSummary({
    required double commission,
    required double paid,
    required double remaining,
    required String symbol,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
      children: [
        _finCard('Commission', commission, PdfColors.green800, symbol),
        _finCard('Total Paid', paid, PdfColors.green600, symbol),
        _finCard('Outstanding', remaining,
            remaining > 0 ? PdfColors.orange700 : PdfColors.green700, symbol),
      ],
    );
  }

  static pw.Widget _finCard(
      String label, double amount, PdfColor color, String symbol) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey200),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(label,
              style: const pw.TextStyle(
                  fontSize: 9, color: PdfColors.grey600)),
          pw.SizedBox(height: 4),
          pw.Text('$symbol${_moneyFmt.format(amount)}',
              style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: color)),
        ],
      ),
    );
  }

  static pw.Widget _buildTransactionTable(
      List<TransactionModel> transactions, String symbol) {
    if (transactions.isEmpty) {
      return pw.Text('No transactions recorded.',
          style: const pw.TextStyle(
              color: PdfColors.grey500, fontSize: 10));
    }
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey200),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(1.2),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.green700),
          children: [
            _tableHeader('Note'),
            _tableHeader('Date'),
            _tableHeader('Amount'),
          ],
        ),
        ...transactions.map(
          (t) => pw.TableRow(children: [
            _tableCell(t.note.isEmpty ? 'Payment' : t.note),
            _tableCell(_fmt.format(t.date)),
            _tableCell('$symbol${_moneyFmt.format(t.amount)}'),
          ]),
        ),
      ],
    );
  }

  static pw.Widget _buildBalanceBanner(double remaining, String symbol) {
    final fullyPaid = remaining <= 0.001;
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: pw.BoxDecoration(
        color: fullyPaid ? PdfColors.green50 : PdfColors.orange50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(
            color: fullyPaid ? PdfColors.green300 : PdfColors.orange300),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            fullyPaid ? '✓ Fully Paid' : 'Outstanding Balance',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: fullyPaid ? PdfColors.green800 : PdfColors.orange800,
              fontSize: 13,
            ),
          ),
          pw.Text(
            fullyPaid ? '$symbol 0.00' : '$symbol${_moneyFmt.format(remaining)}',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 16,
              color: fullyPaid ? PdfColors.green800 : PdfColors.orange800,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _infoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(children: [
        pw.SizedBox(
          width: 90,
          child: pw.Text('$label:',
              style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                  color: PdfColors.grey700)),
        ),
        pw.Text(value,
            style: const pw.TextStyle(
                fontSize: 10, color: PdfColors.grey800)),
      ]),
    );
  }

  static pw.Widget _tableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text,
          style: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
              fontSize: 10)),
    );
  }

  static pw.Widget _tableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text,
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
    );
  }
}
