import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBalance();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBalance() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    if (authProvider.token != null) {
      await walletProvider.getBalance(authProvider.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final walletProvider = Provider.of<WalletProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        title: Text(
          l10n.wallet,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFF4081),
          labelColor: const Color(0xFFFF4081),
          unselectedLabelColor: Colors.white.withValues(alpha: 0.5),
          tabs: [
            Tab(text: l10n.recharge),
            Tab(text: l10n.withdraw),
            Tab(text: 'Convertir'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Balance card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF4081), Color(0xFF9C27B0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF4081).withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Balance Total',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          color: Color(0xFFFFD700),
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${walletProvider.coins}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          l10n.coins,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 60,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    Column(
                      children: [
                        const Icon(
                          Icons.diamond,
                          color: Color(0xFF00BCD4),
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${walletProvider.diamonds}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          l10n.diamonds,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _RechargeTab(),
                _WithdrawTab(),
                _ConvertTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Tab de recarga
class _RechargeTab extends StatelessWidget {
  final List<Map<String, dynamic>> _amounts = [
    {'usd': 1, 'coins': 25000},
    {'usd': 5, 'coins': 125000},
    {'usd': 10, 'coins': 250000},
    {'usd': 20, 'coins': 500000},
    {'usd': 50, 'coins': 1250000},
    {'usd': 100, 'coins': 2500000},
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selecciona el monto a recargar:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: _amounts.length,
            itemBuilder: (context, index) {
              final amount = _amounts[index];
              return GestureDetector(
                onTap: () async {
                  final success = await walletProvider.rechargeCoins(
                    authProvider.token!,
                    amount['usd'].toDouble(),
                  );
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Recarga exitosa: ${amount['coins']} monedas',
                        ),
                        backgroundColor: const Color(0xFF4CAF50),
                      ),
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFF4081).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '\$${amount['usd']}',
                        style: const TextStyle(
                          color: Color(0xFFFF4081),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.monetization_on,
                            color: Color(0xFFFFD700),
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${amount['coins']}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white54, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '1 USD = 25,000 monedas',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Tab de retiro
class _WithdrawTab extends StatefulWidget {
  @override
  State<_WithdrawTab> createState() => _WithdrawTabState();
}

class _WithdrawTabState extends State<_WithdrawTab> {
  final _diamondsController = TextEditingController();

  @override
  void dispose() {
    _diamondsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final walletProvider = Provider.of<WalletProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Solicitar retiro:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _diamondsController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Cantidad de diamantes',
              labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
              prefixIcon: const Icon(Icons.diamond, color: Color(0xFF00BCD4)),
              filled: true,
              fillColor: const Color(0xFF1A1A1A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFFF4081)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.white54, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Información de retiro:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _InfoRow(label: 'Mínimo:', value: '500,000 diamantes (10 USD)'),
                _InfoRow(label: 'Conversión:', value: '50,000 diamantes = 1 USD'),
                _InfoRow(
                  label: 'Tus diamantes:',
                  value: '${walletProvider.diamonds}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () async {
                final diamonds = int.tryParse(_diamondsController.text);
                if (diamonds == null || diamonds < 500000) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mínimo 500,000 diamantes'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                final success = await walletProvider.requestWithdrawal(
                  authProvider.token!,
                  diamonds,
                );
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Solicitud de retiro enviada'),
                      backgroundColor: Color(0xFF4CAF50),
                    ),
                  );
                  _diamondsController.clear();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4081),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Solicitar retiro',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Tab de conversión
class _ConvertTab extends StatefulWidget {
  @override
  State<_ConvertTab> createState() => _ConvertTabState();
}

class _ConvertTabState extends State<_ConvertTab> {
  final _diamondsController = TextEditingController();

  @override
  void dispose() {
    _diamondsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final walletProvider = Provider.of<WalletProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Convertir diamantes a monedas:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _diamondsController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Cantidad de diamantes',
              labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
              prefixIcon: const Icon(Icons.diamond, color: Color(0xFF00BCD4)),
              filled: true,
              fillColor: const Color(0xFF1A1A1A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFFF4081)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.white54, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Información de conversión:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _InfoRow(label: 'Tasa:', value: '2 diamantes = 1 moneda (50% pérdida)'),
                _InfoRow(
                  label: 'Tus diamantes:',
                  value: '${walletProvider.diamonds}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () async {
                final diamonds = int.tryParse(_diamondsController.text);
                if (diamonds == null || diamonds <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ingresa una cantidad válida'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                final success = await walletProvider.convertDiamonds(
                  authProvider.token!,
                  diamonds,
                );
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Conversión exitosa: ${diamonds ~/ 2} monedas recibidas',
                      ),
                      backgroundColor: const Color(0xFF4CAF50),
                    ),
                  );
                  _diamondsController.clear();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4081),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Convertir',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}