import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teste/data/models/hero_character_model.dart';
import 'package:teste/providers/game_state.dart';

class CreateCharacterScreen extends StatefulWidget {
  const CreateCharacterScreen({super.key});

  @override
  State<CreateCharacterScreen> createState() => _CreateCharacterScreenState();
}

class _CreateCharacterScreenState extends State<CreateCharacterScreen> {
  final _nameController = TextEditingController();
  String _selectedClass = 'Guerreiro';
  final List<String> _classes = [
    'Guerreiro',
    'Mago',
    'Ladino',
    'Paladino',
    'Caçador'
  ];

  final List<String> _avatarImages = [
    'images/archer.png',
    'images/ladino.png',
    'images/curandeira.png',
    'images/druida.png',
    'images/feiticeira.png',
    'images/mage.png',
    'images/monge.png',
    'images/templario.png',
    'images/xama.png',
  ];
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    _selectedImagePath = _avatarImages.first;
  }

  void _createCharacter() {
    if (_nameController.text.trim().isEmpty || _selectedImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, digite um nome para o seu herói!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newHero = HeroCharacter(
      name: _nameController.text.trim(),
      heroClass: _selectedClass,
      texturePath: _selectedImagePath!,
    );

    Provider.of<GameState>(context, listen: false).selectHero(newHero);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Novo Herói')),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/background_LockerRoom.png"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              color: Colors.black.withOpacity(0.7),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Nome do Herói',
                        labelStyle: const TextStyle(color: Colors.white70),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.deepPurple.shade300),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Escolha sua Classe:',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      value: _selectedClass,
                      isExpanded: true,
                      dropdownColor: Colors.grey[800],
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedClass = newValue;
                          });
                        }
                      },
                      items: _classes
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                            value: value, child: Text(value));
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    _buildAvatarSelector(),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Criar Personagem'),
                      onPressed: _createCharacter,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Escolha seu Avatar:',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _avatarImages.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final imagePath = _avatarImages[index];
              final isSelected = imagePath == _selectedImagePath;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedImagePath = imagePath;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                          isSelected ? Colors.deepPurple : Colors.transparent,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.asset(
                      imagePath,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
