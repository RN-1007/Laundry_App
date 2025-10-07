import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'pages/login.dart';
import 'pages/home.dart';
import 'pages/profile.dart';
import 'splash/splash_screen.dart';

// Import semua model dan halaman yang dibutuhkan
import 'models/corporate_partner_model.dart';
import 'models/customer_model.dart';
import 'models/kiloan_order_model.dart';
import 'models/laundy_template_model.dart';
import 'models/member_customer_model.dart';
import 'models/order_model.dart';
import 'models/promo_model.dart';
import 'models/satuan_order_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laundry Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey.shade50,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xff1C1C27),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String username;
  const MyHomePage({super.key, required this.username});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int _bottomNavIndex = 0;

  final List<Customer> _customers = [
    MemberCustomer(
      id: "CUST-01",
      name: "Budi Santoso",
      phoneNumber: "08123",
      memberId: "MEM-001",
      memberTier: "Gold",
    ),
    CorporatePartner(
      id: "CUST-02",
      name: "Ibu Citra",
      phoneNumber: "08124",
      companyName: "Hotel Merdeka",
    ),
    RegularCustomer(id: "CUST-03", name: "Ahmad Yani", phoneNumber: "08125"),
    MemberCustomer(
      id: "CUST-04",
      name: "Dewi Anggraini",
      phoneNumber: "08126",
      memberId: "MEM-002",
      memberTier: "Silver",
    ),
  ];
  late List<Order> _orders;
  late List<LaundryTemplate> _templates;
  late List<Promo> _promos;

  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  late CurvedAnimation _fabCurve;

  final autoSizeGroup = AutoSizeGroup();
  final iconList = <IconData>[Icons.dashboard_rounded, Icons.person_rounded];
  final pageTitles = [
    'Fena Laundry',
    'Fena Laundry',
  ]; // Judul diubah agar lebih sesuai
  final navLabels = ['Dashboard', 'Profil'];

  @override
  void initState() {
    super.initState();
    _initializeData();

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fabCurve = CurvedAnimation(
      parent: _fabAnimationController,
      curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    );
    _fabAnimation = Tween<double>(begin: 0, end: 1).animate(_fabCurve);
    _fabAnimationController.forward();
  }

  void _initializeData() {
    _orders = [
      KiloanOrder(
        id: "INV-001",
        customer: _customers[0],
        status: OrderStatus.selesai,
        entryDate: "16 Oct 2025",
        weightInKg: 3,
        pricePerKg: 15000,
      ),
      KiloanOrder(
        id: "INV-002",
        customer: _customers[1],
        status: OrderStatus.prosesCuci,
        entryDate: "16 Oct 2025",
        weightInKg: 25,
        pricePerKg: 12000,
      ),
      SatuanOrder(
        id: "INV-003",
        customer: _customers[2],
        status: OrderStatus.menungguDiambil,
        entryDate: "15 Oct 2025",
        items: [
          LaundryItem(name: "Jaket", quantity: 1, price: 20000),
          LaundryItem(name: "Celana Jeans", quantity: 1, price: 12000),
        ],
      ),
      SatuanOrder(
        id: "INV-004",
        customer: _customers[3],
        status: OrderStatus.selesai,
        entryDate: "15 Oct 2025",
        items: [
          LaundryItem(name: "Set Sprei", quantity: 1, price: 60000),
          LaundryItem(name: "Gorden", quantity: 2, price: 25000),
        ],
      ),
    ];
    _templates = [
      LaundryTemplate(
        id: 'TMP-01',
        name: 'Cuci Setrika Reguler',
        type: TemplateType.kiloan,
        price: 15000,
      ),
      LaundryTemplate(
        id: 'TMP-02',
        name: 'Cuci Kering Ekspress',
        type: TemplateType.kiloan,
        price: 25000,
      ),
      LaundryTemplate(
        id: 'TMP-03',
        name: 'Bed Cover King',
        type: TemplateType.satuan,
        price: 60000,
      ),
      LaundryTemplate(
        id: 'TMP-04',
        name: 'Jaket Kulit',
        type: TemplateType.satuan,
        price: 50000,
      ),
    ];
    _promos = [
      Promo(
        id: 'PROMO-01',
        name: 'Diskon Awal Bulan',
        type: PromoType.percentage,
        value: 10,
        minTransaction: 50000,
      ),
      Promo(
        id: 'PROMO-02',
        name: 'Potongan Cuci Bed Cover',
        type: PromoType.fixed,
        value: 5000,
        minTransaction: 60000,
      ),
    ];
  }

  void _addOrder(Order newOrder) {
    setState(() {
      _orders.add(newOrder);
      if (!_customers.any((c) => c.id == newOrder.customer.id)) {
        _customers.add(newOrder.customer);
      }
    });
  }

  void _updateOrder(Order updatedOrder) => setState(() {
    final index = _orders.indexWhere((o) => o.id == updatedOrder.id);
    if (index != -1) _orders[index] = updatedOrder;
  });
  void _deleteOrder(String orderId) =>
      setState(() => _orders.removeWhere((o) => o.id == orderId));
  void _updateCustomer(Customer updatedCustomer) => setState(() {
    final custIndex = _customers.indexWhere((c) => c.id == updatedCustomer.id);
    if (custIndex != -1) _customers[custIndex] = updatedCustomer;
    _orders = _orders.map((order) {
      if (order.customer.id == updatedCustomer.id) {
        if (order is KiloanOrder)
          return KiloanOrder(
            id: order.id,
            customer: updatedCustomer,
            entryDate: order.entryDate,
            status: order.status,
            weightInKg: order.weightInKg,
            pricePerKg: order.pricePerKg,
          );
        if (order is SatuanOrder)
          return SatuanOrder(
            id: order.id,
            customer: updatedCustomer,
            entryDate: order.entryDate,
            status: order.status,
            items: order.items,
          );
      }
      return order;
    }).toList();
  });
  void _addTemplate(LaundryTemplate template) =>
      setState(() => _templates.add(template));
  void _updateTemplate(LaundryTemplate template) => setState(() {
    final index = _templates.indexWhere((t) => t.id == template.id);
    if (index != -1) _templates[index] = template;
  });
  void _deleteTemplate(String id) =>
      setState(() => _templates.removeWhere((t) => t.id == id));
  void _addPromo(Promo promo) => setState(() => _promos.add(promo));
  void _updatePromo(Promo promo) => setState(() {
    final index = _promos.indexWhere((p) => p.id == promo.id);
    if (index != -1) _promos[index] = promo;
  });
  void _deletePromo(String id) =>
      setState(() => _promos.removeWhere((p) => p.id == id));
  void _logout() => Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const LoginPage()),
  );

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomePage(
        customers: _customers,
        orders: _orders,
        templates: _templates,
        promos: _promos,
        onAddOrder: _addOrder,
        onUpdateOrder: _updateOrder,
        onDeleteOrder: _deleteOrder,
        onUpdateCustomer: _updateCustomer,
        onAddTemplate: _addTemplate,
        onUpdateTemplate: _updateTemplate,
        onDeleteTemplate: _deleteTemplate,
        onAddPromo: _addPromo,
        onUpdatePromo: _updatePromo,
        onDeletePromo: _deletePromo,
      ),
      // Meneruskan fungsi logout ke ProfilePage
      ProfilePage(adminEmail: widget.username, onLogout: _logout),
    ];

    return Scaffold(
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xff252533),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 10,
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            titleSpacing: 40.0,
            title: Text(pageTitles[_bottomNavIndex]),
            actions: const [],
          ),
        ),
      ),
      body: IndexedStack(index: _bottomNavIndex, children: pages),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton(
          elevation: 8,
          backgroundColor: const Color(0xff8A3FFC),
          child: Icon(iconList[_bottomNavIndex], color: Colors.white),
          onPressed: () {},
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: iconList.length,
        tabBuilder: (int index, bool isActive) {
          final color = isActive ? const Color(0xff8A3FFC) : Colors.grey[400];
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(iconList[index], size: 24, color: color),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: AutoSizeText(
                  navLabels[index],
                  maxLines: 1,
                  style: TextStyle(
                    color: color,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                  group: autoSizeGroup,
                ),
              ),
            ],
          );
        },
        backgroundColor: const Color(0xff252533),
        activeIndex: _bottomNavIndex,
        splashColor: const Color(0xff8A3FFC).withOpacity(0.5),
        notchSmoothness: NotchSmoothness.verySmoothEdge,
        gapLocation: GapLocation.center,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        onTap: (index) => setState(() => _bottomNavIndex = index),
        shadow: BoxShadow(
          color: Colors.black.withOpacity(0.3),
          spreadRadius: 0,
          blurRadius: 15,
        ),
      ),
    );
  }
}
