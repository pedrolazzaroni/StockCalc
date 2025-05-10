# 📈 StockCalc

StockCalc é um aplicativo mobile moderno para simular investimentos em ações de qualquer país, de forma simples, visual e rápida. O app oferece uma experiência intuitiva, com interface elegante nas cores laranja e preto, e recursos completos para quem deseja planejar seus investimentos.

## Funcionalidades

- **Busca inteligente de ações**: Pesquise ações pelo código (ex: PETR4, VALE3, AAPL, TSLA) e obtenha automaticamente o nome, preço atual, rentabilidade média anual e mensal, usando a API Gemini 2.0 Flash do Google (dados podem não ser precisos ou atuais).
- **Simulação de investimento**: Informe o valor inicial, aporte recorrente, período (anual ou mensal) e tempo de investimento. O app calcula o valor futuro estimado do seu investimento.
- **Gráfico de evolução**: Visualize a evolução do seu investimento ao longo do tempo em um gráfico de linha moderno.
- **Comparação de ações**: Adicione várias ações para comparar diferentes cenários de investimento.
- **Histórico de simulações**: Acesse o histórico dos últimos cálculos realizados, com detalhes de cada simulação (ação, investido, valor futuro, tempo e data).
- **Compartilhamento**: Compartilhe o resultado da sua simulação com amigos de forma rápida.
- **Interface responsiva**: Layout adaptado para diferentes tamanhos de tela, com navegação fluida entre as páginas.
- **Página Sobre**: Informações sobre o app o criador.
- **Página inicial com navegação**: Acesse rapidamente as funções principais: Iniciar simulação, Sobre e Histórico (aparece apenas se houver simulações salvas).
- **Avisos de precisão**: O app informa que os dados são fornecidos pela API Gemini 2.0 Flash e podem não ser precisos, pois o modelo foi treinado até dezembro de 2023.

## Como funciona?
1. Na tela inicial, escolha "Iniciar" para começar ou "Sobre" para ver informações do app. O botão "Histórico" aparece se houver simulações salvas.
2. Busque uma ação pelo código e selecione-a.
3. Preencha os dados do investimento (valor, aporte, tempo, período).
4. Veja o valor futuro estimado, o gráfico de evolução e compartilhe o resultado.
5. Consulte o histórico de simulações a qualquer momento.

## Tecnologias
- Flutter
- fl_chart
- google_fonts
- shared_preferences
- API Gemini 2.0 Flash (Google)

## Como rodar
1. Clone este repositório
2. Instale as dependências com `flutter pub get`
3. Conecte seu celular via USB, ative a depuração USB e execute:
   ```
   flutter run
   ```

---

Feito com 💸 por Pedro Lazzaroni.
