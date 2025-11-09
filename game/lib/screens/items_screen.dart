import 'package:flutter/material.dart';
import 'package:teste/models/item_model.dart';
import 'package:teste/providers/game_state.dart';
import 'package:provider/provider.dart';

class ItemsScreen extends StatelessWidget {
  const ItemsScreen({super.key});

  final List<GameItem> allGameItems = const [
    GameItem(
        name: 'Poção de Cura',
        description: 'Restaura 50 HP',
        type: ItemType.potion,
        imagePath: 'images/health_potion.png',
        healAmount: 50,
        price: 10),
    GameItem(
        name: 'Espada Curta',
        description: '+5 de Ataque',
        type: ItemType.sword,
        imagePath: 'images/small_sword.png',
        attackBonus: 5,
        price: 100),
    GameItem(
        name: 'Armadura leve',
        description: '+5 de Defesa',
        type: ItemType.armor,
        imagePath: 'images/armor_leather.png',
        defenseBonus: 5,
        price: 80),
    GameItem(
        name: 'Cajado Místico',
        description: '+10 Ataque Mágico',
        type: ItemType.staff,
        imagePath: 'images/magic_staff.png',
        price: 150),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Inventário e Loja'),
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Chip(
                  avatar: Icon(Icons.monetization_on, color: Colors.amber),
                  label: Text('${gameState.playerGold} Ouro'),
                  backgroundColor: Colors.grey[800],
                  labelStyle: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage("images/background_inventory.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: [
                _buildInventorySection(context, gameState),
                const Divider(color: Colors.white54),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text("Itens à Venda",
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: Colors.white)),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: allGameItems.length,
                    itemBuilder: (context, index) {
                      final item = allGameItems[index];
                      return _buildShopItemCard(context, gameState, item);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInventorySection(BuildContext context, GameState gameState) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Seu Inventário (${gameState.playerInventory.length}/5)",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              TextButton.icon(
                icon: Icon(Icons.delete_sweep, size: 20, color: Colors.white),
                label: Text("Limpar", style: TextStyle(color: Colors.white)),
                onPressed: gameState.playerInventory.isNotEmpty
                    ? () => gameState.clearInventory()
                    : null,
                style: TextButton.styleFrom(foregroundColor: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 10),
          Container(
            height: 80,
            child: gameState.playerInventory.isEmpty
                ? Center(
                    child: Text("Seu inventário está vazio.",
                        style: TextStyle(color: Colors.white70)))
                : ListView(
                    scrollDirection: Axis.horizontal,
                    children: gameState.playerInventory.map((item) {
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Card(
                            color: Colors.white,
                            child: Container(
                              width: 100,
                              padding: EdgeInsets.all(8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(item.imagePath,
                                      height: 32, width: 32),
                                  SizedBox(height: 4),
                                  Text(item.name,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: -10,
                            right: -5,
                            child: InkWell(
                              onTap: () =>
                                  gameState.removeItemFromInventory(item),
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.red,
                                child: Icon(Icons.close,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopItemCard(
      BuildContext context, GameState gameState, GameItem item) {
    bool canAdd = gameState.playerInventory.length < 5;
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.deepPurple.shade800,
              backgroundImage: AssetImage(item.imagePath),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(item.description,
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('${item.price} Ouro',
                      style: TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed:
                  canAdd ? () => gameState.addItemToInventory(item) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    canAdd ? Colors.green.shade600 : Colors.grey.shade700,
                shape: CircleBorder(),
                padding: EdgeInsets.all(12),
              ),
              child: Icon(Icons.add_shopping_cart, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
