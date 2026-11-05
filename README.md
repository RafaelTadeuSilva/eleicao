# Urna Eletrônica — Colégio Santa Teresinha

Aplicativo Flutter de urna eletrônica para eleições escolares, com dados no
Firebase (Cloud Firestore). Suporta três modalidades:

- **Política**: presidente da câmara, prefeito (com vice), vereador etc.
- **CIPA**
- **Esportes**: melhor jogador por modalidade.

## Conceitos

- **Evento (eleição)**: define as coleções do Firestore usadas (alunos,
  candidatos, votos, liberação), a modalidade, os cargos (na ordem de votação),
  quantos dígitos cada cargo tem e as zonas eleitorais. Fica salvo na coleção
  `Eleicoes` e também no aparelho.
- **Zonas eleitorais**: a zona **0 – Geral** sempre existe. Um candidato da
  zona Geral aparece em todas as urnas (ex.: presidente, votado por todas as
  turmas). Um candidato de outra zona (ex.: uma turma) só aparece nas urnas
  configuradas naquela zona.
- **Urna**: cada aparelho tem um número de terminal e uma zona. A urna é
  liberada automaticamente para o próximo eleitor; um som avisa o fim de cada
  voto e o fiscal controla quem vota. Não há voto em branco nem nulo.
- **Apuração**: filtra por cargo e por zona, mostra o percentual e destaca o
  mais votado (ou o empate) de cada cargo.

## Planilhas (CSV)

Nas listas de **Candidatos** e **Alunos**, o ícone de planilha permite:

- **Baixar planilha**: gera um CSV (separado por `;`, abre direto no Excel)
  com os cadastros da eleição ativa.
- **Enviar planilha**: mostra uma prévia do que será criado, alterado e
  excluído; só grava depois da confirmação, e nada é gravado se houver erros.

Regras para candidatos:

| Coluna | Como usar |
|---|---|
| `id` | Vazio cria um candidato novo; preenchido altera aquele candidato |
| `numero`, `nome`, `cargo` | Obrigatórias. `cargo` aceita o código (ex.: `4`) ou o nome (ex.: `Vereador`) |
| `zona` | Código ou nome da zona; vazio = Geral |
| `foto`, `foto_vice` | Vazio mantém a foto atual; um link (inclusive Google Drive) troca a foto |
| `acao` | `EXCLUIR` exclui o candidato da linha (basta o `id`) |
| `cargo_descricao`, `zona_nome` | Só informativas |

Para alunos, a `matricula` é a chave: matrícula nova cria, existente altera.
Quem não estiver na planilha não é alterado nem excluído.

## Como rodar

1. Instale o Flutter (versão usada no CI: 3.47.7, canal stable).
2. Gere `lib/firebase_options.dart` com o FlutterFire CLI
   (`flutterfire configure`). Esse arquivo não é versionado.
3. `flutter pub get`
4. `flutter run`

## Testes

```sh
flutter test        # testes unitários e de widget
flutter analyze     # análise estática
```

Os testes não acessam o Firebase: usam `fake_cloud_firestore` e
`SharedPreferences` em memória. A preparação comum fica em
[test/helpers/test_setup.dart](test/helpers/test_setup.dart).

O GitHub Actions ([.github/workflows/ci.yml](.github/workflows/ci.yml)) roda
formatação, análise e testes a cada push e pull request.

## Estrutura

```
lib/src/
  models/         Aluno, Candidato, Voto, EventoEleicao, Zona, LiberacaoUrna
  repositories/   ApiDb (FirestoreDb) e armazenamento de imagens (base64)
  features/
    cadastro/     cadastro de alunos e candidatos
    home/         configuração da urna e do evento
    urna/         votação, apuração e liberação
  widgets/        teclado e componentes da urna
```
