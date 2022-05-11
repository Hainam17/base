import 'package:flutter/material.dart';
import 'package:vhv_basic/import.dart';
import 'src/color_helper.dart';
import 'src/constants.dart';
import 'src/dart_helper.dart';
import 'src/providers/auth.dart';
import 'src/providers/login_messages.dart';
import 'src/providers/login_theme.dart';
import 'src/regex.dart';
import 'src/widgets/auth_card.dart';
import 'src/widgets/hero_text.dart';
import 'theme.dart';
export 'src/models/login_data.dart';
export 'src/providers/login_messages.dart';
export 'src/providers/login_theme.dart';
import 'package:package_info_plus/package_info_plus.dart';

class _HeaderFixed extends StatefulWidget {
  final String? logoPath;
  final String? logoTag;
  final String? title;
  final String? titleTag;
  final LoginTheme? loginTheme;
  final AuthPageOption? options;
  const _HeaderFixed(
      {Key? key,
        this.logoPath,
        this.logoTag,
        this.title,
        this.titleTag,
        this.loginTheme, this.options})
      : super(key: key);

  @override
  __HeaderFixedState createState() => __HeaderFixedState();
}

class __HeaderFixedState extends State<_HeaderFixed> {
  double _titleOpacity = 0;
  double _widthImage = 0;
  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _widthImage = 220;
          _titleOpacity = 1;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _controller = Provider
        .of<Auth>(context, listen: false);
    Widget logo;
    if((widget.logoPath != null)) {
      logo = ((widget.logoPath != null)
          ? Container(
          constraints: BoxConstraints(maxWidth: 220),
          child: (widget.logoPath!.endsWith('.svg'))?Center(
            child: SvgViewer(
              widget.logoPath!,
              width: widget.options!.logoWidth,
            ),
          ):Container(
            constraints: BoxConstraints(maxWidth: 220),
            child: Center(
              child: ImageViewer(widget.logoPath!,
                width: widget.options!.logoWidth,
              ),
            ),
          )
      )
          : const SizedBox.shrink());
    }else{
      logo = ((widget.logoPath != null)
          ? Container(
        constraints: BoxConstraints(maxWidth: 220),
        child: Center(child: Image.asset(widget.logoPath!, width: widget.options!.logoWidth)),
      )
          : const SizedBox.shrink());
    }
    if (widget.logoTag != null) {
      logo = Hero(
        tag: widget.logoTag!,
        child: logo,
      );
    }
    Widget? title;
    if (widget.titleTag != null && !DartHelper.isNullOrEmpty(widget.title!)) {
      title = HeroText(
        widget.title!.lang(),
        key: kTitleKey,
        tag: widget.titleTag!,
        maxLines: 2,
        largeFontSize: !empty(widget.options!.titleFontSize)?widget.options!.titleFontSize:Theme.of(context).textTheme.headline6!.fontSize,
        smallFontSize: widget.loginTheme!.afterHeroFontSize,
        style: Theme.of(context).textTheme.headline5!.apply(
            color: widget.options!.titleColor??Colors.white,
            fontWeightDelta: widget.options!.fontWeightDelta??0,

        ),
        viewState: ViewState.enlarged,
      );
    } else if (!DartHelper.isNullOrEmpty(widget.title!)) {
      title = Text(
        widget.title??'',
        maxLines: 2,
        key: kTitleKey,
        style: Theme.of(context).textTheme.headline6!.apply(color: Colors.white),
      );
    } else {
      title = null;
    }
    if(_controller.isRecover){
      title = null;
    }
    return Container(
      margin: EdgeInsets.only(bottom: widget.options!.logoSpace??10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AnimatedContainer(
            width: _widthImage,
            duration: Duration(milliseconds: 300),
            child: logo,
          ),
          if (title != null)
            AnimatedOpacity(
              opacity: _titleOpacity,
              duration: Duration(milliseconds: 300),
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: title,
              ),
            )
        ],
      ),
    );
  }
}

