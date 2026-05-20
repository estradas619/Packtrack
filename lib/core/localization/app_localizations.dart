import 'dart:async';
import 'package:flutter/material.dart';

/// Custom localization class that provides translated strings for the app.
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // ─── Translation Maps ──────────────────────────────────────────────────────

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // General
      'app_name': 'PackTrack',
      'loading': 'Loading...',
      'error': 'Error',
      'retry': 'Retry',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'delete': 'Delete',
      'save': 'Save',
      'close': 'Close',
      'search': 'Search',
      'no_results': 'No results found',
      'settings': 'Settings',
      'learn_more': 'Learn More',

      // Home Screen
      'home_title': 'My Packages',
      'search_hint': 'Paste tracking number or scan code',
      'scan_code': 'Scan',
      'arriving_today': 'Arriving Today',
      'active_shipments': 'Active Shipments',
      'delivered': 'Delivered',
      'all_orders': 'All Orders',
      'no_packages': 'No packages yet',
      'no_packages_subtitle': 'Add a tracking number to get started',
      'add_package': 'Add Package',
      'refresh': 'Refresh',

      // Map
      'map_title': 'Live Tracking',
      'nearest_delivery': 'Nearest Delivery',
      'estimated_arrival': 'Estimated Arrival',
      'today': 'Today',
      'tomorrow': 'Tomorrow',

      // Package Status
      'status_pending': 'Pending',
      'status_in_transit': 'In Transit',
      'status_in_customs': 'In Customs',
      'status_out_for_delivery': 'Out for Delivery',
      'status_delivered': 'Delivered',
      'status_exception': 'Exception',
      'status_unknown': 'Unknown',

      // Detail Screen
      'package_detail': 'Package Detail',
      'tracking_number': 'Tracking Number',
      'carrier': 'Carrier',
      'origin': 'Origin',
      'destination': 'Destination',
      'estimated_delivery': 'Estimated Delivery',
      'actual_delivery': 'Actual Delivery',
      'timeline': 'Timeline',
      'share_status': 'Share Status',
      'share_message': 'My package ({tracking}) via {carrier} is currently: {status}. Track it here: {link}',
      'copy_tracking': 'Copy Tracking Number',
      'copied': 'Copied to clipboard',

      // Orders
      'order': 'Order',
      'packages_count': '{count} package(s)',
      'order_date': 'Order Date',

      // Search History
      'search_history': 'Search History',
      'clear_history': 'Clear History',
      'recent_searches': 'Recent Searches',

      // Carrier Detection
      'carrier_detected': 'Carrier detected: {carrier}',
      'carrier_unknown': 'Carrier not detected',
      'select_carrier': 'Select Carrier',

      // Settings
      'language': 'Language',
      'notifications': 'Notifications',
      'dark_mode': 'Dark Mode',
      'about': 'About',
      'version': 'Version',
      'privacy_policy': 'Privacy Policy',
      'terms_of_service': 'Terms of Service',

      // Auth
      'welcome_subtitle': 'Track all your packages in one place',
      'welcome_feature_scan': 'Scan or paste any tracking number instantly',
      'welcome_feature_map': 'See your packages on a live map',
      'welcome_feature_notify': 'Get notified when packages arrive',
      'create_account': 'Create Account',
      'sign_in': 'Sign In',
      'sign_out': 'Sign Out',
      'sign_out_confirm': 'Sign Out?',
      'sign_out_message': 'Are you sure you want to sign out?',
      'welcome_back': 'Welcome Back',
      'sign_in_subtitle': 'Sign in to access your tracked packages',
      'register_subtitle': 'Start tracking your packages today',
      'email_hint': 'Email address',
      'password_hint': 'Password',
      'name_hint': 'Full name',
      'email_required': 'Email is required',
      'email_invalid': 'Please enter a valid email',
      'password_required': 'Password is required',
      'password_too_short': 'Password must be at least 6 characters',
      'name_required': 'Name is required',
      'forgot_password': 'Forgot password?',
      'or_continue_with': 'or continue with',
      'terms_agreement': 'By creating an account, you agree to our Terms of Service and Privacy Policy.',

      // Contact Carrier
      'contact_carrier': 'Contact Carrier',
      'contact_carrier_inactive': 'Activates after 48h without movement',
      'stuck_hours': 'No movement for {hours}h',
      'carrier_contact_unavailable': 'Contact info not available for this carrier',
      'contact_carrier_title': 'Contact Support',
      'contact_carrier_desc': 'Call {carrier} customer service. Your tracking number will be copied automatically.',
      'phone_number': 'Phone',
      'tracking_copied_note': 'Tracking number will be copied to your clipboard before calling',
      'call_now': 'Call Now',
      'visit_website': 'Website',

      // Extras & Monetization
      'extras_title': 'Extras',
      'extras_subtitle': 'Optional tools and services to enhance your experience',
      'premium_title': 'PackTrack Premium',
      'premium_active': 'Active subscription',
      'premium_price': '\$4.99/mo',
      'premium_feature_1': 'Unlimited package tracking',
      'premium_feature_2': 'Priority push notifications',
      'premium_feature_3': 'Advanced delivery analytics',
      'premium_feature_4': 'Ad-free experience forever',
      'subscribe_now': 'Subscribe Now',

      // Insurance
      'insurance_title': 'Package Insurance',
      'insurance_subtitle': 'Protect your valuable shipments',
      'insurance_basic': 'Basic',
      'insurance_standard': 'Standard',
      'insurance_premium': 'Premium',
      'insurance_info': 'Coverage applies from the moment you insure until delivery confirmation.',

      // Affiliate
      'affiliate_title': 'Partner Offers',
      'affiliate_subtitle': 'Exclusive deals from our partners',
      'affiliate_offer_1_title': 'Packing Supplies',
      'affiliate_offer_1_desc': 'Premium boxes and materials',
      'affiliate_offer_2_title': 'Smart Locks',
      'affiliate_offer_2_desc': 'Secure your deliveries',
      'affiliate_offer_3_title': 'E-commerce Tools',
      'affiliate_offer_3_desc': 'Manage your online store',

      // Partnerships
      'partnerships_title': 'Carrier Discounts',
      'partnerships_subtitle': 'Ship for less with our partners',
      'partnerships_info': 'Get exclusive shipping rates when you send packages through our partner carriers.',

      // Analytics
      'analytics_title': 'Business Analytics',
      'analytics_subtitle': 'For e-commerce and power users',
      'analytics_metric_1': 'Avg. Delivery Time',
      'analytics_metric_2': 'On-Time Rate',
      'analytics_metric_3': 'Best Carrier',
      'analytics_metric_4': 'Exception Rate',
      'analytics_features': 'Included features:',
      'analytics_feature_1': 'Carrier performance comparison',
      'analytics_feature_2': 'Delivery time predictions',
      'analytics_feature_3': 'Monthly reports & CSV export',
      'analytics_cta': 'Start Free Trial',
    },
    'es': {
      // General
      'app_name': 'PackTrack',
      'loading': 'Cargando...',
      'error': 'Error',
      'retry': 'Reintentar',
      'cancel': 'Cancelar',
      'confirm': 'Confirmar',
      'delete': 'Eliminar',
      'save': 'Guardar',
      'close': 'Cerrar',
      'search': 'Buscar',
      'no_results': 'Sin resultados',
      'settings': 'Configuración',
      'learn_more': 'Saber Más',

      // Home Screen
      'home_title': 'Mis Paquetes',
      'search_hint': 'Pega número de guía o escanea código',
      'scan_code': 'Escanear',
      'arriving_today': 'Llega Hoy',
      'active_shipments': 'Envíos Activos',
      'delivered': 'Entregados',
      'all_orders': 'Todos los Pedidos',
      'no_packages': 'Sin paquetes aún',
      'no_packages_subtitle': 'Agrega un número de guía para comenzar',
      'add_package': 'Agregar Paquete',
      'refresh': 'Actualizar',

      // Map
      'map_title': 'Rastreo en Vivo',
      'nearest_delivery': 'Entrega Más Cercana',
      'estimated_arrival': 'Llegada Estimada',
      'today': 'Hoy',
      'tomorrow': 'Mañana',

      // Package Status
      'status_pending': 'Pendiente',
      'status_in_transit': 'En Tránsito',
      'status_in_customs': 'En Aduana',
      'status_out_for_delivery': 'En Ruta de Entrega',
      'status_delivered': 'Entregado',
      'status_exception': 'Excepción',
      'status_unknown': 'Desconocido',

      // Detail Screen
      'package_detail': 'Detalle del Paquete',
      'tracking_number': 'Número de Guía',
      'carrier': 'Transportista',
      'origin': 'Origen',
      'destination': 'Destino',
      'estimated_delivery': 'Entrega Estimada',
      'actual_delivery': 'Entrega Real',
      'timeline': 'Línea de Tiempo',
      'share_status': 'Compartir Estado',
      'share_message': 'Mi paquete ({tracking}) vía {carrier} está: {status}. Rastréalo aquí: {link}',
      'copy_tracking': 'Copiar Número de Guía',
      'copied': 'Copiado al portapapeles',

      // Orders
      'order': 'Pedido',
      'packages_count': '{count} paquete(s)',
      'order_date': 'Fecha del Pedido',

      // Search History
      'search_history': 'Historial de Búsqueda',
      'clear_history': 'Borrar Historial',
      'recent_searches': 'Búsquedas Recientes',

      // Carrier Detection
      'carrier_detected': 'Transportista detectado: {carrier}',
      'carrier_unknown': 'Transportista no detectado',
      'select_carrier': 'Seleccionar Transportista',

      // Settings
      'language': 'Idioma',
      'notifications': 'Notificaciones',
      'dark_mode': 'Modo Oscuro',
      'about': 'Acerca de',
      'version': 'Versión',
      'privacy_policy': 'Política de Privacidad',
      'terms_of_service': 'Términos de Servicio',

      // Auth
      'welcome_subtitle': 'Rastrea todos tus paquetes en un solo lugar',
      'welcome_feature_scan': 'Escanea o pega cualquier número de guía al instante',
      'welcome_feature_map': 'Ve tus paquetes en un mapa en tiempo real',
      'welcome_feature_notify': 'Recibe notificaciones cuando lleguen tus paquetes',
      'create_account': 'Crear Cuenta',
      'sign_in': 'Iniciar Sesión',
      'sign_out': 'Cerrar Sesión',
      'sign_out_confirm': '¿Cerrar Sesión?',
      'sign_out_message': '¿Estás seguro de que quieres cerrar sesión?',
      'welcome_back': 'Bienvenido de Vuelta',
      'sign_in_subtitle': 'Inicia sesión para acceder a tus paquetes rastreados',
      'register_subtitle': 'Comienza a rastrear tus paquetes hoy',
      'email_hint': 'Correo electrónico',
      'password_hint': 'Contraseña',
      'name_hint': 'Nombre completo',
      'email_required': 'El correo es obligatorio',
      'email_invalid': 'Ingresa un correo válido',
      'password_required': 'La contraseña es obligatoria',
      'password_too_short': 'La contraseña debe tener al menos 6 caracteres',
      'name_required': 'El nombre es obligatorio',
      'forgot_password': '¿Olvidaste tu contraseña?',
      'or_continue_with': 'o continúa con',
      'terms_agreement': 'Al crear una cuenta, aceptas nuestros Términos de Servicio y Política de Privacidad.',

      // Contact Carrier
      'contact_carrier': 'Contactar a la Paquetería',
      'contact_carrier_inactive': 'Se activa tras 48h sin movimiento',
      'stuck_hours': 'Sin movimiento por {hours}h',
      'carrier_contact_unavailable': 'Información de contacto no disponible para este transportista',
      'contact_carrier_title': 'Contactar Soporte',
      'contact_carrier_desc': 'Llama al servicio al cliente de {carrier}. Tu número de guía se copiará automáticamente.',
      'phone_number': 'Teléfono',
      'tracking_copied_note': 'El número de guía se copiará al portapapeles antes de llamar',
      'call_now': 'Llamar Ahora',
      'visit_website': 'Sitio Web',

      // Extras & Monetization
      'extras_title': 'Extras',
      'extras_subtitle': 'Herramientas y servicios opcionales para mejorar tu experiencia',
      'premium_title': 'PackTrack Premium',
      'premium_active': 'Suscripción activa',
      'premium_price': '\$4.99/mes',
      'premium_feature_1': 'Rastreo ilimitado de paquetes',
      'premium_feature_2': 'Notificaciones push prioritarias',
      'premium_feature_3': 'Analítica avanzada de entregas',
      'premium_feature_4': 'Sin publicidad para siempre',
      'subscribe_now': 'Suscribirse Ahora',

      // Insurance
      'insurance_title': 'Seguro de Paquetes',
      'insurance_subtitle': 'Protege tus envíos valiosos',
      'insurance_basic': 'Básico',
      'insurance_standard': 'Estándar',
      'insurance_premium': 'Premium',
      'insurance_info': 'La cobertura aplica desde el momento que aseguras hasta la confirmación de entrega.',

      // Affiliate
      'affiliate_title': 'Ofertas de Socios',
      'affiliate_subtitle': 'Descuentos exclusivos de nuestros socios',
      'affiliate_offer_1_title': 'Material de Empaque',
      'affiliate_offer_1_desc': 'Cajas y materiales premium',
      'affiliate_offer_2_title': 'Cerraduras Inteligentes',
      'affiliate_offer_2_desc': 'Asegura tus entregas',
      'affiliate_offer_3_title': 'Herramientas E-commerce',
      'affiliate_offer_3_desc': 'Gestiona tu tienda en línea',

      // Partnerships
      'partnerships_title': 'Descuentos con Transportistas',
      'partnerships_subtitle': 'Envía por menos con nuestros socios',
      'partnerships_info': 'Obtén tarifas exclusivas de envío cuando envíes paquetes a través de nuestros transportistas aliados.',

      // Analytics
      'analytics_title': 'Analítica para Negocios',
      'analytics_subtitle': 'Para e-commerce y usuarios avanzados',
      'analytics_metric_1': 'Tiempo Promedio de Entrega',
      'analytics_metric_2': 'Tasa de Puntualidad',
      'analytics_metric_3': 'Mejor Transportista',
      'analytics_metric_4': 'Tasa de Excepciones',
      'analytics_features': 'Funciones incluidas:',
      'analytics_feature_1': 'Comparación de rendimiento de transportistas',
      'analytics_feature_2': 'Predicciones de tiempo de entrega',
      'analytics_feature_3': 'Reportes mensuales y exportación CSV',
      'analytics_cta': 'Iniciar Prueba Gratis',
    },
    'pt': {
      // General
      'app_name': 'PackTrack',
      'loading': 'Carregando...',
      'error': 'Erro',
      'retry': 'Tentar novamente',
      'cancel': 'Cancelar',
      'confirm': 'Confirmar',
      'delete': 'Excluir',
      'save': 'Salvar',
      'close': 'Fechar',
      'search': 'Buscar',
      'no_results': 'Nenhum resultado encontrado',
      'settings': 'Configurações',
      'learn_more': 'Saiba Mais',

      // Home Screen
      'home_title': 'Meus Pacotes',
      'search_hint': 'Cole o número de rastreio ou escaneie',
      'scan_code': 'Escanear',
      'arriving_today': 'Chega Hoje',
      'active_shipments': 'Envios Ativos',
      'delivered': 'Entregues',
      'all_orders': 'Todos os Pedidos',
      'no_packages': 'Nenhum pacote ainda',
      'no_packages_subtitle': 'Adicione um número de rastreio para começar',
      'add_package': 'Adicionar Pacote',
      'refresh': 'Atualizar',

      // Map
      'map_title': 'Rastreio ao Vivo',
      'nearest_delivery': 'Entrega Mais Próxima',
      'estimated_arrival': 'Chegada Estimada',
      'today': 'Hoje',
      'tomorrow': 'Amanhã',

      // Package Status
      'status_pending': 'Pendente',
      'status_in_transit': 'Em Trânsito',
      'status_in_customs': 'Na Alfândega',
      'status_out_for_delivery': 'Saiu para Entrega',
      'status_delivered': 'Entregue',
      'status_exception': 'Exceção',
      'status_unknown': 'Desconhecido',

      // Detail Screen
      'package_detail': 'Detalhe do Pacote',
      'tracking_number': 'Número de Rastreio',
      'carrier': 'Transportadora',
      'origin': 'Origem',
      'destination': 'Destino',
      'estimated_delivery': 'Entrega Estimada',
      'actual_delivery': 'Entrega Real',
      'timeline': 'Linha do Tempo',
      'share_status': 'Compartilhar Status',
      'share_message': 'Meu pacote ({tracking}) via {carrier} está: {status}. Rastreie aqui: {link}',
      'copy_tracking': 'Copiar Número de Rastreio',
      'copied': 'Copiado para a área de transferência',

      // Orders
      'order': 'Pedido',
      'packages_count': '{count} pacote(s)',
      'order_date': 'Data do Pedido',

      // Search History
      'search_history': 'Histórico de Busca',
      'clear_history': 'Limpar Histórico',
      'recent_searches': 'Buscas Recentes',

      // Carrier Detection
      'carrier_detected': 'Transportadora detectada: {carrier}',
      'carrier_unknown': 'Transportadora não detectada',
      'select_carrier': 'Selecionar Transportadora',

      // Settings
      'language': 'Idioma',
      'notifications': 'Notificações',
      'dark_mode': 'Modo Escuro',
      'about': 'Sobre',
      'version': 'Versão',
      'privacy_policy': 'Política de Privacidade',
      'terms_of_service': 'Termos de Serviço',

      // Auth
      'welcome_subtitle': 'Rastreie todos os seus pacotes em um só lugar',
      'welcome_feature_scan': 'Escaneie ou cole qualquer número de rastreio',
      'welcome_feature_map': 'Veja seus pacotes em um mapa ao vivo',
      'welcome_feature_notify': 'Receba notificações quando seus pacotes chegarem',
      'create_account': 'Criar Conta',
      'sign_in': 'Entrar',
      'sign_out': 'Sair',
      'sign_out_confirm': 'Sair?',
      'sign_out_message': 'Tem certeza que deseja sair?',
      'welcome_back': 'Bem-vindo de Volta',
      'sign_in_subtitle': 'Entre para acessar seus pacotes rastreados',
      'register_subtitle': 'Comece a rastrear seus pacotes hoje',
      'email_hint': 'Endereço de e-mail',
      'password_hint': 'Senha',
      'name_hint': 'Nome completo',
      'email_required': 'E-mail é obrigatório',
      'email_invalid': 'Digite um e-mail válido',
      'password_required': 'Senha é obrigatória',
      'password_too_short': 'A senha deve ter pelo menos 6 caracteres',
      'name_required': 'Nome é obrigatório',
      'forgot_password': 'Esqueceu a senha?',
      'or_continue_with': 'ou continue com',
      'terms_agreement': 'Ao criar uma conta, você concorda com nossos Termos de Serviço e Política de Privacidade.',

      // Contact Carrier
      'contact_carrier': 'Contatar Transportadora',
      'contact_carrier_inactive': 'Ativa após 48h sem movimentação',
      'stuck_hours': 'Sem movimentação por {hours}h',
      'carrier_contact_unavailable': 'Informações de contato indisponíveis para esta transportadora',
      'contact_carrier_title': 'Contatar Suporte',
      'contact_carrier_desc': 'Ligue para o atendimento ao cliente da {carrier}. Seu número de rastreio será copiado automaticamente.',
      'phone_number': 'Telefone',
      'tracking_copied_note': 'O número de rastreio será copiado antes de ligar',
      'call_now': 'Ligar Agora',
      'visit_website': 'Site',

      // Extras & Monetization
      'extras_title': 'Extras',
      'extras_subtitle': 'Ferramentas e serviços opcionais para melhorar sua experiência',
      'premium_title': 'PackTrack Premium',
      'premium_active': 'Assinatura ativa',
      'premium_price': '\$4.99/mês',
      'premium_feature_1': 'Rastreio ilimitado de pacotes',
      'premium_feature_2': 'Notificações push prioritárias',
      'premium_feature_3': 'Análise avançada de entregas',
      'premium_feature_4': 'Sem anúncios para sempre',
      'subscribe_now': 'Assinar Agora',

      // Insurance
      'insurance_title': 'Seguro de Pacotes',
      'insurance_subtitle': 'Proteja seus envios valiosos',
      'insurance_basic': 'Básico',
      'insurance_standard': 'Padrão',
      'insurance_premium': 'Premium',
      'insurance_info': 'A cobertura se aplica desde o momento que você assegura até a confirmação de entrega.',

      // Affiliate
      'affiliate_title': 'Ofertas de Parceiros',
      'affiliate_subtitle': 'Descontos exclusivos dos nossos parceiros',
      'affiliate_offer_1_title': 'Material de Embalagem',
      'affiliate_offer_1_desc': 'Caixas e materiais premium',
      'affiliate_offer_2_title': 'Fechaduras Inteligentes',
      'affiliate_offer_2_desc': 'Proteja suas entregas',
      'affiliate_offer_3_title': 'Ferramentas E-commerce',
      'affiliate_offer_3_desc': 'Gerencie sua loja online',

      // Partnerships
      'partnerships_title': 'Descontos com Transportadoras',
      'partnerships_subtitle': 'Envie por menos com nossos parceiros',
      'partnerships_info': 'Obtenha tarifas exclusivas de envio quando enviar pacotes através das nossas transportadoras parceiras.',

      // Analytics
      'analytics_title': 'Análise para Negócios',
      'analytics_subtitle': 'Para e-commerce e usuários avançados',
      'analytics_metric_1': 'Tempo Médio de Entrega',
      'analytics_metric_2': 'Taxa de Pontualidade',
      'analytics_metric_3': 'Melhor Transportadora',
      'analytics_metric_4': 'Taxa de Exceções',
      'analytics_features': 'Funcionalidades incluídas:',
      'analytics_feature_1': 'Comparação de desempenho de transportadoras',
      'analytics_feature_2': 'Previsões de tempo de entrega',
      'analytics_feature_3': 'Relatórios mensais e exportação CSV',
      'analytics_cta': 'Iniciar Teste Grátis',
    },
    'fr': {
      'app_name': 'PackTrack',
      'loading': 'Chargement...',
      'home_title': 'Mes Colis',
      'search_hint': 'Collez le numéro de suivi ou scannez',
      'scan_code': 'Scanner',
      'arriving_today': 'Arrive Aujourd\'hui',
      'active_shipments': 'Envois Actifs',
      'delivered': 'Livrés',
      'all_orders': 'Toutes les Commandes',
      'status_pending': 'En Attente',
      'status_in_transit': 'En Transit',
      'status_in_customs': 'En Douane',
      'status_out_for_delivery': 'En Cours de Livraison',
      'status_delivered': 'Livré',
      'status_exception': 'Exception',
      'status_unknown': 'Inconnu',
      'package_detail': 'Détail du Colis',
      'tracking_number': 'Numéro de Suivi',
      'carrier': 'Transporteur',
      'timeline': 'Chronologie',
      'share_status': 'Partager le Statut',
      'language': 'Langue',
      'settings': 'Paramètres',
      'learn_more': 'En Savoir Plus',
      'create_account': 'Créer un Compte',
      'sign_in': 'Se Connecter',
      'sign_out': 'Se Déconnecter',
      'welcome_subtitle': 'Suivez tous vos colis en un seul endroit',
      'contact_carrier': 'Contacter le Transporteur',
      'extras_title': 'Extras',
      'premium_title': 'PackTrack Premium',
      'subscribe_now': 'S\'abonner',
      'cancel': 'Annuler',
    },
    'de': {
      'app_name': 'PackTrack',
      'loading': 'Laden...',
      'home_title': 'Meine Pakete',
      'search_hint': 'Sendungsnummer einfügen oder scannen',
      'scan_code': 'Scannen',
      'arriving_today': 'Kommt Heute',
      'active_shipments': 'Aktive Sendungen',
      'delivered': 'Zugestellt',
      'all_orders': 'Alle Bestellungen',
      'status_pending': 'Ausstehend',
      'status_in_transit': 'Unterwegs',
      'status_in_customs': 'Im Zoll',
      'status_out_for_delivery': 'In Zustellung',
      'status_delivered': 'Zugestellt',
      'status_exception': 'Ausnahme',
      'status_unknown': 'Unbekannt',
      'package_detail': 'Paketdetails',
      'tracking_number': 'Sendungsnummer',
      'carrier': 'Spediteur',
      'timeline': 'Zeitachse',
      'share_status': 'Status Teilen',
      'language': 'Sprache',
      'settings': 'Einstellungen',
      'learn_more': 'Mehr Erfahren',
      'create_account': 'Konto Erstellen',
      'sign_in': 'Anmelden',
      'sign_out': 'Abmelden',
      'welcome_subtitle': 'Verfolgen Sie alle Ihre Pakete an einem Ort',
      'contact_carrier': 'Spediteur Kontaktieren',
      'extras_title': 'Extras',
      'premium_title': 'PackTrack Premium',
      'subscribe_now': 'Jetzt Abonnieren',
      'cancel': 'Abbrechen',
    },
  };

  // ─── Translation Method ────────────────────────────────────────────────────

  String translate(String key, {Map<String, String>? params}) {
    final langCode = locale.languageCode;
    String? value = _localizedValues[langCode]?[key];

    // Fallback to English
    value ??= _localizedValues['en']?[key] ?? key;

    // Replace parameters
    if (params != null) {
      params.forEach((paramKey, paramValue) {
        value = value!.replaceAll('{$paramKey}', paramValue);
      });
    }

    return value!;
  }

  // ─── Convenience Getters ───────────────────────────────────────────────────

  String get appName => translate('app_name');
  String get loading => translate('loading');
  String get homeTitle => translate('home_title');
  String get searchHint => translate('search_hint');
  String get scanCode => translate('scan_code');
  String get arrivingToday => translate('arriving_today');
  String get activeShipments => translate('active_shipments');
  String get deliveredText => translate('delivered');
  String get allOrders => translate('all_orders');
  String get noPackages => translate('no_packages');
  String get noPackagesSubtitle => translate('no_packages_subtitle');
  String get mapTitle => translate('map_title');
  String get nearestDelivery => translate('nearest_delivery');
  String get estimatedArrival => translate('estimated_arrival');
  String get packageDetail => translate('package_detail');
  String get trackingNumber => translate('tracking_number');
  String get carrier => translate('carrier');
  String get origin => translate('origin');
  String get destination => translate('destination');
  String get estimatedDelivery => translate('estimated_delivery');
  String get timeline => translate('timeline');
  String get shareStatus => translate('share_status');
  String get copyTracking => translate('copy_tracking');
  String get copied => translate('copied');
  String get searchHistory => translate('search_history');
  String get clearHistory => translate('clear_history');
  String get recentSearches => translate('recent_searches');
  String get language => translate('language');
  String get settings => translate('settings');
  String get today => translate('today');
  String get tomorrow => translate('tomorrow');

  String statusText(String statusKey) => translate('status_$statusKey');
}

/// Delegate for loading AppLocalizations.
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es', 'pt', 'fr', 'de'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
