## 📋 Descrição do Projeto

**App Service Order** é uma aplicação Flutter desenvolvida para gerenciamento de ordens de serviço. O sistema permite que usuários visualizem, gerenciem e executem ordens de serviço, com suporte a captura de imagens, descrição de atividades e rastreamento de status.

A aplicação segue uma arquitetura limpa e escalável, com separação clara entre camadas de apresentação, domínio e dados.

---

## 🏗️ Arquitetura

O projeto segue os princípios de **Clean Architecture** com as seguintes camadas:

### Estrutura de Pastas

```
lib/
├── core/
│   ├── data/
│   └── domain/
├── di/                          # Dependency Injection (GetIt + Injectable)
├── database/
├── module/
│   ├── home/
│   │   ├── core/
│   │   │   ├── domain/
│   │   │   └── data/
│   │   ├── controller/
│   │   └── view/
│   ├── execution/
│   │   ├── controller/
│   │   ├── state/
│   │   └── view/
│   ├── image/
│   │   ├── core/
│   │   │   ├── domain/
│   │   │   └── repository/
│   │   └── data/
│   └── navigation/
└── main.dart
```

### Padrões Utilizados

- **Bloc Pattern**: Gerenciamento de estado com `flutter_bloc`
- **Clean Architecture**: Separação em camadas (Presentation, Domain, Data)
- **Repository Pattern**: Abstração de acesso a dados
- **Use Cases**: Lógica de negócio encapsulada
- **Dependency Injection**: GetIt + Injectable para injeção de dependências
- **Estados Discretos**: Hierarquia de estados para `ServiceExecutionState`

### Principais Componentes

#### 1. **HomeController**
Gerencia o estado da tela inicial e lista de ordens de serviço.

#### 2. **ServiceExecutionCubit**
Responsável por toda a lógica de execução de ordens:
- Gerenciamento de imagens
- Atualização de descrição
- Validação de formulários
- Finalização de atendimento

#### 3. **NavigationCubit**
Controla navegação entre telas principais (Home e Execução).

#### 4. **Estados Discretos**
```dart
abstract class ServiceExecutionState {}
class ServiceExecutionInitial extends ServiceExecutionState {}
class ServiceExecutionLoadingImages extends ServiceExecutionState {}
class ServiceExecutionReady extends ServiceExecutionState {}
class ServiceExecutionProcessing extends ServiceExecutionState {}
class ServiceExecutionError extends ServiceExecutionState {}
class ServiceExecutionSuccess extends ServiceExecutionState {}
```

---

## 🚀 Como Rodar o Projeto

### Pré-requisitos

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (versão 3.9.2 ou superior)
- [Dart SDK](https://dart.dev/get-dart)
- Um dispositivo Android/iOS ou emulador configurado

### Passos de Instalação

1. **Clone o repositório**
   ```bash
   git clone <seu-repositorio>
   cd app_service_order
   ```

2. **Instale as dependências**
   ```bash
   flutter pub get
   ```

3. **Gere os arquivos de injeção de dependências** ⚠️ **IMPORTANTE**
   ```bash
   dart run build_runner build
   ```
   
   Ou para modo watch (recompila automaticamente ao detectar mudanças):
   ```bash
   dart run build_runner watch
   ```

4. **Execute a aplicação**
   ```bash
   flutter run
   ```

---

## 📱 Visualização do App

### Telas Principais

<p float="left">
  <img src="https://github.com/cristiantebaldi/app_service_order/blob/main/app_preview/home.jpg" width="200" height="415px"/>
  <img src="https://github.com/cristiantebaldi/app_service_order/blob/main/app_preview/atendimento.jpg" width="200" height="415px"/>
    <img src="https://github.com/cristiantebaldi/app_service_order/blob/main/app_preview/extrato.jpg" width="200" height="415px"/>
</p>

---

## 🔧 Stack Tecnológico

- **Flutter**: Framework de UI
- **Dart**: Linguagem de programação
- **Bloc**: Gerenciamento de estado
- **GetIt**: Service Locator para DI
- **Injectable**: Gerador de código para DI
- **SQLite**: Banco de dados local (sqflite)
- **Image Picker**: Captura de imagens
- **Path Provider**: Acesso ao sistema de arquivos

---

## 📦 Dependências Principais

```yaml
dependencies:
  flutter_bloc: ^8.1.6
  get_it: ^7.7.0
  injectable: ^2.4.2
  sqflite: ^2.4.2
  image_picker: ^1.1.2
  path_provider: ^2.1.4

dev_dependencies:
  build_runner: ^2.4.12
  injectable_generator: ^2.6.1
```

---

## 🎯 Features

- ✅ Visualização de ordens de serviço
- ✅ Captura de imagens durante execução
- ✅ Preenchimento de descrição/relatório
- ✅ Validação de formulários
- ✅ Estados de execução discretos
- ✅ Persistência em banco de dados local
- ✅ Gerenciamento de estado com Bloc

---

## 👨‍💻 Desenvolvedor

**Nome:** Cristian Luís Tebaldi  
**Email:** cristiantebaldi@gmail.com  
**LinkedIn:** [www.linkedin.com/in/cristian-luís-tebaldi](www.linkedin.com/in/cristian-luís-tebaldi)  
**GitHub:** [cristiantebaldi](https://github.com/cristiantebaldi) 

---

## 📄 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [`LICENSE`](LICENSE) para mais detalhes.
