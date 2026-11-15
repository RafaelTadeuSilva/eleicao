# Sugestões de melhoria — Urna Eletrônica

Análise feita em 15/11/2026 sobre o branch `main` (commit `080e543`), lendo todo o
código de `lib/`. Estado atual: `flutter analyze` sem avisos e os 190 testes passando.

Os itens estão numerados para facilitar a referência e ordenados por prioridade
dentro de cada seção. Itens marcados com **(verificar)** dependem de algo fora do
repositório (regras do Firestore, aparelho usado) que não foi possível confirmar.

## Resumo — o que atacar primeiro

| # | Problema | Impacto |
|---|---|---|
| 1.1 | A pilha de navegação cresce uma `VotacaoPage` por eleitor | Lentidão ao longo do dia; o botão "voltar" reabre a urna e permite votar de novo |
| 1.2 | Erro ao gravar voto é engolido (só `debugPrint`) | Voto perdido sem ninguém saber |
| 1.3 | Sair da urna para a área administrativa não pede senha | Qualquer eleitor acessa apuração e cadastros |
| 1.4 | Candidatos carregam de forma assíncrona sem tela de espera | Primeiro eleitor pode ver "CANDIDATO INVÁLIDO" para um número válido |
| 1.5 | Editar a matrícula de um aluno cria um segundo cadastro | Aluno duplicado |
| 1.6 | Número com zero à esquerda (ex.: `05`) é aceito no cadastro e reprovado na verificação e no CSV | Relatório acusa erro falso; planilha não importa |
| 2.1 | Tela da urna usa tamanhos fixos em pixels | Estouro de layout em celulares e em cargos com 4–5 dígitos |

---

## 1. Problemas de funcionamento (bugs e riscos)

