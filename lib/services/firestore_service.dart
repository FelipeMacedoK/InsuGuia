import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/paciente.dart';
import '../models/registro_insulina.dart';

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

    return _pacientes
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
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

    return _registrosInsulina
        .where('userId', isEqualTo: userId)
        .orderBy('dataRegistro', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return RegistroInsulina.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // Obter registros de insulina de um paciente específico
  Stream<List<RegistroInsulina>> getRegistrosPorPaciente(String pacienteId) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado');

    return _registrosInsulina
        .where('userId', isEqualTo: userId)
        .where('pacienteId', isEqualTo: pacienteId)
        .orderBy('dataRegistro', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return RegistroInsulina.fromMap(doc.id, doc.data());
      }).toList();
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
}