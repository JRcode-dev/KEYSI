import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('es'), // Español
    Locale('en'), // Inglés
    Locale('hi'), // Hindi
    Locale('ar'), // Árabe
    Locale('bn'), // Bengalí
    Locale('zh'), // Chino
  ];

  static final Map<String, Map<String, String>> _translations = {
    'es': {
      'app_name': 'Vivra',
      'login': 'Iniciar Sesión',
      'register': 'Registrarse',
      'email': 'Correo electrónico',
      'password': 'Contraseña',
      'username': 'Nombre de usuario',
      'forgot_password': '¿Olvidaste tu contraseña?',
      'no_account': '¿No tienes cuenta?',
      'have_account': '¿Ya tienes cuenta?',
      'logout': 'Cerrar sesión',
      'profile': 'Perfil',
      'settings': 'Configuración',
      'rooms': 'Salas',
      'moments': 'Momentos',
      'messages': 'Mensajes',
      'wallet': 'Billetera',
      'ranking': 'Ranking',
      'followers': 'Seguidores',
      'following': 'Siguiendo',
      'friends': 'Amigos',
      'follow': 'Seguir',
      'unfollow': 'Dejar de seguir',
      'send_gift': 'Enviar regalo',
      'lucky_gift': 'Lucky Gift',
      'coins': 'Monedas',
      'diamonds': 'Diamantes',
      'recharge': 'Recargar',
      'withdraw': 'Retirar',
      'balance': 'Balance',
      'send_message': 'Enviar mensaje',
      'create_room': 'Crear sala',
      'join_room': 'Unirse a sala',
      'leave_room': 'Salir de sala',
      'seats': 'Asientos',
      'hot_rooms': 'Salas populares',
      'global_rooms': 'Salas globales',
      'recent_rooms': 'Salas recientes',
      'mute': 'Silenciar',
      'unmute': 'Activar micrófono',
      'daily_tasks': 'Tareas diarias',
      'level': 'Nivel',
      'title': 'Título',
      'bio': 'Biografía',
      'edit_profile': 'Editar perfil',
      'cancel': 'Cancelar',
      'save': 'Guardar',
      'delete': 'Eliminar',
      'confirm': 'Confirmar',
      'error': 'Error',
      'success': 'Éxito',
      'loading': 'Cargando...',
      'no_data': 'Sin datos',
      'retry': 'Reintentar',
    },
    'en': {
      'app_name': 'Vivra',
      'login': 'Login',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'username': 'Username',
      'forgot_password': 'Forgot password?',
      'no_account': "Don't have an account?",
      'have_account': 'Already have an account?',
      'logout': 'Logout',
      'profile': 'Profile',
      'settings': 'Settings',
      'rooms': 'Rooms',
      'moments': 'Moments',
      'messages': 'Messages',
      'wallet': 'Wallet',
      'ranking': 'Ranking',
      'followers': 'Followers',
      'following': 'Following',
      'friends': 'Friends',
      'follow': 'Follow',
      'unfollow': 'Unfollow',
      'send_gift': 'Send gift',
      'lucky_gift': 'Lucky Gift',
      'coins': 'Coins',
      'diamonds': 'Diamonds',
      'recharge': 'Recharge',
      'withdraw': 'Withdraw',
      'balance': 'Balance',
      'send_message': 'Send message',
      'create_room': 'Create room',
      'join_room': 'Join room',
      'leave_room': 'Leave room',
      'seats': 'Seats',
      'hot_rooms': 'Hot rooms',
      'global_rooms': 'Global rooms',
      'recent_rooms': 'Recent rooms',
      'mute': 'Mute',
      'unmute': 'Unmute',
      'daily_tasks': 'Daily tasks',
      'level': 'Level',
      'title': 'Title',
      'bio': 'Bio',
      'edit_profile': 'Edit profile',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'confirm': 'Confirm',
      'error': 'Error',
      'success': 'Success',
      'loading': 'Loading...',
      'no_data': 'No data',
      'retry': 'Retry',
    },
    'hi': {
      'app_name': 'Vivra',
      'login': 'लॉग इन',
      'register': 'रजिस्टर',
      'email': 'ईमेल',
      'password': 'पासवर्ड',
      'username': 'उपयोगकर्ता नाम',
      'forgot_password': 'पासवर्ड भूल गए?',
      'no_account': 'खाता नहीं है?',
      'have_account': 'पहले से खाता है?',
      'logout': 'लॉग आउट',
      'profile': 'प्रोफ़ाइल',
      'settings': 'सेटिंग्स',
      'rooms': 'कमरे',
      'moments': 'पल',
      'messages': 'संदेश',
      'wallet': 'वॉलेट',
      'ranking': 'रैंकिंग',
      'followers': 'अनुयायी',
      'following': 'अनुसरण',
      'friends': 'दोस्त',
      'follow': 'फॉलो',
      'unfollow': 'अनफॉलो',
      'send_gift': 'उपहार भेजें',
      'lucky_gift': 'लकी गिफ्ट',
      'coins': 'सिक्के',
      'diamonds': 'हीरे',
      'recharge': 'रिचार्ज',
      'withdraw': 'निकालें',
      'balance': 'बैलेंस',
      'send_message': 'संदेश भेजें',
      'create_room': 'कमरा बनाएं',
      'join_room': 'कमरे में शामिल हों',
      'leave_room': 'कमरा छोड़ें',
      'seats': 'सीटें',
      'hot_rooms': 'लोकप्रिय कमरे',
      'global_rooms': 'वैश्विक कमरे',
      'recent_rooms': 'हाल के कमरे',
      'mute': 'म्यूट',
      'unmute': 'अनम्यूट',
      'daily_tasks': 'दैनिक कार्य',
      'level': 'स्तर',
      'title': 'शीर्षक',
      'bio': 'जीवनी',
      'edit_profile': 'प्रोफ़ाइल संपादित करें',
      'cancel': 'रद्द करें',
      'save': 'सहेजें',
      'delete': 'हटाएं',
      'confirm': 'पुष्टि करें',
      'error': 'त्रुटि',
      'success': 'सफलता',
      'loading': 'लोड हो रहा है...',
      'no_data': 'कोई डेटा नहीं',
      'retry': 'पुनः प्रयास',
    },
    'ar': {
      'app_name': 'Vivra',
      'login': 'تسجيل الدخول',
      'register': 'التسجيل',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'username': 'اسم المستخدم',
      'forgot_password': 'نسيت كلمة المرور؟',
      'no_account': 'ليس لديك حساب؟',
      'have_account': 'لديك حساب بالفعل؟',
      'logout': 'تسجيل الخروج',
      'profile': 'الملف الشخصي',
      'settings': 'الإعدادات',
      'rooms': 'الغرف',
      'moments': 'اللحظات',
      'messages': 'الرسائل',
      'wallet': 'المحفظة',
      'ranking': 'التصنيف',
      'followers': 'المتابعون',
      'following': 'المتابَعون',
      'friends': 'الأصدقاء',
      'follow': 'متابعة',
      'unfollow': 'إلغاء المتابعة',
      'send_gift': 'إرسال هدية',
      'lucky_gift': 'هدية محظوظة',
      'coins': 'عملات',
      'diamonds': 'الماس',
      'recharge': 'شحن',
      'withdraw': 'سحب',
      'balance': 'الرصيد',
      'send_message': 'إرسال رسالة',
      'create_room': 'إنشاء غرفة',
      'join_room': 'الانضمام إلى غرفة',
      'leave_room': 'مغادرة الغرفة',
      'seats': 'المقاعد',
      'hot_rooms': 'الغرف الشائعة',
      'global_rooms': 'الغرف العالمية',
      'recent_rooms': 'الغرف الأخيرة',
      'mute': 'كتم الصوت',
      'unmute': 'إلغاء كتم الصوت',
      'daily_tasks': 'المهام اليومية',
      'level': 'المستوى',
      'title': 'اللقب',
      'bio': 'السيرة الذاتية',
      'edit_profile': 'تعديل الملف الشخصي',
      'cancel': 'إلغاء',
      'save': 'حفظ',
      'delete': 'حذف',
      'confirm': 'تأكيد',
      'error': 'خطأ',
      'success': 'نجاح',
      'loading': 'جاري التحميل...',
      'no_data': 'لا توجد بيانات',
      'retry': 'إعادة المحاولة',
    },
    'bn': {
      'app_name': 'Vivra',
      'login': 'লগ ইন',
      'register': 'নিবন্ধন',
      'email': 'ইমেইল',
      'password': 'পাসওয়ার্ড',
      'username': 'ব্যবহারকারীর নাম',
      'forgot_password': 'পাসওয়ার্ড ভুলে গেছেন?',
      'no_account': 'অ্যাকাউন্ট নেই?',
      'have_account': 'ইতিমধ্যে অ্যাকাউন্ট আছে?',
      'logout': 'লগ আউট',
      'profile': 'প্রোফাইল',
      'settings': 'সেটিংস',
      'rooms': 'রুম',
      'moments': 'মুহূর্ত',
      'messages': 'বার্তা',
      'wallet': 'ওয়ালেট',
      'ranking': 'র‍্যাংকিং',
      'followers': 'অনুসরণকারী',
      'following': 'অনুসরণ করছেন',
      'friends': 'বন্ধু',
      'follow': 'অনুসরণ করুন',
      'unfollow': 'আনফলো করুন',
      'send_gift': 'উপহার পাঠান',
      'lucky_gift': 'লাকি গিফট',
      'coins': 'কয়েন',
      'diamonds': 'হীরা',
      'recharge': 'রিচার্জ',
      'withdraw': 'উত্তোলন',
      'balance': 'ব্যালেন্স',
      'send_message': 'বার্তা পাঠান',
      'create_room': 'রুম তৈরি করুন',
      'join_room': 'রুমে যোগ দিন',
      'leave_room': 'রুম ছেড়ে দিন',
      'seats': 'আসন',
      'hot_rooms': 'জনপ্রিয় রুম',
      'global_rooms': 'গ্লোবাল রুম',
      'recent_rooms': 'সাম্প্রতিক রুম',
      'mute': 'মিউট',
      'unmute': 'আনমিউট',
      'daily_tasks': 'দৈনিক কাজ',
      'level': 'স্তর',
      'title': 'শিরোনাম',
      'bio': 'বায়ো',
      'edit_profile': 'প্রোফাইল সম্পাদনা',
      'cancel': 'বাতিল',
      'save': 'সংরক্ষণ',
      'delete': 'মুছুন',
      'confirm': 'নিশ্চিত করুন',
      'error': 'ত্রুটি',
      'success': 'সাফল্য',
      'loading': 'লোড হচ্ছে...',
      'no_data': 'কোন ডেটা নেই',
      'retry': 'পুনরায় চেষ্টা করুন',
    },
    'zh': {
      'app_name': 'Vivra',
      'login': '登录',
      'register': '注册',
      'email': '电子邮件',
      'password': '密码',
      'username': '用户名',
      'forgot_password': '忘记密码？',
      'no_account': '没有账户？',
      'have_account': '已有账户？',
      'logout': '登出',
      'profile': '个人资料',
      'settings': '设置',
      'rooms': '房间',
      'moments': '动态',
      'messages': '消息',
      'wallet': '钱包',
      'ranking': '排行榜',
      'followers': '粉丝',
      'following': '关注',
      'friends': '朋友',
      'follow': '关注',
      'unfollow': '取消关注',
      'send_gift': '送礼物',
      'lucky_gift': '幸运礼物',
      'coins': '金币',
      'diamonds': '钻石',
      'recharge': '充值',
      'withdraw': '提现',
      'balance': '余额',
      'send_message': '发送消息',
      'create_room': '创建房间',
      'join_room': '加入房间',
      'leave_room': '离开房间',
      'seats': '座位',
      'hot_rooms': '热门房间',
      'global_rooms': '全球房间',
      'recent_rooms': '最近房间',
      'mute': '静音',
      'unmute': '取消静音',
      'daily_tasks': '每日任务',
      'level': '等级',
      'title': '称号',
      'bio': '简介',
      'edit_profile': '编辑资料',
      'cancel': '取消',
      'save': '保存',
      'delete': '删除',
      'confirm': '确认',
      'error': '错误',
      'success': '成功',
      'loading': '加载中...',
      'no_data': '没有数据',
      'retry': '重试',
    },
  };

  String translate(String key) {
    return _translations[locale.languageCode]?[key] ??
        _translations['en']?[key] ??
        key;
  }

  String get appName => translate('app_name');
  String get login => translate('login');
  String get register => translate('register');
  String get email => translate('email');
  String get password => translate('password');
  String get username => translate('username');
  String get forgotPassword => translate('forgot_password');
  String get noAccount => translate('no_account');
  String get haveAccount => translate('have_account');
  String get logout => translate('logout');
  String get profile => translate('profile');
  String get settings => translate('settings');
  String get rooms => translate('rooms');
  String get moments => translate('moments');
  String get messages => translate('messages');
  String get wallet => translate('wallet');
  String get ranking => translate('ranking');
  String get followers => translate('followers');
  String get following => translate('following');
  String get friends => translate('friends');
  String get follow => translate('follow');
  String get unfollow => translate('unfollow');
  String get sendGift => translate('send_gift');
  String get luckyGift => translate('lucky_gift');
  String get coins => translate('coins');
  String get diamonds => translate('diamonds');
  String get recharge => translate('recharge');
  String get withdraw => translate('withdraw');
  String get balance => translate('balance');
  String get sendMessage => translate('send_message');
  String get createRoom => translate('create_room');
  String get joinRoom => translate('join_room');
  String get leaveRoom => translate('leave_room');
  String get seats => translate('seats');
  String get hotRooms => translate('hot_rooms');
  String get globalRooms => translate('global_rooms');
  String get recentRooms => translate('recent_rooms');
  String get mute => translate('mute');
  String get unmute => translate('unmute');
  String get dailyTasks => translate('daily_tasks');
  String get level => translate('level');
  String get title => translate('title');
  String get bio => translate('bio');
  String get editProfile => translate('edit_profile');
  String get cancel => translate('cancel');
  String get save => translate('save');
  String get delete => translate('delete');
  String get confirm => translate('confirm');
  String get error => translate('error');
  String get success => translate('success');
  String get loading => translate('loading');
  String get noData => translate('no_data');
  String get retry => translate('retry');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['es', 'en', 'hi', 'ar', 'bn', 'zh']
        .contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}