class FlutterLogin extends StatefulWidget {
  FlutterLogin({
    Key? key,
    required this.onSignup,
    required this.onLogin,
    this.title = 'LOGIN',
    this.logo,
    this.hideRegister = false,
    this.messages,
    this.theme,
    this.emailValidator,
    this.passwordValidator,
    this.fullNameValidator,
    this.onSubmitAnimationCompleted(bool isLogin)?,
    this.logoTag,
    this.titleTag,
    this.showDebugButtons = false,
    this.forgotPassword,
    this.authMode,
    this.signUpExtra,
    this.header,
    this.headerRegister
  }) : super(key: key);


  final Widget? headerRegister;
  final Widget? header;
  final bool hideRegister;
  final Widget? signUpExtra;

  /// Called when the user hit the submit button when in sign up mode
  final AuthCallback? onSignup;
  final Widget? forgotPassword;

  /// Called when the user hit the submit button when in login mode
  final AuthCallback? onLogin;

  /// The large text above the login [Card], usually the app or company name
  final String? title;

  /// The path to the asset image that will be passed to the `Image.asset()`
  final String? logo;
  final AuthMode? authMode;

  /// Describes all of the labels, text hints, button texts and other auth
  /// descriptions
  final LoginMessages? messages;

  /// FlutterLogin's theme. If not specified, it will use the default theme as
  /// shown in the demo gifs and use the colorsheme in the closest `Theme`
  /// widget
  final LoginTheme? theme;

  /// Email validating logic, Returns an error string to display if the input is
  /// invalid, or null otherwise
  final FormFieldValidator<String>? emailValidator;
  final FormFieldValidator<String>? fullNameValidator;

  /// Same as [emailValidator] but for password
  final FormFieldValidator<String>? passwordValidator;

  /// Called after the submit animation's completed. Put your route transition
  /// logic here. Recommend to use with [logoTag] and [titleTag]
  final Function? onSubmitAnimationCompleted;

  /// Hero tag for logo image. If not specified, it will simply fade out when
  /// changing route
  final String? logoTag;

  /// Hero tag for title text. Need to specify `LoginTheme.beforeHeroFontSize`
  /// and `LoginTheme.afterHeroFontSize` if you want different font size before
  /// and after hero animation
  final String? titleTag;

  /// Display the debug buttons to quickly forward/reverse login animations. In
  /// release mode, this will be overrided to false regardless of the value
  /// passed in
  final bool showDebugButtons;

  static final FormFieldValidator<String> defaultemailValidator = (value) {
    if (value!.isEmpty || !Regex.email.hasMatch(value)) {
      return 'Invalid email!';
    }
    return null;
  };

  static final FormFieldValidator<String> defaultPasswordValidator = (value) {
    if (value!.isEmpty || value.length <= 2) {
      return 'Password is too short!';
    }
    return null;
  };

  @override
  _FlutterLoginState createState() => _FlutterLoginState();
}

