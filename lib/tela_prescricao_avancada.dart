import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/paciente.dart';
import 'models/prescricao.dart';
import 'services/firestore_service.dart';
import 'services/insulina_calculo_service.dart';

class TelaPrescricaoAvancada extends StatefulWidget {
  const TelaPrescricaoAvancada({super.key});

  @override
  State<TelaPrescricaoAvancada> createState() => _TelaPrescricaoAvancadaState();
}

class _TelaPrescricaoAvancadaState extends State<TelaPrescricaoAvancada> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  Paciente? _pacienteSelecionado;
  bool _isLoading = false;

  // Campos de avaliação clínica
  late TextEditingController _glicemiaAdmissaoController;
  late TextEditingController _hemoglobinaGlicadaController;
  late TextEditingController _creatininaController;
  bool _usaInsulinaPrevia = false;
  bool _usaCorticoide = false;
  TipoDieta _tipoDieta = TipoDieta.oral;
  SensibilidadeInsulina? _sensibilidadeCalculada;
  EsquemaInsulina? _esquemaCalculado;
  DosesInsulina? _dosesCalculadas;

  @override
  void initState() {
    super.initState();
    _glicemiaAdmissaoController = TextEditingController();
    _hemoglobinaGlicadaController = TextEditingController();
    _creatininaController = TextEditingController();
  }

  @override
  void dispose() {
    _glicemiaAdmissaoController.dispose();
    _hemoglobinaGlicadaController.dispose();
    _creatininaController.dispose();
    super.dispose();
  }

  void _calcularRecomendacoes() {
    if (_pacienteSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um paciente')),
      );
      return;
    }

    // Parse glicemia
    final glicemia = double.tryParse(_glicemiaAdmissaoController.text);
    if (glicemia == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Glicemia inválida')),
      );
      return;
    }

    // Parse hemoglobina glicada
    final hemoglobinaGlicada = _hemoglobinaGlicadaController.text.isEmpty
        ? null
        : double.tryParse(_hemoglobinaGlicadaController.text);

    // Determinar sensibilidade à insulina
    final sensibilidade = InsulinaCalculoService.determinarSensibilidade(
      hemoglobinaGlicada: hemoglobinaGlicada,
      imc: _pacienteSelecionado!.imc,
      usaCorticoide: _usaCorticoide,
    );

    // Determinar esquema de insulina
    final esquema = InsulinaCalculoService.determinarEsquema(
      glicemiaAdmissao: glicemia,
      glicemiasRegistradas: [glicemia], // Inicialmente apenas a de admissão
      usaInsulinaPrevia: _usaInsulinaPrevia,
      tipoDieta: _tipoDieta,
    );

    // Calcular doses
    final doses = InsulinaCalculoService.calcularDoses(
      peso: _pacienteSelecionado!.peso,
      sensibilidade: sensibilidade,
      esquema: esquema,
    );

    setState(() {
      _sensibilidadeCalculada = sensibilidade;
      _esquemaCalculado = esquema;
      _dosesCalculadas = doses;
    });

    // Mostrar resultado
    _mostrarResultado(sensibilidade, esquema, doses);
  }

  void _mostrarResultado(
    SensibilidadeInsulina sensibilidade,
    EsquemaInsulina esquema,
    DosesInsulina doses,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Recomendações de Insulina'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '⚠️ AVISO ACADÊMICO',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Este é um aplicativo acadêmico baseado nas diretrizes da SBD. '
                  'As sugestões são meramente orientadoras e devem ser individualizadas pelo médico.',
                  style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                _buildRecomendacaoCard('Sensibilidade à Insulina', _formatarSensibilidade(sensibilidade)),
                _buildRecomendacaoCard('Esquema Recomendado', _formatarEsquema(esquema)),
                _buildRecomendacaoCard('TDD (Dose Total Diária)', '${doses.tdd.toStringAsFixed(0)} UI'),
                _buildRecomendacaoCard('Dose Basal', '${doses.basalDiaria.toStringAsFixed(0)} UI/dia'),
                _buildRecomendacaoCard('Dose de Bôlus', '${doses.bolusDiario.toStringAsFixed(0)} UI/dia (50% TDD)'),
                _buildRecomendacaoCard('Fator de Correção', '${doses.corracao.toStringAsFixed(0)} UI por intervalo'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _salvarPrescricao();
              },
              child: const Text('Salvar Prescrição'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecomendacaoCard(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            titulo,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          ),
          Text(
            valor,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatarSensibilidade(SensibilidadeInsulina sens) {
    switch (sens) {
      case SensibilidadeInsulina.sensivel:
        return 'Sensível';
      case SensibilidadeInsulina.usual:
        return 'Usual';
      case SensibilidadeInsulina.resistente:
        return 'Resistente';
    }
  }

  String _formatarEsquema(EsquemaInsulina esq) {
    switch (esq) {
      case EsquemaInsulina.somenteCorracao:
        return 'Somente Correção';
      case EsquemaInsulina.basalCorracao:
        return 'Basal + Correção';
      case EsquemaInsulina.basalBolus:
        return 'Basal + Bôlus';
    }
  }

  Future<void> _salvarPrescricao() async {
    if (_pacienteSelecionado == null || _dosesCalculadas == null) return;

    setState(() => _isLoading = true);

    try {
      final prescricao = Prescricao(
        id: '',
        pacienteId: _pacienteSelecionado!.id,
        pacienteNome: _pacienteSelecionado!.nome,
        dosePrescrita: _dosesCalculadas!.tdd,
        tipoInsulina: 'NPH',
        frequencia: _esquemaCalculado == EsquemaInsulina.basalBolus ? 'Basal + Bôlus' : 'Basal + Correção',
        indicacoes: '''Esquema: ${_formatarEsquema(_esquemaCalculado!)}
TDD: ${_dosesCalculadas!.tdd.toStringAsFixed(0)} UI
Basal: ${_dosesCalculadas!.basalDiaria.toStringAsFixed(0)} UI
Fator de Correção: ${_dosesCalculadas!.corracao.toStringAsFixed(0)} UI
Sensibilidade: ${_formatarSensibilidade(_sensibilidadeCalculada!)}''',
        dataPrescricao: DateTime.now(),
        dataVencimento: DateTime.now().add(const Duration(days: 7)),
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
      );

      await _firestoreService.addPrescricao(prescricao);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prescrição salva com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      // Limpar formulário
      setState(() {
        _pacienteSelecionado = null;
        _glicemiaAdmissaoController.clear();
        _hemoglobinaGlicadaController.clear();
        _creatininaController.clear();
        _usaInsulinaPrevia = false;
        _usaCorticoide = false;
        _tipoDieta = TipoDieta.oral;
        _sensibilidadeCalculada = null;
        _esquemaCalculado = null;
        _dosesCalculadas = null;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescrição de Insulina Avançada'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Aviso acadêmico
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  border: Border.all(color: Colors.amber),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Aplicativo acadêmico baseado em diretrizes SBD. '
                        'Sugestões são meramente orientadoras.',
                        style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Seleção de paciente
              const Text(
                'Dados do Paciente',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              StreamBuilder<List<Paciente>>(
                stream: _firestoreService.getPacientes(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Erro: ${snapshot.error}');
                  }

                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final pacientes = snapshot.data!;
                  if (pacientes.isEmpty) {
                    return const Text('Nenhum paciente cadastrado');
                  }

                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Selecione o Paciente',
                      border: OutlineInputBorder(),
                    ),
                    items: pacientes.map((p) {
                      return DropdownMenuItem(value: p.id, child: Text(p.nome));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _pacienteSelecionado =
                              pacientes.firstWhere((p) => p.id == value);
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Selecione um paciente';
                      }
                      return null;
                    },
                  );
                },
              ),
              if (_pacienteSelecionado != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${_pacienteSelecionado!.nome} - ${_pacienteSelecionado!.idade} anos'),
                      Text('Peso: ${_pacienteSelecionado!.peso} kg | Altura: ${_pacienteSelecionado!.altura} m'),
                      Text('IMC: ${_pacienteSelecionado!.imc.toStringAsFixed(1)} kg/m²'),
                      if (_pacienteSelecionado!.creatinina != null)
                        Text('Creatinina: ${_pacienteSelecionado!.creatinina} mg/dL | TFG: ${_pacienteSelecionado!.tfgCkdEpi.toStringAsFixed(0)} mL/min'),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Avaliação clínica
              const Text(
                'Avaliação Clínica',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Glicemia na admissão
              TextFormField(
                controller: _glicemiaAdmissaoController,
                decoration: const InputDecoration(
                  labelText: 'Glicemia na Admissão (mg/dL)',
                  border: OutlineInputBorder(),
                  suffixText: 'mg/dL',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a glicemia';
                  }
                  final glicemia = double.tryParse(value);
                  if (glicemia == null || glicemia <= 0) {
                    return 'Glicemia inválida';
                  }
                  if (glicemia <= 140) {
                    return 'Glicemia não indica hiperglicemia hospitalar (>140)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Hemoglobina glicada
              TextFormField(
                controller: _hemoglobinaGlicadaController,
                decoration: const InputDecoration(
                  labelText: 'Hemoglobina Glicada (%) - Opcional',
                  border: OutlineInputBorder(),
                  suffixText: '%',
                  hintText: 'Ex: 8.5',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),

              // Creatinina
              TextFormField(
                controller: _creatininaController,
                decoration: const InputDecoration(
                  labelText: 'Creatinina (mg/dL) - Opcional',
                  border: OutlineInputBorder(),
                  suffixText: 'mg/dL',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),

              // Usa insulina prévia
              CheckboxListTile(
                title: const Text('Já usa insulina'),
                value: _usaInsulinaPrevia,
                onChanged: (value) {
                  setState(() => _usaInsulinaPrevia = value ?? false);
                },
              ),

              // Usa corticoide
              CheckboxListTile(
                title: const Text('Em uso de corticoide'),
                value: _usaCorticoide,
                onChanged: (value) {
                  setState(() => _usaCorticoide = value ?? false);
                },
              ),
              const SizedBox(height: 12),

              // Tipo de dieta
              DropdownButtonFormField<TipoDieta>(
                decoration: const InputDecoration(
                  labelText: 'Tipo de Dieta',
                  border: OutlineInputBorder(),
                ),
                initialValue: _tipoDieta,
                items: TipoDieta.values.map((dieta) {
                  String label = '';
                  switch (dieta) {
                    case TipoDieta.oral:
                      label = 'Oral';
                      break;
                    case TipoDieta.npo:
                      label = 'NPO (Nada por via oral)';
                      break;
                    case TipoDieta.enteral:
                      label = 'Dieta Enteral';
                      break;
                    case TipoDieta.parenteral:
                      label = 'Dieta Parenteral';
                      break;
                  }
                  return DropdownMenuItem(value: dieta, child: Text(label));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _tipoDieta = value);
                  }
                },
              ),
              const SizedBox(height: 24),

              // Botão calcular
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.calculate),
                  label: const Text('Calcular Recomendações'),
                  onPressed: _isLoading ? null : _calcularRecomendacoes,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
