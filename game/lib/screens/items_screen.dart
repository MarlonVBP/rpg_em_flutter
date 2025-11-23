import 'package:flutter/material.dart';
import 'package:teste/data/models/item_model.dart';
import 'package:teste/providers/game_state.dart';
import 'package:provider/provider.dart';
import 'package:teste/data/local/all_game_items.dart'; // IMPORTANTE: Importe a lista global
import 'package:teste/services/audio_manager.dart';

class ItemsScreen extends StatelessWidget {
  const ItemsScreen({super.key});

  // Remova a lista `allGameItems` local que estava aqui dentro.
  // Vamos usar a importada de `data/local/all_game_items.dart`.

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Mercador da Vila'),
            backgroundColor: Colors.brown[800], // Cor mais temática
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Chip(
                  avatar:
                      const Icon(Icons.monetization_on, color: Colors.amber),
                  label: Text('${gameState.playerGold} Ouro'),
                  backgroundColor: Colors.black54,
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/background_inventory.png"),
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
                          ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount:
                        allGameItems.length, // Usa a lista global importada
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

  // _buildInventorySection permanece IGUAL ao seu código original (não precisa alterar)

  Widget _buildShopItemCard(
      BuildContext context, GameState gameState, GameItem item) {
    // Verifica se tem ouro e espaço para habilitar o botão visualmente (opcional, pois a lógica barra no clique)
    bool canAfford = gameState.playerGold >= item.price;
    bool hasSpace = gameState.playerInventory.length < 5;
    bool canBuy = canAfford && hasSpace;

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      color: Colors.black.withOpacity(0.8),
      shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey.shade800),
          borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(item.imagePath, width: 50, height: 50),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(item.description,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.monetization_on,
                          size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text('${item.price}',
                          style: TextStyle(
                              color: canAfford ? Colors.amber : Colors.red,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Chama a nova lógica de compra
                String? error = gameState.purchaseItem(item);
                if (error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error), backgroundColor: Colors.red),
                  );
                } else {
                  AudioManager.instance.playSfx('buy_sound.mp3');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Você comprou: ${item.name}!'),
                        backgroundColor: Colors.green),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    canBuy ? Colors.green.shade700 : Colors.grey.shade700,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(12),
              ),
              child: const Icon(Icons.add_shopping_cart, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // Lembre-se de copiar o _buildInventorySection do seu arquivo original se for substituir tudo
  Widget _buildInventorySection(BuildContext context, GameState gameState) {
    // ... (Cole o código original do método _buildInventorySection aqui)
    // Vou incluir uma versão resumida caso precise, mas o original estava bom.
    return Container(
        padding: EdgeInsets.all(16),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Mochila (${gameState.playerInventory.length}/5)",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              if (gameState.playerInventory.isNotEmpty)
                TextButton.icon(
                  icon: Icon(Icons.delete_sweep,
                      size: 20, color: Colors.red[300]),
                  label: Text("Jogar tudo fora",
                      style: TextStyle(color: Colors.red[300])),
                  onPressed: () => gameState.clearInventory(),
                ),
            ],
          ),
          SizedBox(height: 10),
          Container(
            height: 80,
            child: gameState.playerInventory.isEmpty
                ? Center(
                    child: Text("Vazio...",
                        style: TextStyle(color: Colors.white38)))
                : ListView(
                    scrollDirection: Axis.horizontal,
                    children: gameState.playerInventory.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: InkWell(
                          onTap: () => gameState.removeItemFromInventory(item),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white10,
                            backgroundImage: AssetImage(item.imagePath),
                            child: Align(
                                alignment: Alignment.topRight,
                                child: CircleAvatar(
                                    radius: 8,
                                    backgroundColor: Colors.red,
                                    child: Icon(Icons.close,
                                        size: 10, color: Colors.white))),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ]));
  }
}

// Extension to add purchaseItem if GameState doesn't define it.
// This keeps the UI code working and centralizes simple purchase logic here.
extension GameStatePurchaseExtension on GameState {
  /// Attempts to purchase [item]; returns null on success or an error message.
  String? purchaseItem(GameItem item) {
    // Check gold
    if (playerGold < item.price) {
      return 'Ouro insuficiente';
    }
    // Check inventory space (max 5)
    if (playerInventory.length >= 5) {
      return 'Inventário cheio';
    }
    // Deduct gold and add item
    playerGold -= item.price;
    playerInventory.add(item);
    // Notify listeners so UI updates
    try {
      // GameState is expected to extend ChangeNotifier, so notifyListeners should exist.
      // If it doesn't, this will be a no-op (compile will fail and you should add notifyListeners in GameState).
      notifyListeners();
    } catch (_) {}
    return null;
  }
}
