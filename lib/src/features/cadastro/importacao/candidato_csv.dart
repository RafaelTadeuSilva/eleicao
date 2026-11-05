import 'package:eleicao/src/features/cadastro/controllers/candidato_control.dart';
import 'package:eleicao/src/features/cadastro/importacao/plano_importacao.dart';
import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/functions/csv.dart';
import 'package:eleicao/src/functions/image_helper.dart';
import 'package:eleicao/src/models/candidato.dart';
import 'package:eleicao/src/models/zona.dart';

/// Planilha de candidatos.
///
/// Regras da importação:
/// - `id` vazio: cria um candidato novo (o id é gerado pelo Firebase).
/// - `id` preenchido: atualiza o candidato com esse id.
/// - `acao` = EXCLUIR (com `id`): exclui o candidato.
/// - Candidatos que não estão na planilha não são alterados nem excluídos.
/// - `cargo` aceita o código ou a descrição; `zona` aceita o código ou o nome.
/// - `foto`/`foto_vice` vazias mantêm a foto atual; um link (http/https,
///   inclusive Google Drive) troca a foto. Fotos enviadas pelo app aparecem
///   como [marcadorFotoNoApp] na exportação e também são mantidas.
class CandidatoCsv {
  static const colunas = [
    'id',
    'numero',
    'nome',
    'cargo',
    'cargo_descricao',
    'zona',
    'zona_nome',
    'nome_vice',
    'foto',
    'foto_vice',
    'acao',
  ];

  /// Fotos guardadas no próprio banco (base64) são grandes demais para uma
  /// célula de planilha; exporta-se este texto no lugar.
  static const marcadorFotoNoApp = '(foto no app)';

  static String exportar(
    List<Candidato> candidatos, {
    required List<int> cargos,
    required List<Zona> zonas,
  }) {
    String nomeZona(int codigo) =>
        zonas.where((z) => z.codigo == codigo).firstOrNull?.nome ?? '';
    String foto(String? valor) {
      final v = (valor ?? '').trim();
      if (v.isEmpty || v.startsWith('http')) return v;
      return marcadorFotoNoApp;
    }

    int ordem(Cargo c) {
      final i = cargos.indexOf(c.codigo);
      return i == -1 ? cargos.length + c.codigo : i;
    }

    final ordenados = [...candidatos]..sort((a, b) {
        final porCargo = ordem(a.cargo).compareTo(ordem(b.cargo));
        if (porCargo != 0) return porCargo;
        final porZona = a.zone.compareTo(b.zone);
        return porZona != 0 ? porZona : a.numero.compareTo(b.numero);
      });

    return gerarCsv([
      colunas,
      for (final c in ordenados)
        [
          c.id,
          c.numero,
          c.nome,
          c.cargo.codigo,
          c.cargo.descricao,
          c.zone,
          nomeZona(c.zone),
          c.nomeVice ?? '',
          foto(c.urlImage),
          foto(c.urlImageVice),
          '',
        ],
    ]);
  }

  /// Analisa a planilha [texto] contra os candidatos [existentes] da eleição
  /// ativa, sem gravar nada.
  static PlanoImportacao<Candidato> planejar(
    String texto, {
    required List<Candidato> existentes,
    required List<int> cargos,
    required int Function(int codigoCargo) digitosDoCargo,
    required List<Zona> zonas,
  }) {
    final tabela = TabelaCsv.ler(texto);
    final erros = <MensagemImportacao>[];
    final avisos = <MensagemImportacao>[];
    final itens = <ItemImportacao<Candidato>>[];

    if (tabela.colunas.isEmpty) {
      return const PlanoImportacao(
          itens: [], erros: [MensagemImportacao(0, 'Arquivo vazio')]);
    }
    // Exclusões só precisam de id; estas colunas são exigidas apenas se
    // houver linhas para criar/alterar.
    final faltando =
        ['numero', 'nome', 'cargo'].where((c) => !tabela.temColuna(c)).toList();
    var avisouColunas = false;

    final porId = {for (final c in existentes) c.id: c};
    final idsNoArquivo = <String, int>{};

    for (final linha in tabela.linhas) {
      String v(String coluna) => tabela.valor(linha, coluna);
      void erro(String texto) =>
          erros.add(MensagemImportacao(linha.numero, texto));

      final id = v('id');
      final atual = id.isEmpty ? null : porId[id];
      if (id.isNotEmpty) {
        final repetida = idsNoArquivo[id];
        if (repetida != null) {
          erro('id "$id" repetido (também na linha $repetida)');
          continue;
        }
        idsNoArquivo[id] = linha.numero;
        if (atual == null) {
          erro('id "$id" não existe nesta eleição. Para criar um candidato '
              'novo, deixe a coluna id vazia');
          continue;
        }
      }

      if (palavrasExcluir.contains(normalizarCabecalho(v('acao')))) {
        if (atual == null) {
          erro('para excluir, informe o id do candidato');
        } else {
          itens.add(ItemImportacao(
              linha: linha.numero,
              acao: AcaoImportacao.excluir,
              registro: atual,
              descricao: _descricao(atual)));
        }
        continue;
      }

      if (faltando.isNotEmpty) {
        if (!avisouColunas) {
          avisouColunas = true;
          erros.add(colunasAusentes(faltando));
        }
        continue;
      }

      final errosAntes = erros.length;

      final numero = int.tryParse(v('numero'));
      if (numero == null) erro('número "${v('numero')}" inválido');

      final nome = v('nome');
      if (nome.isEmpty) erro('nome não informado');

      final cargo =
          _cargo(v('cargo').isNotEmpty ? v('cargo') : v('cargo_descricao'));
      if (cargo == null) erro('cargo "${v('cargo')}" não reconhecido');

      final zona = zonaDaPlanilha(v('zona'), zonas);
      if (zona == null) erro('zona "${v('zona')}" não existe nesta eleição');

      final foto = _foto(v('foto'), atual?.urlImage, erro);
      final fotoVice = _foto(v('foto_vice'), atual?.urlImageVice, erro);

      if (erros.length > errosAntes) continue;

      final digitos = digitosDoCargo(cargo!.codigo);
      if (numero.toString().length != digitos) {
        erro(
            'número $numero deve ter $digitos dígitos para ${cargo.descricao}');
        continue;
      }
      if (!cargos.contains(cargo.codigo)) {
        avisos.add(MensagemImportacao(linha.numero,
            '${cargo.descricao} não faz parte desta eleição; o candidato não aparecerá na votação'));
      }

      final nomeVice = v('nome_vice');
      final novo = Candidato(
        id: atual?.id ?? '',
        numero: numero!,
        nome: nome,
        nomeVice: nomeVice.isEmpty ? null : nomeVice,
        urlImage: foto ?? '',
        urlImageVice: fotoVice,
        cargo: cargo,
        zone: zona!.codigo,
      );

      if (atual == null) {
        itens.add(ItemImportacao(
            linha: linha.numero,
            acao: AcaoImportacao.criar,
            registro: novo,
            descricao: _descricao(novo)));
      } else {
        final alteracoes = _diferencas(atual, novo, zonas);
        itens.add(ItemImportacao(
            linha: linha.numero,
            acao: alteracoes.isEmpty
                ? AcaoImportacao.semAlteracao
                : AcaoImportacao.atualizar,
            registro: novo,
            descricao: _descricao(novo),
            alteracoes: alteracoes));
      }
    }

    erros.addAll(_numerosDuplicados(itens, existentes));
    return PlanoImportacao(itens: itens, erros: erros, avisos: avisos);
  }

