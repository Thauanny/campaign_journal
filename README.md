<p align="center">
  <img src="assets/icon/logo.png" width="128" alt="Diário da Campanha" />
</p>

<h1 align="center">Diário da Campanha</h1>

<p align="center">
  <b>Grave a sessão. A IA escreve a crônica.</b><br/>
  Transcrição, resumo, enciclopédia, jornada e fichas dos heróis para mestres de RPG de mesa, em português do Brasil.
</p>

<p align="center">
  Flutter · Dart · SQLite local · Gemini, Groq, Ollama, Claude e OpenAI
</p>

---

## Por que existe

Mestres de RPG passam horas depois de cada sessão lembrando quem era aquele NPC, onde o grupo parou e que gancho ficou aberto. O Diário da Campanha resolve isso: você grava (ou importa) a sessão e o app devolve o diário pronto para **revisar**, não para digitar do zero.

- **Você continua no comando.** Tudo o que a IA extrai passa por uma fila de revisão antes de entrar na campanha.
- **Escolha a IA que couber no seu bolso.** Há opções gratuitas (Gemini, Groq, IA local) e pagas (Claude, OpenAI). O app se adapta aos limites de cada uma.
- **Seus dados ficam com você.** Campanhas, transcrições e fichas ficam num banco SQLite no seu aparelho; as chaves de API ficam no cofre seguro do sistema.

## O que ele faz

### Do áudio ao diário
- **Gravador** de sessão com cronômetro, nível de som, pausa, marcação de momentos importantes e blocos de 5 minutos salvos em disco.
- **Importação** de áudio (Discord, Craig, gravador do celular) ou de **texto já transcrito** (`.txt`, `.srt`, `.vtt` ou colado).
- **Transcrição com horários** de cada fala (Whisper na Groq/OpenAI/local; Gemini em blocos curtos com horários conferidos contra o texto).
- **Resumo e crônica** em terceira pessoa, texto "Anteriormente em…" para ler na mesa e **ganchos em aberto**.
- **Histórico de gravações** da sessão: ouvir, apagar e reanalisar.

### Descobertas e enciclopédia
- Extração de **NPCs, locais, missões, itens, facções e feitiços**, sem duplicar o que a campanha já conhece.
- **Fila de revisão**: confirme, edite ou descarte cada descoberta.
- **Enciclopédia** da campanha, com histórico de cada entrada.
- **Jornada**: linha do tempo da campanha, sessão a sessão, com marcos de início e fim, locais, feitiços e a primeira aparição de cada NPC.

### Combate e heróis
- **Feitiços** registrados a cada uso (quem lançou, em quem, de que lado, resultado), inclusive dos inimigos.
- **Dano, cura e XP** anotados e aplicados aos heróis (pontos de vida atuais, barra de vida, ajuste manual).
- **Fichas por sistema**: D&D 5e, Tormenta20, Pathfinder 2e, Call of Cthulhu, Ordem Paranormal, Vampiro: A Máscara ou outro. O sistema da campanha é enviado à IA para análises mais precisas.
- **Importar fichas em PDF ou foto**, uma ou várias de uma vez, com fila de progresso e conferência campo a campo. Atualize a ficha quando a de papel mudar.

### Para o mestre
- **Perguntar à campanha**: respostas com fonte (sessão e minuto) a partir das transcrições.
- **Planejar a próxima sessão**: início forte, ganchos e segredos sugeridos pela IA.
- **Recap** para os jogadores e **gerador de ideias** de mesa.
- **Exportação** em Markdown, PDF, texto para Discord e **cofre Obsidian** (com wikilinks).

## Uma IA para tudo, adaptada aos limites

Escolha uma "IA da campanha" em *Configurações > IA* e o app usa a mesma para voz, extração, resumo, perguntas e fichas.

