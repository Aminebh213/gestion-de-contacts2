import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/person.dart';

class ModifierContactPage extends StatefulWidget {
  @override
  State<ModifierContactPage> createState() => _ModifierContactPageState();
}

class _ModifierContactPageState extends State<ModifierContactPage> {
  final nomCtrl = TextEditingController();
  final prenomCtrl = TextEditingController();
  final numeroCtrl = TextEditingController();
  late int contactId;
  int? currentUserId;
  bool isLoading = true;
  bool isSaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isLoading) {
      contactId = ModalRoute.of(context)!.settings.arguments as int;
      _initializeAndLoad();
    }
  }

  Future<void> _initializeAndLoad() async {
    final user = await AuthService.getCurrentUser();
    if (user != null) {
      setState(() {
        currentUserId = user.id;
      });
      _loadContact();
    }
  }

  Future<void> _loadContact() async {
    if (currentUserId == null) return;
    
    try {
      Person person = await ApiService.getPerson(currentUserId!, contactId);
      nomCtrl.text = person.nom;
      prenomCtrl.text = person.prenom;
      numeroCtrl.text = person.telephone;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    nomCtrl.dispose();
    prenomCtrl.dispose();
    numeroCtrl.dispose();
    super.dispose();
  }

  Future<void> updateContact() async {
    if (nomCtrl.text.isEmpty ||
        prenomCtrl.text.isEmpty ||
        numeroCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Tous les champs sont obligatoires"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur: utilisateur non connecté"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';
      
      await ApiService.updatePerson(
        currentUserId!,
        contactId,
        Person(
          id: contactId,
          nom: nomCtrl.text.trim(),
          prenom: prenomCtrl.text.trim(),
          telephone: numeroCtrl.text.trim(),
          userId: currentUserId!,
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Contact modifié avec succès"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  InputDecoration inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.indigo.shade700),
      filled: true,
      fillColor: Colors.indigo.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.indigo, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade100,
      appBar: AppBar(
        title: Text("Modifier un Contact"),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade600,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  TextField(
                    controller: nomCtrl,
                    decoration: inputStyle("Nom"),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: prenomCtrl,
                    decoration: inputStyle("Prénom"),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: numeroCtrl,
                    decoration: inputStyle("Numéro"),
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 25),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade700,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 3,
                    ),
                    child: isSaving
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text("Mettre à jour",
                            style: TextStyle(fontSize: 16)),
                    onPressed: isSaving ? null : updateContact,
                  ),
                ],
              ),
            ),
    );
  }
}