class _FlutterLoginState extends State<FlutterLogin>
    with TickerProviderStateMixin {
  final GlobalKey<AuthCardState> authCardKey = GlobalKey();
  static const loadingDuration = const Duration(milliseconds: 400);
  late AnimationController _loadingController;
  late AnimationController _logoController;
  late AnimationController _titleController;
  bool hasRouter = false;
  late AuthPageOption options;

  @override
  void initState() {
    super.initState();

    _loadingController = AnimationController(
      vsync: this,
      duration: loadingDuration,
    )..addStatusListener((status) {
      if (status == AnimationStatus.forward) {
        _logoController.forward();
        _titleController.forward();
      }
      if (status == AnimationStatus.reverse) {
        _logoController.reverse();
        _titleController.reverse();
      }
    });
    _logoController = AnimationController(
      vsync: this,
      duration: loadingDuration,
    );
    _titleController = AnimationController(
      vsync: this,
      duration: loadingDuration,
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _loadingController.forward();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _loadingController.dispose();
    _logoController.dispose();
    _titleController.dispose();
  }

  void _reverseHeaderAnimation() {
    if (widget.logoTag == null) {
      _logoController.reverse();
    }
    if (widget.titleTag == null) {
      _titleController.reverse();
    }
  }

  Widget _buildHeader(double height, LoginTheme loginTheme) {
    return GestureDetector(
      onTap:(factories['loginFeature'] != LoginOption.required)?(){
        goToHome();
      }:null,
      child: _HeaderFixed(
        logoPath: widget.logo,
        logoTag: widget.logoTag,
        title: widget.title!.lang(),
        titleTag: widget.titleTag,
        loginTheme: loginTheme,
        options: options,
      ),
    );
  }

  ThemeData _mergeTheme({ThemeData? theme, LoginTheme? loginTheme}) {
    final originalPrimaryColor = loginTheme!.primaryColor ?? theme!.primaryColor;
    final primaryDarkShades = getDarkShades(originalPrimaryColor);
    final primaryColor = primaryDarkShades.length == 1
        ? lighten(primaryDarkShades.first!)
        : primaryDarkShades.first;
    final primaryColorDark = primaryDarkShades.length >= 3
        ? primaryDarkShades[2]
        : primaryDarkShades.last;
    final accentColor = loginTheme.accentColor ?? theme!.colorScheme.secondary;
    final errorColor = loginTheme.errorColor ?? theme!.errorColor;
    // the background is a dark gradient, force to use white text if detect default black text color
    final isDefaultBlackText = theme!.textTheme.headline3!.color ==
        Typography.blackMountainView.headline3!.color;
    final titleStyle = theme.textTheme.headline3!
        .copyWith(
      color: loginTheme.accentColor ??
          (isDefaultBlackText
              ? Colors.white
              : theme.textTheme.headline3!.color),
      fontSize: loginTheme.beforeHeroFontSize,
      fontWeight: FontWeight.w300,
    )
        .merge(loginTheme.titleStyle);
    final textStyle = theme.textTheme.bodyText1!
        .copyWith(color: Colors.black54)
        .merge(loginTheme.bodyStyle);
    final textFieldStyle = theme.textTheme.subtitle1!
        .copyWith(color: Colors.black.withOpacity(.65), fontSize: 14)
        .merge(loginTheme.textFieldStyle);
    final buttonStyle = theme.textTheme.button!
        .copyWith(color: Colors.white)
        .merge(loginTheme.buttonStyle);
    final cardTheme = loginTheme.cardTheme;
    final inputTheme = loginTheme.inputTheme;
    final buttonTheme = loginTheme.buttonTheme;
    final roundBorderRadius = BorderRadius.circular(100);

    LoginThemeHelper.loginTextStyle = titleStyle;

    return theme.copyWith(
      primaryColor: primaryColor,
      primaryColorDark: primaryColorDark,
      colorScheme: Theme.of(context).colorScheme.copyWith(
        secondary: accentColor
      ),
      errorColor: errorColor,
      cardTheme: theme.cardTheme.copyWith(
        clipBehavior: cardTheme!.clipBehavior,
        color: cardTheme.color ?? theme.cardColor,
        elevation: cardTheme.elevation ?? 12.0,
        margin: cardTheme.margin ?? const EdgeInsets.all(4.0),
        shape: cardTheme.shape ??
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      ),
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        filled: inputTheme.filled,
        fillColor: inputTheme.fillColor ??
            Color.alphaBlend(
              primaryColor!.withOpacity(.07),
              Colors.grey.withOpacity(.04),
            ),
        contentPadding: inputTheme.contentPadding ??
            const EdgeInsets.symmetric(vertical: 4.0),
        errorStyle: inputTheme.errorStyle ?? TextStyle(color: errorColor),
        labelStyle: inputTheme.labelStyle,
        enabledBorder: inputTheme.enabledBorder ??
            inputTheme.border ??
            OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
              borderRadius: roundBorderRadius,
            ),
        focusedBorder: inputTheme.focusedBorder ??
            inputTheme.border ??
            OutlineInputBorder(
              borderSide: BorderSide(color: primaryColor!, width: 1.5),
              borderRadius: roundBorderRadius,
            ),
        errorBorder: inputTheme.errorBorder ??
            inputTheme.border ??
            OutlineInputBorder(
              borderSide: BorderSide(color: errorColor),
              borderRadius: roundBorderRadius,
            ),
        focusedErrorBorder: inputTheme.focusedErrorBorder ??
            inputTheme.border ??
            OutlineInputBorder(
              borderSide: BorderSide(color: errorColor, width: 1.5),
              borderRadius: roundBorderRadius,
            ),
        disabledBorder: inputTheme.enabledBorder ??
            inputTheme.border ??
            OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
              borderRadius: roundBorderRadius,
            ),
      ),
      floatingActionButtonTheme: theme.floatingActionButtonTheme.copyWith(
        backgroundColor: buttonTheme.backgroundColor ?? primaryColor,
        splashColor: buttonTheme.splashColor ?? theme.colorScheme.secondary,
        elevation: buttonTheme.elevation ?? 4.0,
        highlightElevation: buttonTheme.highlightElevation ?? 2.0,
        shape: buttonTheme.shape ?? StadiumBorder(),
      ),
      // put it here because floatingActionButtonTheme doesnt have highlightColor property
      highlightColor:
      loginTheme.buttonTheme.highlightColor ?? theme.highlightColor,
      textTheme: theme.textTheme.copyWith(
        headline4: titleStyle,
        bodyText1: textStyle,
        subtitle1: textFieldStyle,
        button: buttonStyle,
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    options = (authPageOption != null)?authPageOption!():AuthPageOption();
    final loginTheme = widget.theme ?? LoginTheme();
    final theme = _mergeTheme(theme: Theme.of(context), loginTheme: loginTheme);
    final emailValidator =
        widget.emailValidator ?? FlutterLogin.defaultemailValidator;
    final passwordValidator =
        widget.passwordValidator ?? FlutterLogin.defaultPasswordValidator;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: widget.messages ?? LoginMessages(),
        ),
        ChangeNotifierProvider(
          create: (context) => Auth(
            authMode: widget.authMode!,
            onLogin: widget.onLogin,
            onSignup: widget.onSignup,
          ),
        ),
      ],
      child: Scaffold(
        // resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            if(options.secondBackground != null)Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.bottomCenter,
                      image: AssetImage(options.secondBackground!)
                  )
              ),
            ),
            if(options.backgroundBuilder != null)options.backgroundBuilder!(),
            Container(
              margin: (options.extraBottom != null && MediaQuery.of(context).viewInsets.bottom == 0)?EdgeInsets.only(bottom: 25):EdgeInsets.zero,
              decoration: BoxDecoration(
                image: (!empty(options.background))?DecorationImage(
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.topCenter,
                  image: AssetImage(options.background!)
                ):null,
                gradient: (empty(options.background) && (options.backgroundBuilder == null))?LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    loginTheme.pageColorLight ?? theme.primaryColor,
                    loginTheme.pageColorDark ?? theme.primaryColorDark,
                  ]
                ):null,
              ),
              child: Theme(
                data: theme,
                child: AuthCard(
                    key: authCardKey,
                    hideRegister: widget.hideRegister,
                    header: ((factories['loginHeaderOutside'] != null)?factories['loginHeaderOutside']():null)??(widget.header ?? _buildHeader(200, loginTheme)),
                    headerRegister: widget.headerRegister!,
                    //padding: EdgeInsets.only(top: cardTopPosition),
                    loadingController: _loadingController,
                    emailValidator: emailValidator,
                    fullNameValidator: widget.fullNameValidator!,
                    passwordValidator: passwordValidator,
                    onSubmit: _reverseHeaderAnimation,
                    signUpExtra: widget.signUpExtra!,
                    options: options,
                    onSubmitCompleted: (bool isLogin) {
                      if(!hasRouter){
                        hasRouter = true;
                        widget.onSubmitAnimationCompleted!(isLogin);
                      }
                    },
                    forgotPassword: widget.forgotPassword),
              ),
            ),
            if(options.extraBottom != null && MediaQuery.of(context).viewInsets.bottom == 0)
              Consumer<Auth>(
                  builder: (_, _controller, child){
                return options.extraBottom!(_controller.isRecover);
              }),
            if(options.showVersion!
                && MediaQuery.of(context).viewInsets.bottom == 0)FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (_, snapshot){
                  return snapshot.hasData?Align(
                      alignment: Alignment.bottomCenter,
                      child: SafeArea(child: Text('Version ${snapshot.data!.version}', style:  options.versionStyle ?? TextStyle(color: Colors.white.withOpacity(0.5))))
                  ):Container();
                }
            ),
            if(options.coatingBuilder != null)options.coatingBuilder!(),
          ],
        ),
      ),
    );
  }
}