### 1.1 Pilha de navegação cresce a cada eleitor
[votacao_control.dart:94-113](lib/src/features/urna/controllers/votacao_control.dart#L94-L113)

`fimVotacao` faz `push` da tela "FIM" e depois `pushReplacement` para
`ProximoEleitorPage`. O `pushReplacement` troca apenas a tela "FIM"; a
`VotacaoPage` que estava embaixo continua na pilha. Sequência real:

```
[Votacao] → [Votacao, FIM] → [Votacao, Proximo] → [Votacao, Votacao2] → [Votacao, Votacao2, FIM] → …
```

Consequências:
- Depois de N eleitores existem N `VotacaoPage` vivas, cada uma com os
  `Timer.periodic` de 200 ms dos `NumberLabel` rodando.
- O botão "voltar" do Android (ou Esc no desktop) volta para uma `VotacaoPage`
  antiga, pronta para votar de novo.

**Sugestão:** usar `pushAndRemoveUntil(..., (r) => false)` ao ir para
`ProximoEleitorPage`, ou transformar "FIM" em um estado da própria
`VotacaoPage`. Envolver `VotacaoPage` e `ProximoEleitorPage` em
`PopScope(canPop: false)`.

### 1.2 Falha ao gravar voto é silenciosa
[votacao_control.dart:82-92](lib/src/features/urna/controllers/votacao_control.dart#L82-L92)

`gravaVoto()` não é aguardado e o `catch` só faz `debugPrint`. Como `votoAtual`
é limpo antes da gravação, se o Firestore recusar (regra de segurança, cota,
coleção errada) o voto some e a urna segue para "FIM" normalmente.

**Sugestão:** em caso de erro, guardar os votos em uma fila local
(`SharedPreferences` ou arquivo) e reenviar; mostrar na Home um contador de
"votos pendentes de envio"; no mínimo, avisar o fiscal na tela.

### 1.3 Área administrativa sem proteção
[teclado_widget.dart:40-50](lib/src/widgets/teclado_widget.dart#L40-L50)

Um toque longo no nome da zona leva direto para a `HomePage`, de onde se abre a
apuração (parcial, durante a votação), se excluem candidatos e se troca o
evento. Não há PIN nem confirmação.

**Sugestão:** pedir um PIN de mesário para sair da urna e para abrir Apuração.

### 1.4 Lista de candidatos pode não estar pronta
[votacao_control.dart:16-24](lib/src/features/urna/controllers/votacao_control.dart#L16-L24)

O construtor chama `carregaListaCandidatos()` sem aguardar. Enquanto a consulta
não volta, `listCandidato` está vazia (no primeiro eleitor) e qualquer número
digitado mostra "CANDIDATO INVÁLIDO". Se a consulta falhar, a exceção não é
tratada e a urna fica sem candidatos.

Além disso, a lista inteira (com as fotos em base64) é baixada de novo a cada
eleitor, o que custa leituras do Firestore e banda.

**Sugestão:** carregar os candidatos uma vez ao "Iniciar Urna" (a Home já faz
essa consulta em `navigateToVotacao` e descarta o resultado), mostrar
carregamento/erro e reaproveitar a lista entre eleitores.

### 1.5 Editar matrícula duplica o aluno
[aluno_cad_page.dart:133-145](lib/src/features/cadastro/pages/aluno_cad_page.dart#L133-L145)

Na edição o campo Matrícula continua editável. `update` usa a matrícula nova
como id e o `FirestoreDb.update` faz `set(merge: true)`, então um documento novo
é criado e o antigo permanece. Na criação, uma matrícula já existente
sobrescreve o outro aluno sem aviso. O título de eleitor duplicado só é
conferido na importação CSV, não no formulário.

**Sugestão:** bloquear o campo na edição; na criação, verificar se a matrícula
e o título já existem.

### 1.6 Zero à esquerda: regras diferentes em cada lugar
- Formulário: valida o **texto** (`"05".length == 2`) — aceita.
  [candidato_cad_page.dart:119](lib/src/features/cadastro/pages/candidato_cad_page.dart#L119)
- Verificação: valida o **inteiro** (`5.toString().length == 1`) — acusa erro.
  [verificacao_candidatos.dart:116](lib/src/features/cadastro/controllers/verificacao_candidatos.dart#L116)
- CSV: também valida o inteiro — recusa a linha.
  [candidato_csv.dart:173](lib/src/features/cadastro/importacao/candidato_csv.dart#L173)

Na urna o número funciona (digitar 0 e 5 encontra o candidato 5).

**Sugestão:** decidir uma regra única. Ou proibir zero à esquerda no
formulário, ou trocar as outras duas validações por "número < 10^dígitos".

### 1.7 Foto que falha no envio vira "Salvo com sucesso"
[api_storage_base64.dart:47-49](lib/src/repositories/storage/api_storage_base64.dart#L47-L49),
[candidato_cad_page.dart:354-360](lib/src/features/cadastro/pages/candidato_cad_page.dart#L354-L360)

`uploadFile` devolve `''` em qualquer erro. A mensagem final testa o campo de
texto (que ainda tem o caminho do arquivo), não o resultado, e diz "Salvo com
sucesso" com o candidato gravado sem foto.

### 1.8 Tamanho das fotos em base64
[api_storage_base64.dart:30-46](lib/src/repositories/storage/api_storage_base64.dart#L30-L46)

- A imagem é reduzida para 320 px mas codificada em **PNG**; uma foto em PNG
  nesse tamanho costuma passar de 150 KB (o comentário fala em 30–50 KB).
- O caminho alternativo grava os bytes originais sem limite e rotula como
  `image/jpeg`; uma foto de celular estoura o limite de 1 MB por documento.
- Todas as consultas `find({})` (listas, verificação, checagem de duplicado,
  início da urna) baixam todas as fotos.
- `resolveImageProvider` decodifica o base64 a cada rebuild; na urna isso
  acontece a cada tecla.

**Sugestão:** comprimir em JPEG (pacote `image`) ou usar o Firebase Storage;
decodificar uma vez e guardar os bytes em memória.

### 1.9 Liberação de urna está pela metade
[liberacao_urna_repository_impl.dart:19-23](lib/src/features/cadastro/repositories/liberacao_urna/liberacao_urna_repository_impl.dart#L19-L23)

`proximaLiberacao` sempre devolve uma liberação fictícia, então a urna libera
sozinha a cada 3 s (o README documenta isso como intencional). Efeitos:
- A tela "Liberação" grava registros que ninguém lê; `finalizaLiberacao` nunca
  executa (id sempre nulo); `eleitorAtual` é preenchido e nunca usado.
- Não há registro de quem já votou.

**Sugestão:** ou remover a tela e o código morto, ou ligar de verdade
(consulta por `urna` + `status == 0`, de preferência com `snapshots()` no lugar
do polling) e tornar o modo "liberação automática" uma opção do evento.

Na tela em si
([liberacao_urna_page.dart](lib/src/features/urna/pages/liberacao_urna_page.dart),
[liberacao_urna_control.dart:14-28](lib/src/features/urna/controllers/liberacao_urna_control.dart#L14-L28)):
- `int.parse` em campo vazio ou com letras lança `FormatException` sem tratamento.
- Confirma mesmo sem eleitor encontrado.
- A busca roda a cada tecla, sem debounce; respostas fora de ordem podem
  mostrar o eleitor errado.
- Controllers e `FocusNode` não são descartados.

### 1.10 Configuração do evento não é sincronizada entre aparelhos
[injector.dart:75-140](lib/src/injector.dart#L75-L140)

Cada aparelho usa a cópia local do evento (`SharedPreferences`). Se o
administrador adicionar uma zona ou trocar os cargos em um aparelho, as outras
urnas continuam com a versão antiga até alguém abrir o diálogo e reativar.

**Sugestão:** ao abrir a Home, buscar o evento ativo em `Eleicoes` e avisar
(ou atualizar) se estiver diferente.

### 1.11 Valores desconhecidos caem em "Vereador" sem aviso
[cargo.dart:98-106](lib/src/features/urna/enums/cargo.dart#L98-L106)

`getCargoByCodigo` e `getCargoByDescricao` usam `Cargo.vereador` como padrão.
Um voto ou candidato com cargo inválido é contado como vereador na apuração.

**Sugestão:** devolver `null` e tratar (ignorar e listar como "inconsistente").

### 1.12 Mappers sem tolerância a dados incompletos
[aluno_mapper_impl.dart:6-12](lib/src/features/cadastro/mapper/aluno_mapper_impl.dart#L6-L12),
[liberacao_urna_mapper_impl.dart:6-15](lib/src/features/cadastro/mapper/liberacao_urna_mapper_impl.dart#L6-L15)

Atribuem `map['nome']`, `map['turma']` etc. direto. Um documento sem o campo
(ou com número gravado como texto) derruba a lista inteira. Os mappers de
candidato e voto já tratam isso; vale igualar. `AlunoControl.getById` também
usa `aluno!`.

### 1.13 Operações de banco sem tratamento de erro nem indicador
- `FirestoreDb.update` e `delete` sempre retornam `true`
  ([firestore_db.dart:33-37](lib/src/repositories/remote/firestore_db.dart#L33-L37)),
  então os ramos "Erro ao salvar" nunca acontecem; erros reais chegam como
  exceção não tratada.
- `update` usa `set(merge: true)`, que cria o documento se não existir.
- Sem rede, `await` de escrita no Firestore não retorna; as telas de cadastro
  ficam paradas sem indicação.
- Apuração, listas, "Iniciar Urna" e exclusão de candidato não têm `try/catch`.
- `main()` não trata falha em `inject()`: se o Firebase não inicializar, o app
  fica em tela branca
  ([main.dart:6-15](lib/main.dart#L6-L15)).

### 1.14 Diálogo de evento: dígitos fora da lista quebram a tela
[evento_eleicao_dialog.dart:449-452](lib/src/features/home/widgets/evento_eleicao_dialog.dart#L449-L452)

O modelo aceita 1 a 6 dígitos (`clamp(1, 6)`), mas o `DropdownButton` só
oferece 2 a 5. Um evento com 1 ou 6 dígitos (salvo por outra versão ou editado
no console) dispara erro de asserção ao abrir o diálogo.

### 1.15 Orientação não volta ao sair da urna
[votacao_page.dart:19-20](lib/src/features/urna/pages/votacao_page.dart#L19-L20)

A urna trava em paisagem; ao voltar para a Home (toque longo) a orientação
retrato definida em `main()` não é restaurada.

### 1.16 Sons em `.mov`
[audio_player.dart](lib/src/functions/audio_player.dart)

`.mov` é um contêiner da Apple; em Android, Windows e web a reprodução não é
garantida **(verificar nos aparelhos usados)**. Converter para `.mp3` ou
`.wav`. Com um único `AudioPlayer`, teclas rápidas cortam o som anterior;
`PlayerMode.lowLatency` ou `AudioPool` resolvem. A interface declara `void
play` e a implementação é `Future`, então erros de áudio ficam sem tratamento.

### 1.17 Segurança do Firestore **(verificar)**
O app não usa autenticação (`firebase_auth` não está no projeto) e o
repositório não tem `firestore.rules`. Para funcionar assim, as regras precisam
estar abertas, o que permite a qualquer pessoa com as chaves do app ler,
alterar ou apagar votos.

**Sugestão:** login anônimo + regras (votos: só `create`; cadastros: só
administrador), versionar `firestore.rules` e considerar App Check.
`android:usesCleartextTraffic="true"` no manifesto também pode ser removido.

### 1.18 Votos sem data nem terminal
[voto_mapper_impl.dart:24-33](lib/src/features/cadastro/mapper/voto_mapper_impl.dart#L24-L33)

O voto não grava horário nem número da urna, o que impede auditoria (votos por
urna, por período). A apuração usa `lista.last` como "dados mais recentes"
([apuracao_control.dart:102](lib/src/features/urna/controllers/apuracao_control.dart#L102)),
mas a consulta vem ordenada por nome, não por data.

**Sugestão:** gravar `criadoEm: FieldValue.serverTimestamp()` e `terminal`.

---

## 2. Layout e experiência de uso

### Tela da urna (votação)

**2.1 Tamanhos fixos em pixels**
[candidato_page.dart](lib/src/features/urna/pages/candidato_page.dart),
[number_label.dart:49-63](lib/src/widgets/number_label.dart#L49-L63)

Fontes de 40/28/25 e caixas de dígito de 80×80 não se adaptam à tela. O painel
esquerdo ocupa 3/5 da largura; com 5 dígitos, "Número:" + 5 caixas já passam
de 500 px, mais a foto (40% da largura). Cargos longos ("MELHOR JOGADOR -
TÊNIS DE MESA" em fonte 28) estouram a `Row`, porque a `Column` de textos não
está em `Expanded`.

**Sugestão:** calcular tamanhos a partir do `LayoutBuilder` (como o teclado já
faz), usar `Expanded`/`FittedBox` nos textos e testar em 800×480 e 1280×800.

**2.2 Foto do vice posicionada por `OverlayPortal`**
[candidato_page.dart:44-69](lib/src/features/urna/pages/candidato_page.dart#L44-L69)

A posição (`top: height - 40`, `left: width - width * .3 - 5`) está em
coordenadas da tela inteira e só funciona porque o painel fica no canto
superior esquerdo; com `SafeArea` ela desloca e cobre as instruções. Um
`Stack` com `Positioned` dentro do próprio painel é mais simples e previsível.

**2.3 Teclado**
[teclado_widget.dart](lib/src/widgets/teclado_widget.dart)

- Colunas calculadas pela largura e botões pela altura: em painéis estreitos
  os botões ficam desalinhados ou estouram. Usar `GridView`/`AspectRatio`.
- CORRIGE em `Flexible` e CONFIRMA em `Expanded` com `fixedSize`: tamanhos
  inconsistentes.
- Nome do colégio fixo no código ("Colégio Santa Teresinha"); mover para a
  configuração do evento.
- Cabeçalho em fonte 15, pequeno para a distância de uso.
- As 12 chamadas repetidas de `NumberButton` cabem em um laço.

**2.4 Fluxo do voto**
- CONFIRMA sem candidato válido não faz nada, sem som nem mensagem. Um aviso
  curto ("Número inválido, aperte CORRIGE") ajuda.
- As instruções "Aperte a tecla…" ocupam ~130 px o tempo todo; na urna real
  aparecem só depois de digitar o número. Em telas baixas isso estoura a coluna.
- Entre um cargo e outro não há transição nem som; o eleitor pode não perceber
  que o cargo mudou.
- Não há voto em branco (decisão documentada). Se um cargo ficar sem candidato
  o eleitor trava; considerar ao menos uma saída para o mesário.
- "Aguarde a liberação da urna" poderia mostrar terminal e zona, para o fiscal
  conferir.
- No desktop, aceitar o teclado físico (números, Enter = confirma,
  Backspace = corrige).

**2.5 Cursor piscante**
[number_label.dart:25-27](lib/src/widgets/number_label.dart#L25-L27)

Cada caixa cria um `Timer.periodic` de 200 ms mesmo sem piscar. Um único
`AnimationController` (ou só a caixa ativa animada) basta, e 500 ms é mais
confortável. `TextStyle(height: 0.1)` é um truque de alinhamento frágil.

### Home

**2.6 Estouro em celular**
[home_page.dart:52-66](lib/src/features/home/home_page.dart#L52-L66)

O título (fonte 22) e o botão "Trocar / Criar Eleição" estão em uma `Row`
sem `Expanded`; em retrato num celular isso estoura. Usar `Wrap` ou colocar o
título em `Expanded`.

**2.7 Organização**
- O drawer usa `ElevatedButton` com fonte 25; o padrão é `ListTile` com ícone
  (ou `NavigationDrawer`).
- Terminal, Zona e Tipo de Eleição aparecem no card e no drawer.
- "Iniciar Urna" é a ação principal e deveria se destacar (`FilledButton` grande).
- Os chips mostram nomes de coleções do Firestore, detalhe técnico que cabe em
  "detalhes"; no lugar, mostrar quantidade de candidatos, alunos e votos.
- A Home fica presa em retrato; em tablet e desktop o conteúdo aproveitaria
  melhor a largura.

**2.8 Diálogos de terminal e zona**
[home_page.dart:288-352](lib/src/features/home/home_page.dart#L288-L352)

- Terminal inválido: o botão Salvar não faz nada, sem mensagem.
- A zona é resolvida pelo **texto** do campo; texto livre que não bate com
  nenhuma zona grava zona 0 (Geral) em silêncio, e duas zonas com o mesmo nome
  ficam ambíguas. Guardar o `value` do `onSelected`.
- Falta botão Cancelar.

**2.9 Diálogo de evento**
[evento_eleicao_dialog.dart](lib/src/features/home/widgets/evento_eleicao_dialog.dart)

- É um formulário grande (4 seções) dentro de `AlertDialog`; uma página
  própria ou um `Stepper` fica mais confortável, principalmente em celular.
- A ordem de votação é a ordem em que as caixas são marcadas, o que não é
  óbvio; `ReorderableListView` deixa isso explícito.
- Ao criar evento novo, a coleção de alunos começa em `Alunos2026` fixo e não
  acompanha o sufixo, ao contrário das outras três.
- Não há como excluir um evento (o repositório tem `delete`, sem uso).
- `Colors.black54` e `Colors.blue` fixos; usar o `ColorScheme`.

### Cadastros e listas

**2.10 Lista de alunos**
[lista_alunos_cad_page.dart:57-80](lib/src/features/cadastro/pages/lista_alunos_cad_page.dart#L57-L80)

- Nome em fonte 25 sem `Expanded`: nomes compridos estouram a linha.
- Sem busca (o `find` já aceita prefixo de nome, a tela não usa), sem
  indicador de carregamento, sem estado vazio, sem contagem.
- Não dá para excluir aluno pela tela, só por planilha.
- Trocar o `Card` + `InkWell` + `Row` manual por `ListTile`.

**2.11 Lista de candidatos**
[lista_candidatos_cad_page.dart](lib/src/features/cadastro/pages/lista_candidatos_cad_page.dart)

- Vem ordenada por nome; agrupar por cargo e ordenar por número ajuda a conferir.
- Sem miniatura da foto (a tela de verificação já mostra).
- Os problemas aparecem em `Tooltip`, pouco descobrível em tela de toque;
  mostrar o primeiro problema como subtítulo.
- `VerificacaoCandidatos.verificar` roda duas vezes por rebuild (AppBar e corpo).
- Ícone de excluir sem `tooltip`.

**2.12 Formulários**
- Aluno: os botões Salvar e Cancelar estão colados e têm o mesmo peso visual
  ([aluno_cad_page.dart:117-125](lib/src/features/cadastro/pages/aluno_cad_page.dart#L117-L125)).
  Usar `FilledButton` + `TextButton` com espaçamento.
- Aluno: a mensagem "Nome deve ter mais de 4 caracteres" aceita exatamente 4.
- Aluno: a turma é um `DropdownMenu` de texto livre corrigido ao perder o
  foco; `DropdownButtonFormField` (como no candidato) evita o truque.
- Candidato: o seletor de cargo lista os 22 cargos de todas as modalidades;
  mostrar primeiro (ou só) os cargos do evento.
- Candidato: ao trocar para um cargo sem vice, nome e foto do vice continuam
  gravados.
- "Salvo com sucesso" em `AlertDialog` exige um toque a mais; `SnackBar` basta.
- Títulos das telas mostram o nome da coleção ("Lista de Alunos (Alunos2026)");
  mostrar o nome do evento.

### Apuração
[apuracao_page.dart](lib/src/features/urna/pages/apuracao_page.dart)

- **2.13** Enquanto carrega, a tela mostra "Nenhum voto encontrado". Falta
  estado de carregamento e de erro.
- **2.14** O total de votos está em um `Card` usado como
  `floatingActionButton` e cobre o último item da lista; mover para o topo ou
  para um `bottomNavigationBar`.
- **2.15** Faltam: barra de progresso por candidato, total por cargo,
  exportação do resultado (CSV/PDF) e comparação com o número de eleitores
  (comparecimento).
- **2.16** Cores `green.shade100`/`amber.shade100` fixas; não acompanham tema escuro.

### Geral

- **2.17** Tamanhos de fonte espalhados (`fontSize: 25`, `22`, `18`…); usar
  `Theme.of(context).textTheme` para manter consistência.
- **2.18** Sem tema escuro; várias cores fixas (`black54`, `black87`,
  `red.shade50`) quebrariam se ele for ativado.
- **2.19** Acessibilidade: adicionar `Semantics`/`tooltip` nos botões do
  teclado e nos ícones de ação.

---

## 3. Código e arquitetura

**3.1 Estado global**
[votacao_state.dart](lib/src/features/urna/state/votacao_state.dart),
[cadastro_state.dart](lib/src/features/cadastro/state/cadastro_state.dart),
[injector.dart:28-35](lib/src/injector.dart#L28-L35)

Todo o estado vive em variáveis globais (`ValueNotifier` e listas mutáveis) e
os repositórios em `late final` globais. Funciona, mas:
- `tipoEleicao` e `digitosPorCargo` são listas/mapas comuns; as telas não
  reagem a mudanças e dependem de `setState` manual.
- Os controllers (`VotacaoControl`, `AlunoControl`, `CandidatoControl`)
  estendem `ChangeNotifier` mas nunca notificam nem são descartados.
- A `CandidatoPage` lê `candidatoAtual.value` fora do `ValueListenableBuilder`
  correspondente e só atualiza porque `numCandidato.notifyListeners()` é
  chamado depois ([votacao_control.dart:35](lib/src/features/urna/controllers/votacao_control.dart#L35)).

**Sugestão:** concentrar o evento ativo em um `ValueNotifier<EventoEleicao>`
único e o estado da votação em um objeto imutável dentro do `VotacaoControl`;
injetar repositórios pelo construtor (os testes ficam mais simples).

**3.2 Dependências cruzadas entre camadas**
- Os repositórios em `features/cadastro/repositories` importam
  `features/urna/state` para saber o nome da coleção.
- `widgets/teclado_widget.dart` importa `features/home` e `features/urna`.
- `models/` importa `features/urna/enums/cargo.dart`.
- Repositórios de voto e liberação ficam dentro de `features/cadastro`.

**Sugestão:** mover `Cargo` para `models/`, os repositórios para
`src/repositories/` e passar o nome da coleção por parâmetro.

**3.3 Nomes que confundem**
- `tipoEleicao` é a lista de códigos de cargo do evento; `numSeqEleicao` é o
  cargo atual; `numAtual` é a quantidade de dígitos digitados.
- `txtId` no cadastro de candidato guarda o número, não o id.
- `zone`, `zona` e `turma` se alternam para o mesmo conceito.
- `setTerminal` e `setZone` existem como funções globais em
  [injector.dart:37-50](lib/src/injector.dart#L37-L50) e como métodos em
  [home_page.dart:337-352](lib/src/features/home/home_page.dart#L337-L352);
  dentro da Home os métodos escondem as funções. Em `setZone` do injector a
  variável se chama `terminal`.

**3.4 Preferências locais**
- Chaves em texto espalhadas (`'terminal'`, `'zone'`, `'evento_id'`…);
  centralizar em uma classe de configurações.
- O evento é salvo em 10 chaves separadas com formato próprio (`"1:2"`); um
  único JSON com `EventoEleicao.toMap()` elimina o parsing manual em
  [injector.dart:75-103](lib/src/injector.dart#L75-L103).
- `prefs.setInt` sem `await` em vários pontos.

**3.5 Valores fixos**
- `'2026'` aparece como padrão em modelo, estado, injector, diálogo e
  repositório; `findAll` sempre acrescenta os eventos "2026" e "2025"
  ([evento_eleicao_repository_impl.dart:28-40](lib/src/features/cadastro/repositories/evento_eleicao/evento_eleicao_repository_impl.dart#L28-L40)).
  Usar o ano corrente ou não criar eventos fantasmas.
- Matrícula com exatamente 4 dígitos fixa no formulário e no CSV.
- Limite de 10 cargos repetido em três lugares.

**3.6 `ApiDb.find` genérico demais**
[firestore_db.dart:46-71](lib/src/repositories/remote/firestore_db.dart#L46-L71)

O filtro vazio ordena por `nome`, e o Firestore exclui documentos sem esse
campo; a chave `nome` muda o comportamento da consulta. Não há limite nem
paginação. A apuração baixa todos os votos a cada atualização; `count()`
agregado por candidato reduz leituras. `create` grava o campo `id` dentro do
documento e `createAll` remove, comportamento inconsistente.

**3.7 Importação CSV**
[aplicar_importacao.dart](lib/src/features/cadastro/importacao/aplicar_importacao.dart)

Grava item a item com `await`; 500 alunos significam 500 idas ao servidor e,
sem rede, a tela trava no primeiro. `WriteBatch` em blocos de até 500 é mais
rápido e atômico por bloco.

**3.8 Código sem uso**
- `CandidatoControl.getByNumero`
- `EventoEleicaoRepository.findOne` e `delete`
- `VotoRepository.create`
- `eleitorAtual`
- parâmetro `id` de `CandidatoPage`
- `ativaValidacaoForm` em `AlunoCadPage` (nunca vira `true`)
- comentários de código antigo em `teclado_widget.dart:17` e `aluno_cad_page.dart:100`

**3.9 Pequenos ajustes**
- `Future.delayed(Durations.short2)` antes de carregar o registro em
  `AlunoCadPage` e `CandidatoCadPage`: não é necessário.
- `AlunoCadPage` não descarta os controllers; `buscaAluno` não confere
  `mounted` e é chamado antes de `super.initState()`.
- `showVice` (`ValueNotifier`) duplica o que o `setState` já faz e não é descartado.
- `// ignore_for_file: prefer_const_constructors` em 4 arquivos: aplicar os
  `const` e remover.
- `CandidatoPage` é um widget de painel, não uma página; renomear
  (`PainelCandidato`).
- `detectarSeparador` faz `texto.split('')` no arquivo inteiro para ler só a
  primeira linha.

---

## 4. Projeto e repositório

- **4.1** 125 arquivos de `android/app/.cxx/` (artefatos de build do CMake)
  estão versionados. Remover com `git rm -r --cached android/app/.cxx` e
  adicionar ao `.gitignore`.
- **4.2** `GoogleService-Info.plist` (iOS e macOS) está versionado, enquanto
  `firebase_options.dart` é ignorado; os dois têm as mesmas chaves. Escolher
  um critério só.
- **4.3** A pasta `web/` existe e `firebase.json` configura web, mas o código
  usa `dart:io` (`File`) em imagens e CSV e não roda no navegador. Remover a
  plataforma ou adaptar.
- **4.4** A permissão `INTERNET` só está nos manifestos de debug e profile. O
  SDK do Firebase costuma trazê-la no merge, mas vale declarar no manifesto
  principal e testar um build de release **(verificar)**.
- **4.5** `cupertino_icons` está no `pubspec.yaml` e não é usado.
- **4.6** `analysis_options.yaml` usa só o conjunto padrão; lints como
  `unawaited_futures`, `prefer_const_constructors` e
  `use_build_context_synchronously` pegariam vários itens deste documento.
- **4.7** Testes: a cobertura de lógica é boa. Faltam testes de widget para a
  tela de votação em tamanhos de tela pequenos (pegaria 2.1 e 2.6) e um teste
  do fluxo completo voto → FIM → próximo eleitor (pegaria 1.1).
