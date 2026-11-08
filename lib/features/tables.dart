import 'dart:math';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers.dart';
import '../core/px_icons.dart';
import '../core/rpg_theme.dart';
import '../core/ui.dart';
import '../data/database.dart';
import '../data/repository.dart';

final _rng = Random();
T _pick<T>(List<T> l) => l[_rng.nextInt(l.length)];

const _ancestries = {
  'Humano': (['Aldr', 'Bren', 'Cael', 'Dorn', 'Edm', 'Fenn', 'Gar', 'Hal', 'Ior', 'Kael', 'Lor', 'Mar', 'Ned', 'Ori', 'Per', 'Rav', 'Sel', 'Tob', 'Ulr', 'Val'], ['a', 'o', 'ik', 'wen', 'ric', 'an', 'is', 'en', 'ard', 'ia'], ['Cascalho', 'Ventania', 'Ferraz', 'da Ponte', 'Corvo', 'Silvestre', 'Pedraalta', 'Marés', 'do Vale', 'Brasa']),
  'Elfo': (['Ael', 'Cal', 'Elar', 'Fae', 'Ill', 'Lir', 'Mir', 'Nae', 'Syl', 'Thal', 'Vae', 'Yl'], ['ion', 'ara', 'indel', 'wen', 'thir', 'iel', 'ora', 'ael'], ['Folha-de-Prata', 'Luz-da-Lua', 'Canto-do-Vento', 'Raiz-Antiga', 'Orvalho', 'Brisa-Estelar']),
  'Anão': (['Bor', 'Dur', 'Gim', 'Hrod', 'Kaz', 'Mor', 'Thor', 'Brun', 'Dag', 'Rurik'], ['in', 'gar', 'li', 'ek', 'rim', 'din', 'bar', 'gan'], ['Martelo-de-Ferro', 'Barba-Rubra', 'Punho-de-Pedra', 'Forja-Fria', 'Escudo-Negro', 'Veio-de-Ouro']),
  'Halfling': (['Bil', 'Cor', 'Dill', 'Fro', 'Mer', 'Pip', 'Rosa', 'Sam', 'Tuck', 'Wil'], ['bo', 'lo', 'a', 'o', 'ry', 'ie', 'wick', 'by'], ['Pés-Ligeiros', 'Barriga-Cheia', 'Colina-Verde', 'Torta-Quente', 'Fundo-do-Poço', 'Tacho-Dourado']),
  'Orc': (['Gru', 'Mog', 'Ur', 'Thok', 'Gash', 'Dra', 'Zug', 'Krag', 'Bol', 'Rok'], ['k', 'gash', 'ak', 'ug', 'nar', 'ash', 'gol', 'dar'], ['Quebra-Ossos', 'Olho-Vermelho', 'Machado-Sujo', 'Sangue-Frio', 'Dente-Torto', 'Punho-de-Guerra']),
};

String _name(String anc) {
  final a = _ancestries[anc]!;
  return '${_pick(a.$1)}${_pick(a.$2)} ${_pick(a.$3)}';
}

String _tavern() {
  // (substantivo, feminino?)
  const nouns = [('Javali', false), ('Dragão', false), ('Corvo', false), ('Caldeirão', false), ('Gato', false), ('Cervo', false), ('Machado', false), ('Barril', false), ('Lanterna', true), ('Grifo', false), ('Sapo', false), ('Coruja', true), ('Raposa', true)];
  const adjs = ['Bêbado', 'Dourado', 'Cego', 'Dançante', 'Manco', 'Risonho', 'Enferrujado', 'Sonolento', 'Faminto'];
  final (n, fem) = _pick(nouns);
  final adj = _pick(adjs);
  return fem ? 'A $n ${adj.replaceAll(RegExp(r'o$'), 'a')}' : 'O $n $adj';
}

String _rumor() => _pick([
      'Dizem que ${_pick(['o ferreiro', 'a viúva do moinho', 'o capitão da guarda', 'o velho sacerdote'])} anda recebendo visitas à noite, ${_pick(['de gente encapuzada', 'de criaturas que ninguém vê', 'de forasteiros com sotaque estranho'])}.',
      'Um mercador jura que ${_pick(['a estrada do norte', 'a ponte velha', 'a floresta dos corvos'])} está ${_pick(['amaldiçoada', 'tomada por bandidos', 'sumindo do mapa à noite'])}.',
      'Contam que há um tesouro enterrado ${_pick(['sob a taverna', 'nas ruínas do forte', 'no fundo do poço seco'])}, mas ${_pick(['quem o procura some', 'um guardião o protege', 'só aparece na lua cheia'])}.',
      'Alguém viu ${_pick(['um dragão jovem', 'um cavaleiro sem cabeça', 'uma criança que não envelhece'])} perto de ${_pick(['Pedraalta', 'do rio', 'das minas'])}.',
    ]);

