import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'core/monitoring/firebase_monitoring.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/firebase_auth_session_repository.dart';
import 'data/repositories/drift_business_dashboard_repository.dart';
import 'data/repositories/drift_inventory_planning_repository.dart';
import 'data/repositories/drift_repositories.dart';
import 'data/repositories/drift_sales_report_repository.dart';
import 'data/repositories/drift_transaction_management_repository.dart';
import 'data/repositories/local_panorama_repository.dart';
import 'data/sync/outbox_background_worker.dart';
import 'di/app_container.dart';
import 'domain/repositories/repositories.dart';
import 'domain/entities/auth_session.dart';
import 'domain/repositories/auth_session_repository.dart';
import 'features/auth/presentation/auth_session_gate.dart';
import 'features/dashboard/presentation/store_dashboard_page.dart';
import 'features/onboarding/data/onboarding_store.dart';
import 'features/onboarding/presentation/onboarding_gate.dart';
import 'features/splash/presentation/splash_gate.dart';
import 'features/transaction/presentation/product_scanner_page.dart';
import 'features/transaction/presentation/transaction_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final monitoring = FirebaseMonitoring();
  monitoring.installGlobalErrorHandlers();
  final monitoringStatus = await monitoring.initialize();
  scheduleOutboxBackgroundSync();
  final container = AppContainer();
  final authSessionRepository = monitoringStatus == MonitoringStatus.active
      ? FirebaseAuthSessionRepository(auth: FirebaseAuth.instance)
      : null;
  runApp(
    RyanGunshopApp(
      layoutRepository: DriftStoreLayoutRepository(container.database),
      dashboardRepository: DriftBusinessDashboardRepository(container.database),
      salesReportRepository: DriftSalesReportRepository(container.database),
      transactionManagementRepository: DriftTransactionManagementRepository(
        container.database,
      ),
      panoramaRepository: LocalPanoramaRepository(),
      productRepository: container.products,
      inventoryPlanningRepository: DriftInventoryPlanningRepository(
        container.database,
      ),
      transactionViewModelFactory: () => container.createTransactionViewModel(
        storeId: 'local-preview-store',
        cashierId: 'local-owner',
      ),
      authSessionRepository: authSessionRepository,
      authenticatedTransactionViewModelFactory: (session) =>
          container.createTransactionViewModel(
            storeId: session.storeId,
            cashierId: session.userId,
          ),
      canEditLayout: true,
    ),
  );
}

typedef AuthenticatedTransactionViewModelFactory =
    Future<TransactionViewModel> Function(AuthenticatedSession session);

class RyanGunshopApp extends StatelessWidget {
  RyanGunshopApp({
    required this.layoutRepository,
    BusinessDashboardRepository? dashboardRepository,
    SalesReportRepository? salesReportRepository,
    TransactionManagementRepository? transactionManagementRepository,
    PanoramaRepository? panoramaRepository,
    this.productRepository,
    this.inventoryPlanningRepository,
    this.transactionViewModelFactory,
    this.authSessionRepository,
    this.authenticatedTransactionViewModelFactory,
    this.canEditLayout = false,
    this.allowUnauthenticatedLocalMode = kDebugMode,
    OnboardingStore? onboardingStore,
    super.key,
  }) : dashboardRepository =
           dashboardRepository ?? const EmptyBusinessDashboardRepository(),
       salesReportRepository =
           salesReportRepository ?? const EmptySalesReportRepository(),
       transactionManagementRepository =
           transactionManagementRepository ??
           const EmptyTransactionManagementRepository(),
       panoramaRepository =
           panoramaRepository ?? const EmptyPanoramaRepository(),
       onboardingStore = onboardingStore ?? SharedPreferencesOnboardingStore();

  final StoreLayoutRepository layoutRepository;
  final BusinessDashboardRepository dashboardRepository;
  final SalesReportRepository salesReportRepository;
  final TransactionManagementRepository transactionManagementRepository;
  final PanoramaRepository panoramaRepository;
  final ProductRepository? productRepository;
  final InventoryPlanningRepository? inventoryPlanningRepository;
  final TransactionViewModelFactory? transactionViewModelFactory;
  final AuthSessionRepository? authSessionRepository;
  final AuthenticatedTransactionViewModelFactory?
  authenticatedTransactionViewModelFactory;
  final bool canEditLayout;
  final bool allowUnauthenticatedLocalMode;
  final OnboardingStore onboardingStore;

  @override
  Widget build(BuildContext context) {
    Widget dashboard({AuthenticatedSession? session, VoidCallback? onSignOut}) {
      final storeId = session?.storeId ?? 'local-preview-store';
      final actorId = session?.userId ?? 'local-owner';
      final sessionFactory = session == null
          ? transactionViewModelFactory
          : authenticatedTransactionViewModelFactory == null
          ? transactionViewModelFactory
          : () => authenticatedTransactionViewModelFactory!(session);
      return StoreDashboardPage(
        layoutRepository: layoutRepository,
        dashboardRepository: dashboardRepository,
        salesReportRepository: salesReportRepository,
        transactionManagementRepository: transactionManagementRepository,
        panoramaRepository: panoramaRepository,
        productRepository: productRepository,
        inventoryPlanningRepository: inventoryPlanningRepository,
        transactionViewModelFactory: sessionFactory,
        storeId: storeId,
        transactionActorId: actorId,
        canEditLayout: session?.isOwner ?? canEditLayout,
        accountName: session?.displayName,
        accountRole: session?.role.name,
        onSignOut: onSignOut,
      );
    }

    final repository = authSessionRepository;
    final content = repository == null
        ? allowUnauthenticatedLocalMode
              ? dashboard()
              : const _AuthenticationUnavailablePage()
        : AuthSessionGate(
            repository: repository,
            builder: (context, session, signOut) => dashboard(
              session: session,
              onSignOut: () => unawaited(signOut()),
            ),
          );
    return MaterialApp(
      title: 'RyanGunshop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: SplashGate(
        child: OnboardingGate(store: onboardingStore, child: content),
      ),
    );
  }
}

class _AuthenticationUnavailablePage extends StatelessWidget {
  const _AuthenticationUnavailablePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 56,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Layanan akun belum tersedia',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'RyanGunshop tidak membuka data warung sampai koneksi akun '
                    'dapat diverifikasi. Tutup aplikasi, periksa koneksi, lalu '
                    'coba kembali.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
