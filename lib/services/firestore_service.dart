import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/paciente.dart';
import '../models/registro_insulina.dart';
import '../models/prescricao.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Referência à coleção de pacientes
  CollectionReference<Map<String, dynamic>> get _pacientes =>
      _firestore.collection('pacientes');

  // Adicionar um novo paciente
  Future<String> addPaciente(Paciente paciente) async {
    try {
      final docRef = await _pacientes.add(paciente.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao adicionar paciente: $e');
    }
  }

  // Obter todos os pacientes do usuário atual
  Stream<List<Paciente>> getPacientes() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado');

    return _pacientes.where('userId', isEqualTo: userId).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return Paciente.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // Atualizar um paciente existente
  Future<void> updatePaciente(String id, Map<String, dynamic> data) async {
    try {
      await _pacientes.doc(id).update(data);
    } catch (e) {
      throw Exception('Erro ao atualizar paciente: $e');
    }
  }

  // Excluir um paciente
  Future<void> deletePaciente(String id) async {
    try {
      await _pacientes.doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao excluir paciente: $e');
    }
  }

  // Buscar um paciente específico
  Future<Paciente?> getPaciente(String id) async {
    try {
      final doc = await _pacientes.doc(id).get();
      if (!doc.exists) return null;
      return Paciente.fromMap(doc.id, doc.data()!);
    } catch (e) {
      throw Exception('Erro ao buscar paciente: $e');
    }
  }

  // Referência à coleção de registros de insulina
  CollectionReference<Map<String, dynamic>> get _registrosInsulina =>
      _firestore.collection('registros_insulina');

  // Adicionar um novo registro de insulina
  Future<String> addRegistroInsulina(RegistroInsulina registro) async {
    try {
      final docRef = await _registrosInsulina.add(registro.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao adicionar registro: $e');
    }
  }

  // Obter todos os registros de insulina do usuário atual
  Stream<List<RegistroInsulina>> getRegistrosInsulina() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado');

    // Avoid requiring a composite index by ordering on the client side.
    // We still filter by userId in the query to limit documents read.
    return _registrosInsulina
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => RegistroInsulina.fromMap(doc.id, doc.data()))
              .toList();
          // sort by dataRegistro descending (newest first)
          list.sort((a, b) => b.dataRegistro.compareTo(a.dataRegistro));
          return list;
        });
  }

  // Obter registros de insulina de um paciente específico
  Stream<List<RegistroInsulina>> getRegistrosPorPaciente(String pacienteId) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado');

    // Avoid composite index requirement by sorting in client after fetching
    return _registrosInsulina
        .where('userId', isEqualTo: userId)
        .where('pacienteId', isEqualTo: pacienteId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => RegistroInsulina.fromMap(doc.id, doc.data()))
              .toList();
          list.sort((a, b) => b.dataRegistro.compareTo(a.dataRegistro));
          return list;
        });
  }

  // Excluir um registro de insulina
  Future<void> deleteRegistroInsulina(String id) async {
    try {
      await _registrosInsulina.doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao excluir registro: $e');
    }
  }

  // Referência à coleção de prescrições
  CollectionReference<Map<String, dynamic>> get _prescricoes =>
      _firestore.collection('prescricoes');

  // Adicionar uma nova prescrição
  Future<String> addPrescricao(Prescricao prescricao) async {
    try {
      final docRef = await _prescricoes.add(prescricao.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao adicionar prescrição: $e');
    }
  }

  // Obter todas as prescrições do usuário atual
  Stream<List<Prescricao>> getPrescricoes() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado');

    return _prescricoes
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => Prescricao.fromMap(doc.id, doc.data()))
              .toList();
          // sort by dataPrescricao descending (newest first)
          list.sort((a, b) => b.dataPrescricao.compareTo(a.dataPrescricao));
          return list;
        });
  }

  // Obter prescrições de um paciente específico
  Stream<List<Prescricao>> getPrescricoesPorPaciente(String pacienteId) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado');

    return _prescricoes
        .where('userId', isEqualTo: userId)
        .where('pacienteId', isEqualTo: pacienteId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => Prescricao.fromMap(doc.id, doc.data()))
              .toList();
          list.sort((a, b) => b.dataPrescricao.compareTo(a.dataPrescricao));
          return list;
        });
  }

  // Atualizar uma prescrição existente
  Future<void> updatePrescricao(String id, Map<String, dynamic> data) async {
    try {
      await _prescricoes.doc(id).update(data);
    } catch (e) {
      throw Exception('Erro ao atualizar prescrição: $e');
    }
  }

  // Excluir uma prescrição
  Future<void> deletePrescricao(String id) async {
    try {
      await _prescricoes.doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao excluir prescrição: $e');
    }
  }

  // Buscar uma prescrição específica
  Future<Prescricao?> getPrescricao(String id) async {
    try {
      final doc = await _prescricoes.doc(id).get();
      if (!doc.exists) return null;
      return Prescricao.fromMap(doc.id, doc.data()!);
    } catch (e) {
      throw Exception('Erro ao buscar prescrição: $e');
    }
  }
}
