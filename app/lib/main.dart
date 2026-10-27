import 'package:flutter/material.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'core/config/brand.dart';
import 'core/network/api_client.dart';
import 'core/services/local_profile_photo.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/views/forgot_password_view.dart';
import 'features/auth/views/select_shop_view.dart';
import 'features/auth/views/sign_in_view.dart';
import 'features/auth/views/sign_up_view.dart';
import 'features/auth/views/welcome_view.dart';
import 'features/billing/views/subscription_paywall_view.dart';
import 'features/calendar/views/calendar_view.dart';
import 'features/common/views/module_placeholder_view.dart';
import 'features/customers/views/customers_view.dart';
import 'features/dashboard/views/home_shell.dart';
import 'features/intro/views/app_intro_view.dart';
import 'features/measurements/views/measurements_view.dart';
import 'features/notifications/views/notifications_view.dart';
import 'features/onboarding/views/onboarding_flow_view.dart';
import 'features/onboarding/views/onboarding_view.dart';
import 'features/orders/views/order_detail_view.dart';
import 'features/orders/views/order_form_view.dart';
import 'features/payments/views/payments_view.dart';
import 'features/profile/views/profile_view.dart';
import 'features/profile/views/shop_settings_view.dart';
import 'features/reports/views/reports_view.dart';
import 'features/settings/views/settings_view.dart';
import 'features/staff/views/staff_view.dart';
import 'features/templates/views/templates_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final api = await ApiClient().init();
  Get.put(api, permanent: true);
  Get.put(AuthController(), permanent: true);
  final settings = SettingsController();
  await settings.load();
  Get.put(settings, permanent: true);
  final profilePhoto = LocalProfilePhoto();
  await profilePhoto.load();
  Get.put(profilePhoto, permanent: true);
  await Get.find<AuthController>().hydrate();
  runApp(SilaiSetuApp(settings: settings));
}

class SilaiSetuApp extends StatelessWidget {
  const SilaiSetuApp({super.key, required this.settings});
  final SettingsController settings;

  String _initialRoute(AuthController auth) {
    // Stay logged in across app restarts when a session was restored.
    if (auth.user.value != null || Get.find<ApiClient>().hasSession) {
      if (auth.user.value == null) return '/home';
      return auth.routeAfterAuth();
    }
    // First-time users see 3 intro screens once.
    if (!settings.introSeen.value) return '/intro';
    return '/welcome';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final auth = Get.find<AuthController>();
      final themeMode = settings.themeMode.value;
      final locale = settings.locale.value;
      return GetMaterialApp(
        title: Brand.name,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: themeMode,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        initialRoute: _initialRoute(auth),
        getPages: [
          GetPage(name: '/intro', page: () => const AppIntroView()),
          GetPage(name: '/welcome', page: () => const WelcomeView()),
          GetPage(name: '/sign-in', page: () => const SignInView()),
          GetPage(name: '/sign-up', page: () => const SignUpView()),
          GetPage(name: '/login', page: () => const SignInView()),
          GetPage(name: '/forgot-password', page: () => const ForgotPasswordView()),
          GetPage(name: '/reset-password', page: () => const ResetPasswordView()),
          GetPage(
            name: '/forgot-identifier',
            page: () => const ForgotIdentifierView(),
          ),
          GetPage(name: '/verify', page: () => const VerifyView()),
          GetPage(name: '/onboarding', page: () => const OnboardingView()),
          GetPage(
            name: '/onboarding/flow',
            page: () => const OnboardingFlowView(),
          ),
          GetPage(name: '/select-shop', page: () => const SelectShopView()),
          GetPage(
            name: '/subscription',
            page: () => const SubscriptionPaywallView(),
          ),
          GetPage(name: '/home', page: () => const HomeShell()),
          GetPage(name: '/customers', page: () => const CustomersView()),
          GetPage(name: '/customers/new', page: () => const CustomerFormView()),
          GetPage(
            name: '/customers/:id',
            page: () => CustomerDetailView(id: Get.parameters['id']!),
          ),
          GetPage(
            name: '/customers/:id/edit',
            page: () => CustomerFormView(id: Get.parameters['id']),
          ),
          GetPage(name: '/orders/new', page: () => const OrderFormView()),
          GetPage(
            name: '/orders/:id',
            page: () => OrderDetailView(id: Get.parameters['id']!),
          ),
          GetPage(name: '/measurements', page: () => const MeasurementsListView()),
          GetPage(
            name: '/measurements/new',
            page: () => const MeasurementFormView(),
          ),
          GetPage(name: '/templates', page: () => const TemplatesView()),
          GetPage(name: '/staff', page: () => const StaffView()),
          GetPage(name: '/payments', page: () => const PaymentsHubView()),
          GetPage(
            name: '/payments/receive',
            page: () => const ReceivePaymentView(),
          ),
          GetPage(
            name: '/payments/:orderId/receipt',
            page: () => ReceiptView(orderId: Get.parameters['orderId']!),
          ),
          GetPage(name: '/calendar', page: () => const CalendarView()),
          GetPage(name: '/reports', page: () => const ReportsView()),
          GetPage(
            name: '/notifications',
            page: () => const NotificationsView(),
          ),
          GetPage(name: '/profile', page: () => const ProfileView()),
          GetPage(name: '/shop-settings', page: () => const ShopSettingsView()),
          GetPage(
            name: '/change-password',
            page: () => const ChangePasswordView(),
          ),
          GetPage(name: '/settings', page: () => const SettingsView()),
          GetPage(
            name: '/tasks',
            page: () => const ModulePlaceholderView(
              title: 'Tasks & production',
              backendGap:
                  'No production-task tables/APIs yet. Order assignment uses assignedToId only.',
            ),
          ),
          GetPage(
            name: '/worker-payments',
            page: () => const ModulePlaceholderView(
              title: 'Worker payments',
              backendGap:
                  'No worker payment ledger in Prisma/API. Customer payments on orders exist.',
            ),
          ),
          GetPage(
            name: '/expenses',
            page: () => const ModulePlaceholderView(
              title: 'Expenses',
              backendGap: 'Expense module is not in the Nest/Prisma schema yet.',
            ),
          ),
          GetPage(
            name: '/inventory',
            page: () => const ModulePlaceholderView(
              title: 'Inventory',
              backendGap:
                  'Inventory items and stock movements are not implemented on the backend yet.',
            ),
          ),
          GetPage(
            name: '/gallery',
            page: () => const ModulePlaceholderView(
              title: 'Stitch gallery',
              backendGap:
                  'Design gallery / media library APIs are not implemented yet.',
            ),
          ),
        ],
      );
    });
  }
}
