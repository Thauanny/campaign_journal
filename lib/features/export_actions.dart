import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../core/providers.dart';
import '../core/ui.dart';
import '../data/database.dart';
import '../domain/exporter.dart';
import '../core/px_icons.dart';

Future<ExportData> loadExportData(WidgetRef ref, String cid) async {
  final repo = ref.read(repoProvider);
  final db = repo.db;
  final camp = (await repo.campaign(cid))!;
  final sessions = await repo.sessionsOf(cid);
  final ents = await repo.entitiesOf(cid);
  final sids = sessions.map((s) => s.id).toSet();
  final mentions = (await db.select(db.mentions).get()).where((m) => sids.contains(m.sessionId)).toList();
  final events = (await db.select(db.events).get()).where((e) => sids.contains(e.sessionId)).toList();
  final segs = <String, List<Segment>>{for (final s in sessions) s.id: await repo.segmentsOf(s.id)};
  return ExportData(camp, sessions, ents, mentions, events, (id) => segs[id] ?? []);
}

/// A fonte padrão do PDF só tem Latin-1: troca pontuação tipográfica.
String pdfSafe(String s) => s
    .replaceAll(RegExp('[—–]'), '-')
    .replaceAll(RegExp('[“”]'), '"')
    .replaceAll(RegExp('[‘’]'), "'")
    .replaceAll('…', '...')
    .replaceAll('\u{1F4DC}', '')
    .replaceAll(RegExp(r'[^\x00-\xFF]'), '');

Future<Uint8List> markdownToPdf(String md) async {
  final doc = pw.Document();
  final lines = pdfSafe(md).split('\n');
  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(40),
    build: (_) => [
      for (final l in lines)
        if (l.startsWith('#'))
          pw.Padding(padding: const pw.EdgeInsets.only(top: 10, bottom: 4), child: pw.Text(l.replaceFirst(RegExp(r'^#+\s*'), ''), style: pw.TextStyle(fontSize: 18 - '#'.allMatches(l.split(' ').first).length * 2.0, fontWeight: pw.FontWeight.bold)))
        else
          pw.Text(l.replaceAll('**', '').replaceAll('*', ''), style: const pw.TextStyle(fontSize: 11)),
    ],
  ));
  return doc.save();
}

/// Menu de exportação: Markdown, PDF, texto para Discord e cofre Obsidian.
Future<void> showExportSheet(BuildContext context, WidgetRef ref, String cid, {String? sessionId}) async {
  final choice = await showModalBottomSheet<String>(context: context, builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(title: Text(sessionId == null ? 'Exportar campanha' : 'Exportar sessão', style: Theme.of(ctx).textTheme.titleMedium)),
        ListTile(leading: const Icon(PxIcons.fileAlt), title: const Text('Markdown (.md)'), onTap: () => Navigator.pop(ctx, 'md')),
        ListTile(leading: const Icon(PxIcons.file), title: const Text('PDF'), onTap: () => Navigator.pop(ctx, 'pdf')),
        if (sessionId != null) ListTile(leading: const Icon(PxIcons.messageText), title: const Text('Texto para Discord (copiar)'), onTap: () => Navigator.pop(ctx, 'discord')),
        ListTile(leading: const Icon(PxIcons.folderPlus), title: const Text('Cofre Obsidian (pasta)'), onTap: () => Navigator.pop(ctx, 'obsidian')),
      ])));
  if (choice == null || !context.mounted) return;
  try {
    final d = await loadExportData(ref, cid);
    final session = sessionId == null ? null : d.sessions.firstWhere((s) => s.id == sessionId);
    final base = session == null ? d.campaign.name : '${d.campaign.name} - Sessão ${session.number}';
    final md = session == null ? campaignMarkdown(d) : sessionMarkdown(d, session, transcript: true);
    switch (choice) {
      case 'md':
        final u = await FilePicker.saveFile(fileName: '$base.md', bytes: Uint8List.fromList(utf8.encode(md)), mimeType: 'text/markdown');
        if (u != null && context.mounted) snack(context, 'Markdown salvo.');
      case 'pdf':
        final u = await FilePicker.saveFile(fileName: '$base.pdf', bytes: await markdownToPdf(md), mimeType: 'application/pdf');
        if (u != null && context.mounted) snack(context, 'PDF salvo.');
      case 'discord':
        final msgs = discordMessages(d, session!);
        await Clipboard.setData(ClipboardData(text: msgs.join('\n---\n')));
        if (context.mounted) snack(context, msgs.length == 1 ? 'Copiado para colar no Discord.' : 'Copiado em ${msgs.length} partes (separadas por ---, limite de 2000 caracteres por mensagem).');
      case 'obsidian':
        final dir = await FilePicker.getDirectoryPath(dialogTitle: 'Escolha a pasta do cofre Obsidian');
        if (dir == null) return;
        final files = obsidianVault(d, transcript: true);
        for (final e in files.entries) {
          final f = File(p.join(dir, d.campaign.name.replaceAll('/', '-'), e.key));
          await f.parent.create(recursive: true);
          await f.writeAsString(e.value);
        }
        if (context.mounted) snack(context, '${files.length} notas gravadas em "$dir".');
    }
  } catch (e) {
    if (context.mounted) snack(context, 'Falha ao exportar: $e');
  }
}