  /// Confere números repetidos no resultado final (banco + planilha).
  static List<MensagemImportacao> _numerosDuplicados(
      List<ItemImportacao<Candidato>> itens, List<Candidato> existentes) {
    final tocados = {
      for (final i in itens)
        if (i.acao != AcaoImportacao.criar) i.registro.id
    };
    final gravados = itens
        .where((i) =>
            i.acao == AcaoImportacao.criar ||
            i.acao == AcaoImportacao.atualizar ||
            i.acao == AcaoImportacao.semAlteracao)
        .toList();
    final finais = [
      ...existentes.where((c) => !tocados.contains(c.id)),
      ...gravados.map((i) => i.registro),
    ];

    final erros = <MensagemImportacao>[];
    for (final item in gravados) {
      if (item.acao == AcaoImportacao.semAlteracao) continue;
      final c = item.registro;
      final outro = CandidatoControl.numeroDuplicado(
        finais.where((e) => !identical(e, c)),
        numero: c.numero,
        cargo: c.cargo,
        zone: c.zone,
      );
      if (outro != null) {
        erros.add(MensagemImportacao(item.linha,
            'número ${c.numero} de ${c.cargo.descricao} já pertence a "${outro.nome}"'));
      }
    }
    return erros;
  }

  static Cargo? _cargo(String valor) {
    if (valor.isEmpty) return null;
    final codigo = int.tryParse(valor);
    if (codigo != null) {
      return Cargo.values.where((c) => c.codigo == codigo).firstOrNull;
    }
    final normalizado = normalizarCabecalho(valor);
    return Cargo.values
        .where((c) => normalizarCabecalho(c.descricao) == normalizado)
        .firstOrNull;
  }

  /// Vazio ou marcador: mantém [atual]. Link: troca. Outro texto: erro.
  static String? _foto(
      String valor, String? atual, void Function(String) erro) {
    if (valor.isEmpty || valor == marcadorFotoNoApp) return atual;
    if (valor.startsWith('http://') || valor.startsWith('https://')) {
      return normalizeImageUrl(valor);
    }
    if (valor.startsWith('data:image')) return valor;
    erro('foto "$valor" inválida: use um link http(s) ou deixe vazio');
    return atual;
  }

  static String _descricao(Candidato c) =>
      '${c.numero} - ${c.nome} (${c.cargo.descricao})';

  static List<String> _diferencas(Candidato a, Candidato b, List<Zona> zonas) {
    String zona(int c) =>
        zonas.where((z) => z.codigo == c).firstOrNull?.nome ?? 'Zona $c';
    return [
      if (a.numero != b.numero) 'número: ${a.numero} → ${b.numero}',
      if (a.nome != b.nome) 'nome: ${a.nome} → ${b.nome}',
      if (a.cargo != b.cargo)
        'cargo: ${a.cargo.descricao} → ${b.cargo.descricao}',
      if (a.zone != b.zone) 'zona: ${zona(a.zone)} → ${zona(b.zone)}',
      if ((a.nomeVice ?? '') != (b.nomeVice ?? ''))
        'vice: ${a.nomeVice ?? ''} → ${b.nomeVice ?? ''}',
      if (a.urlImage != b.urlImage) 'foto alterada',
      if ((a.urlImageVice ?? '') != (b.urlImageVice ?? ''))
        'foto do vice alterada',
    ];
  }
}
