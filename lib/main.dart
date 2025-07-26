import 'package:controlab/app/config/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Assiste ao provider do GoRouter para obter a configuração de rotas.
    final router = ref.watch(goRouterProvider);

    // Define as cores primárias e secundárias para o tema.
    const primaryColor = Color(0xFF005B96);
    const secondaryColor = Color(0xFF64C7CC);
    const surfaceColor = Color(0xFFF0F4F8); // Um cinza azulado claro
    const backgroundColor = Color(
      0xFFE4EBF1,
    ); // Um fundo ligeiramente mais escuro

    // Cria o tema da aplicação.
    final theme = ThemeData(
      useMaterial3: true,
      // Define a paleta de cores principal.
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        background: backgroundColor,
        // Define cores para contraste, como texto sobre fundos coloridos.
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: const Color(
          0xFF0A2540,
        ), // Texto escuro para boa legibilidade
        onError: Colors.white,
      ),
      // Define a fonte padrão da aplicação usando Google Fonts.
      textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      // Define o tema para os cards.
      cardTheme: const CardThemeData(
        // CORREÇÃO: Utilizado CardThemeData em vez de CardTheme.
        elevation: 2,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        surfaceTintColor: Colors.white,
        color: Colors.white,
      ),
      // Define o tema para os botões elevados.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      // Define o tema para a AppBar.
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // Define o tema para a NavigationBar.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: secondaryColor.withOpacity(0.2),
        surfaceTintColor: Colors.white,
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
    );

    // Retorna o MaterialApp.router para usar o GoRouter.
    return MaterialApp.router(
      title: 'Controlab',
      debugShowCheckedModeBanner: false,
      theme: theme,
      // Configuração de rotas fornecida pelo GoRouter.
      routerConfig: router,
    );
  }
}
