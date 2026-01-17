import 'package:flutter/material.dart';
import '../models/person.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'add_person.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Person> persons = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  int? currentUserId;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final user = await AuthService.getCurrentUser();
    if (user != null) {
      setState(() {
        currentUserId = user.id;
      });
      _loadPersons();
    } else {
      // No user logged in, redirect to login
      Navigator.pushReplacementNamed(context, '/connexion');
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPersons() async {
    if (currentUserId == null) return;
    
    setState(() {
      isLoading = true;
    });
    
    try {
      List<Person> loadedPersons;
      if (searchQuery.isEmpty) {
        loadedPersons = await ApiService.getPersons(currentUserId!);
      } else {
        loadedPersons = await ApiService.searchPersons(currentUserId!, searchQuery);
      }
      
      setState(() {
        persons = loadedPersons;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog(e.toString());
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchQuery = value;
    });
    _loadPersons();
  }

  Future<void> _deletePerson(int id) async {
    if (currentUserId == null) return;
    
    try {
      await ApiService.deletePerson(currentUserId!, id);
      _loadPersons();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contact supprimé avec succès')),
      );
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }



  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Erreur'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }



  void _navigateToAddPerson() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddPersonScreen()),
    );
    if (result == true) {
      _loadPersons();
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Contacts'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Déconnexion'),
                  content: Text('Voulez-vous vraiment vous déconnecter?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: Text('Annuler'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: Text('Déconnexion', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              
              if (confirmed == true) {
                await AuthService.logout();
                Navigator.pushReplacementNamed(context, '/connexion');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un contact...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : persons.isEmpty
                    ? Center(
                        child: Text(
                          searchQuery.isEmpty
                              ? 'Aucun contact trouvé'
                              : 'Aucun résultat pour "$searchQuery"',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                  itemCount: persons.length,
                  itemBuilder: (ctx, index) {
                    final person = persons[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text('${person.prenom} ${person.nom}'),
                        subtitle: Text(person.telephone),
                        leading: CircleAvatar(
                          child: Text(
                            person.prenom.isNotEmpty
                                ? person.prenom[0].toUpperCase()
                                : '?',
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                final result = await Navigator.pushNamed(
                                  context,
                                  '/modifier',
                                  arguments: person.id,
                                );
                                if (result == true) {
                                  _loadPersons();
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Confirmer la suppression'),
                                      content: Text(
                                          'Êtes-vous sûr de vouloir supprimer ${person.prenom} ${person.nom} ?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: Text('Annuler'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: Text('Supprimer',
                                              style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                if (confirm == true) {
                                  _deletePerson(person.id!);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddPerson,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