| IA | Custo | Texto | Voz | Imagem / ficha |
|---|---|---|---|---|
| **Gemini** (Google) | grátis com limite diário | sim | sim | sim (inclui PDF direto) |
| **Groq** | grátis com limites por minuto/dia | sim | sim (Whisper) | depende dos modelos da conta |
| **Neste computador** (Ollama + Whisper.cpp) | grátis, offline | sim | sim (desktop) | não |
| **Claude** (Anthropic) | pago por uso | sim | não (usa outra IA) | sim (inclui PDF direto) |
| **OpenAI** | pago por uso | sim | sim (Whisper) | sim |

- **Testes da conta**: com a chave salva, um único botão busca os modelos disponíveis e testa **texto, voz, imagem e documento** de uma vez, mostrando o que a conta cobre e o que não cobre.
- **Limites respeitados**: o tamanho dos blocos, as pausas entre chamadas e o contexto enviado mudam conforme a IA escolhida; limites por minuto são esperados e repetidos automaticamente.
- **Aviso de cota**: se o limite diário acabar, um aviso fixo na tela inicial e na campanha informa **quando volta a liberar**.
- **Sem chave, sem problema**: dá para usar só com texto colado e a heurística offline, com resultados mais simples.

## Privacidade

- Banco de dados **local** (SQLite). Nada é enviado a servidores do projeto: não existe servidor do projeto.
- Chaves de API no **cofre seguro** do sistema (Keychain, Keystore etc.).
- Ao usar uma IA em nuvem, o **texto e o áudio da sessão são enviados ao provedor escolhido**, sob os termos dele. Para ficar 100% offline, use a IA local.
- Opção de **apagar o áudio depois de transcrever**, mantendo transcrição e resumo.
- O gravador pede consentimento da mesa na primeira vez.

## Design

Interface em **pixel art estilo anos 2000**: janelas com degradê azul, fonte Pixelify Sans, ícones pixelarticons, alto contraste e telas com uma tarefa por vez (revelação progressiva, seções recolhíveis). Tema claro e escuro.

## Plataformas

Desenvolvido e testado principalmente no **macOS**. O projeto tem as estruturas de **Android, iOS, Windows e Linux** (ícone, tela de abertura e nome já configurados) e a estrutura **web**, mas recursos que dependem de ferramentas locais (Whisper.cpp, ffmpeg, Ollama) existem só no desktop.

## Começando

Requisitos: Flutter com Dart `^3.10`.

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # gera o código do banco (Drift)
flutter run -d macos        # ou -d android, -d windows…
```

Depois, abra **Configurações > IA**, escolha uma IA, cole a chave (o app mostra onde gerá-la) e toque em **Testar tudo**.

### Testes

```bash
flutter analyze
flutter test
```

### Ícone e tela de abertura

O ícone é gerado em pixel art por `tool/make_icon.py` (sem dependências). Para regenerar as imagens das plataformas:

```bash
python3 tool/make_icon.py
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

### Notas de build

`sqlite3`, `path_provider_foundation` e `image` estão fixados em `dependency_overrides` (os build hooks do `objective_c` quebram o `build_runner`; `image` 4.11 é incompatível com o `archive` resolvido). Se o `codesign` do macOS reclamar de "detritus", mova o projeto para fora de `~/Documents`.

## Arquitetura

```
lib/
  ai/        provedores (Gemini, Groq, OpenAI, Claude, Ollama), transcritores, visão,
             cota/limites, testes de capacidade e catálogo de modelos
  core/      configurações, cofre de chaves, tema pixel art, kit de UI, ícones
  data/      banco Drift (SQLite) e repositórios
  domain/    pipeline de processamento, detectores (feitiços, combate), contexto dos
             heróis, perfis de sistemas de RPG, exportação
  features/  telas (campanhas, sessões, gravador, revisão, jornada, fichas, IA…)
```

Pilha: Flutter, Riverpod, go_router, Drift, Dio, just_audio, record, pdfrx e ML Kit (OCR no celular).

## Roadmap

- Leitura de fichas por IA com visão para os demais sistemas.
- Separação de falantes (quem disse o quê) na transcrição.
- Sincronização opcional entre dispositivos.
- Versão web completa.

## Contribuindo

Sugestões e problemas são bem-vindos. Antes de abrir uma contribuição, rode `flutter analyze` e `flutter test`.

## Licença

A definir.
