# **⚔️ RPG em Flutter**

Um jogo de RPG baseado em turnos desenvolvido com Flutter e Firebase. O jogo apresenta um sistema de combate estratégico com cartas, gerenciamento de inventário, missões (quests) e progressão de personagens.

## **📸 Funcionalidades**

* **Autenticação**: Login e Registro de usuários integrados ao Firebase Auth.  
* **Sistema de Batalha**: Combate em turnos utilizando cartas de ação (Ataque, Magia, Itens).  
* **Gerenciamento de Estado**: Controle centralizado de heróis, inventário e ouro via Provider.  
* **Persistência em Nuvem**: Salvamento automático de progresso (ouro, itens, heróis e status de missões) no Firebase Realtime Database.  
* **Inventário e Loja**: Compra e venda de itens que afetam os atributos do personagem.  
* **Sistema de Classes**: Afinidades elementais e bônus de atributos baseados na classe do herói (Guerreiro, Mago, Caçador, etc.).  
* **Suporte Multiplataforma**: Executável em Android, iOS e Web.

## **🛠️ Tecnologias Utilizadas**

* [**Flutter**](https://flutter.dev/): Framework principal de UI.  
* [**Provider**](https://pub.dev/packages/provider): Gerenciamento de estado.  
* [**Firebase**](https://firebase.google.com/):  
  * **Auth**: Gerenciamento de usuários.  
  * **Realtime Database**: Banco de dados NoSQL para dados do jogo.  
* [**AudioPlayers**](https://pub.dev/packages/audioplayers): Reprodução de música de fundo e efeitos sonoros.  
* [**Shared Preferences**](https://pub.dev/packages/shared_preferences): Armazenamento local leve para preferências do usuário (ex: último herói selecionado).

## **🚀 Como Rodar o Projeto**

### **Pré-requisitos**

* Flutter SDK instalado (versão \>=3.3.0).  
* Configuração do projeto no Console do Firebase.

### **Configuração do Firebase**

1. Crie um projeto no [Firebase Console](https://console.firebase.google.com/).  
2. Ative o **Authentication** (Email/Password).  
3. Crie um **Realtime Database**.  
4. Configure o flutterfire CLI para gerar o arquivo firebase\_options.dart:  
   flutterfire configure

### **Instalação**

1. Clone o repositório:  
   git clone \[https://github.com/seu-usuario/rpg\_em\_flutter.git\](https://github.com/seu-usuario/rpg\_em\_flutter.git)

2. Instale as dependências:  
   flutter pub get

3. Execute o projeto:  
   flutter run

## **🎮 Estrutura do Projeto**

* /lib/app: Configurações iniciais do app.  
* /lib/data: Modelos de dados (Heroi, Inimigo, Item) e dados estáticos locais.  
* /lib/providers: Lógica de estado (GameState, AuthProvider).  
* /lib/screens: Telas do jogo (Batalha, Home, Login, Inventário).  
* /lib/widgets: Componentes reutilizáveis de UI.  
* /lib/services: Serviços auxiliares (ex: AudioManager).

## **⚠️ Notas Importantes**

* O nome interno do pacote no pubspec.yaml está como teste. Recomenda-se alterar para algo mais descritivo se for publicar.  
* A persistência offline do Firebase está desabilitada na Web (main.dart), comportamento padrão para evitar erros de cache no navegador.

Desenvolvido com 💙 e Flutter.