String _road() => _pick([
      'Uma carroça tombada, sem cocheiro — e rastros que levam à mata.',
      'Três bandidos cobram pedágio, nervosos: parecem fugir de algo pior.',
      'Um viajante ferido pede ajuda e jura que foi traído pelo próprio grupo.',
      'Névoa densa. Sons de sinos vindos de lugar nenhum.',
      'Uma patrulha da guarda procura "quatro aventureiros" que combinam com a descrição do grupo.',
      'Um mercador ambulante vende itens suspeitosamente baratos.',
      'Lobos famintos seguem o grupo à distância, sem atacar.',
    ]);

String _loot() => _pick([
      'Uma bolsa com ${(_rng.nextInt(90) + 10)} peças de prata e um dente de ouro.',
      'Um anel simples, gravado por dentro com um nome que ninguém conhece.',
      'Uma poção turva: cheira a menta e a problema.',
      'Um mapa rasgado que mostra metade de uma masmorra.',
      'Uma adaga de ótima fabricação com o brasão de uma casa extinta.',
      'Um diário com páginas arrancadas.',
      'Um amuleto frio ao toque, que esquenta perto de mortos-vivos.',
    ]);

String _hook() => 'Um ${_pick(['mercador', 'nobre', 'clérigo', 'bardo', 'guarda'])} ${_pick(['assustado', 'misterioso', 'endividado', 'astuto'])} pede ajuda para ${_pick(['recuperar um objeto roubado', 'escoltar uma carga até a fronteira', 'descobrir quem anda sabotando o porto', 'encontrar uma pessoa desaparecida'])} — mas ${_pick(['esconde parte da verdade', 'tem pressa demais', 'oferece pagamento bom demais'])}.';

/// Tabelas aleatórias offline: nomes, tavernas, rumores, encontros, tesouros e ganchos.
class TablesScreen extends ConsumerStatefulWidget {
  final String cid;
  const TablesScreen(this.cid, {super.key});
  @override
  ConsumerState<TablesScreen> createState() => _TablesState();
}

class _TablesState extends ConsumerState<TablesScreen> {
  String _anc = 'Humano';
  final _res = <String, String>{};

  void _roll(String k, String Function() f) => setState(() => _res[k] = f());

  Future<void> _saveNpc(String name) async {
    await ref.read(repoProvider).saveEntity(EntitiesCompanion.insert(
        id: newId(), campaignId: widget.cid, kind: 'npc', name: name, description: Value('Gerado na tabela de nomes (${_anc.toLowerCase()}).'), review: const Value('confirmed')));
    if (mounted) snack(context, '"$name" salvo na enciclopédia.');
  }

  @override
  Widget build(BuildContext context) {
    final p = context.rpg;
    Widget card(String key, IconData icon, String title, String Function() f, {List<Widget> extra = const [], Widget? save}) {
      final r = _res[key];
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: RpgCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 40, height: 40, color: p.bgDeep, child: Icon(icon, color: p.gold, size: 24)),
              const SizedBox(width: 12),
              Expanded(child: Text(title.toUpperCase(), style: pxText(15, p.text))),
            ]),
            ...extra,
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: p.bgDeep,
              child: Text(r ?? 'Toque em ROLAR.', style: TextStyle(fontSize: 22, height: 1.15, color: r == null ? p.muted : p.gold)),
            ),
            const SizedBox(height: 10),
            Wrap(spacing: 10, runSpacing: 10, children: [
              RuneButton('Rolar', icon: PxIcons.dice, compact: true, onPressed: () => _roll(key, f)),
              if (r != null) RuneButton('Copiar', icon: PxIcons.copy, compact: true, tone: RuneTone.ghost, onPressed: () { Clipboard.setData(ClipboardData(text: r)); snack(context, 'Copiado.'); }),
              if (r != null && save != null) save,
            ]),
          ]),
        ),
      );
    }

    return Scaffold(
      appBar: GameBar(title: const Text('Gerador de ideias'), leading: BackButton(onPressed: () => context.go('/campaign/${widget.cid}'))),
      body: MaxWidth(
        width: 760,
        ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 48), children: [
          Text('Sorteie ideias na hora para improvisar na mesa: toque em ROLAR em qualquer cartão. Funciona offline e não usa IA.', style: TextStyle(color: p.muted, fontSize: 22, height: 1.3)),
          const SizedBox(height: 14),
          card('name', PxIcons.user, 'Nome de NPC', () => _name(_anc),
              extra: [
                const SizedBox(height: 10),
                Wrap(children: [for (final a in _ancestries.keys) PxChoice(a, _anc == a, () => setState(() => _anc = a))]),
              ],
              save: RuneButton('Salvar NPC', icon: PxIcons.userPlus, compact: true, tone: RuneTone.arcane, onPressed: () => _saveNpc(_res['name']!))),
          card('tavern', PxIcons.buildings, 'Taverna', _tavern),
          card('rumor', PxIcons.message, 'Rumor', _rumor),
          card('road', PxIcons.map, 'Encontro na estrada', _road),
          card('loot', PxIcons.coin, 'Tesouro', _loot),
          card('hook', PxIcons.flag, 'Gancho de aventura', _hook),
        ]),
      ),
    );
  }
}
