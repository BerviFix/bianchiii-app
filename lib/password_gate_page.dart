import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importa shared_preferences
import 'package:supabase_flutter/supabase_flutter.dart';

class PasswordGatePage extends StatefulWidget {
  final Widget child;
  const PasswordGatePage({Key? key, required this.child}) : super(key: key);

  @override
  State<PasswordGatePage> createState() => _PasswordGatePageState();
}

class _PasswordGatePageState extends State<PasswordGatePage> with SingleTickerProviderStateMixin {
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isAuthenticated = false;
  bool _isError = false;
  bool _isLoading = false;
  bool _passwordVisible = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final String _email = 'simone.bervi@gmail.com';
  late final SupabaseClient _supabaseClient;

  // Chiave per SharedPreferences
  static const String _loginTimestampKey = 'login_timestamp_millis';
  final Duration _sessionTimeoutDuration = const Duration(hours: 1);

  @override
  void initState() {
    super.initState();
    _initSupabase();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _checkSessionAndTimestamp(); // Modificato da _checkIfAlreadyAuthenticated
    _animationController.forward();
  }

  Future<void> _initSupabase() async {
    _supabaseClient = Supabase.instance.client;
  }

  Future<void> _checkSessionAndTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final session = _supabaseClient.auth.currentSession;
    final loginTimestampMillis = prefs.getInt(_loginTimestampKey);

    if (session != null) {
      // L'utente ha una sessione Supabase attiva
      if (loginTimestampMillis != null) {
        final nowMillis = DateTime.now().millisecondsSinceEpoch;
        if (nowMillis - loginTimestampMillis >= _sessionTimeoutDuration.inMilliseconds) {
          // Sessione scaduta in base al nostro timestamp
          await _performLogout(prefs);
        } else {
          // Sessione ancora valida
          setState(() => _isAuthenticated = true);
        }
      } else {
        // Sessione Supabase esiste, ma non c'è il nostro timestamp (es. primo login o login precedente)
        // Salviamo il timestamp ora, assumendo che la sessione sia appena iniziata o valida.
        await prefs.setInt(_loginTimestampKey, DateTime.now().millisecondsSinceEpoch);
        setState(() => _isAuthenticated = true);
      }
    } else {
      // Nessuna sessione Supabase, quindi l'utente non è autenticato
      await _performLogout(prefs); // Assicura che il timestamp sia pulito
    }
  }

  Future<void> _authenticate() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();

    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: _email,
        password: _passwordController.text,
      );

      if (response.user != null) {
        // Login riuscito: salva il timestamp corrente
        await prefs.setInt(_loginTimestampKey, DateTime.now().millisecondsSinceEpoch);
        setState(() {
          _isError = false;
          _isLoading = false;
          _isAuthenticated = true;
        });
        await _animationController.reverse();
      } else {
        throw Exception('Autenticazione fallita');
      }
    } catch (e) {
      HapticFeedback.mediumImpact();
      setState(() {
        _isError = true;
        _isLoading = false;
      });
      // In caso di errore di autenticazione, è buona norma rimuovere un eventuale timestamp vecchio
      await prefs.remove(_loginTimestampKey);
      _shakeAnimation();
    }
  }

  Future<void> _performLogout(SharedPreferences prefs) async {
    await _supabaseClient.auth.signOut();
    await prefs.remove(_loginTimestampKey); // Rimuovi il timestamp al logout
    if (mounted) {
      setState(() {
        _isAuthenticated = false;
        _passwordController.clear(); // Opzionale: pulisci la password
      });
      // Ritarda il focus per dare tempo alla UI di aggiornarsi se necessario
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  Future<void> _shakeAnimation() async {
    const int count = 6;
    const Duration duration = Duration(milliseconds: 50);

    for (int i = 0; i < count; i++) {
      await Future.delayed(duration, () {
        // Non è necessario fare setState qui se l'animazione è gestita
        // da un AnimationController o se non cambia lo stato visivo
        // che dipende da `build`. Lo shake qui sembra essere un effetto
        // visivo temporaneo non legato allo stato persistente.
        // Se lo shake è un'animazione del TextField stesso,
        // questa logica potrebbe essere rivista.
        // Per ora, la selezione del testo è mantenuta.
        if (mounted) {
          _passwordController.selection = TextSelection.fromPosition(
              TextPosition(offset: _passwordController.text.length));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticated) {
      return widget.child;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: child,
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.black,
                Colors.grey.shade900,
              ],
            ),
          ),
          child: Center(
            child: _buildGlassmorphicCard(),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassmorphicCard() {
    return Container(
      width: 360,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.lock_outline,
            color: Colors.white,
            size: 50,
          ),
          const SizedBox(height: 24),
          const Text(
            'Area Riservata',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Inserisci la password per accedere',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildPasswordField(),
          const SizedBox(height: 32),
          _buildLoginButton(),
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isError
              ? Colors.red.withOpacity(0.7)
              : Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _passwordController,
        focusNode: _focusNode,
        style: const TextStyle(color: Colors.white),
        obscureText: !_passwordVisible,
        decoration: InputDecoration(
          hintText: 'Password',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixIcon: _isError
              ? const Icon(Icons.error_outline, color: Colors.red)
              : IconButton(
            icon: Icon(
              _passwordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.white70,
            ),
            onPressed: () {
              setState(() {
                _passwordVisible = !_passwordVisible;
              });
            },
          ),
        ),
        onSubmitted: (_) => _authenticate(),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _authenticate,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurpleAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
          ),
        )
            : const Text(
          'Accedi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }
}