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
      currentUserId = user.id;
      _loadPersons();
    } else {
      Navigator.pushReplacementNamed(context, '/connexion');
    }
  }

  Future<void> _loadPersons() async {
    if (currentUserId == null) return;
    setState(() => isLoading = true);

    try {
      persons = searchQuery.isEmpty
          ? await ApiService.getPersons(currentUserId!)
          : await ApiService.searchPersons(currentUserId!, searchQuery);
    } catch (e) {
      _showErrorDialog(e.toString());
    }

    setState(() => isLoading = false);
  }

  void _onSearchChanged(String value) {
    searchQuery = value;
    _loadPersons();
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Erreur'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          )
        ],
      ),
    );
  }

  void _navigateToAddPerson() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddPersonScreen()),
    );
    if (result == true) _loadPersons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des contacts'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await AuthService.logout();
              Navigator.pushReplacementNamed(context, '/connexion');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: persons.length,
              itemBuilder: (context, index) {
                final person = persons[index];

                return Dismissible(
                  key: Key(person.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('Supprimer'),
                        content: Text(
                            'Supprimer ${person.prenom} ${person.nom} ?'),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, false),
                            child: Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, true),
                            child: Text(
                              'Supprimer',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (_) async {
                    final deleted = persons[index];
                    setState(() => persons.removeAt(index));

                    try {
                      await ApiService.deletePerson(
                          currentUserId!, deleted.id!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Contact supprimé')),
                      );
                    } catch (e) {
                      _showErrorDialog('Erreur suppression');
                      _loadPersons();
                    }
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(person.prenom[0].toUpperCase()),
                      ),
                      title:
                      Text('${person.prenom} ${person.nom}'),
                      subtitle: Text(person.telephone),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {
                          final res =
                          await Navigator.pushNamed(context,
                              '/modifier',
                              arguments: person.id);
                          if (res == true) _loadPersons();
                        },
                      ),
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
      ),
    );
  }
}
