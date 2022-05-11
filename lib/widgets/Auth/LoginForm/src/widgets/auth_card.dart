import 'dart:math';
import 'package:flutter/material.dart';
import 'package:transformer_page_view/transformer_page_view.dart';
import 'package:vhv_basic/form.dart';
import 'package:vhv_basic/import.dart';
import 'package:vhv_basic/widgets/Auth/Controller.dart';
import '../dart_helper.dart';
import '../matrix.dart';
import '../models/login_data.dart';
import '../paddings.dart';
import '../providers/auth.dart';
import '../providers/login_messages.dart';
import '../widget_helper.dart';
import 'animated_button.dart';
import 'animated_text.dart';
import 'animated_text_form_field.dart';
import 'custom_page_transformer.dart';
import 'expandable_container.dart';
import 'fade_in.dart';

class AuthCard extends StatefulWidget {
  AuthCard({
    Key? key,
    this.padding = const EdgeInsets.all(0),
    this.loadingController,
    this.emailValidator,
    this.fullNameValidator,
    this.passwordValidator,
    this.onSubmit,
    this.onSubmitCompleted,
    this.forgotPassword,
    this.signUpExtra,
    this.header,
    this.headerRegister,
    this.hideRegister,
    this.hideBirthDate = true, this.options,
  }) : super(key: key);

  final EdgeInsets padding;
  final AnimationController? loadingController;
  final FormFieldValidator<String>? emailValidator;
  final FormFieldValidator<String>? fullNameValidator;
  final FormFieldValidator<String>? passwordValidator;
  final Function? onSubmit;
  final Function(bool isLogin)? onSubmitCompleted;
  final Widget? forgotPassword;
  final Widget? signUpExtra;
  final Widget? header;
  final Widget? headerRegister;
  final bool? hideRegister;
  final bool hideBirthDate;
  final AuthPageOption? options;

  @override
  AuthCardState createState() => AuthCardState();
}

class AuthCardState extends State<AuthCard> with TickerProviderStateMixin {
  GlobalKey _cardKey = GlobalKey();
  var _isLoadingFirstTime = true;
  var _pageIndex = 0;
  static const cardSizeScaleEnd = .2;

  late TransformerPageController _pageController;
  late AnimationController _formLoadingController;
  late AnimationController _routeTransitionController;
  late Animation<double> _flipAnimation;
  late Animation<double> _cardSizeAnimation;
  late Animation<double> _cardSize2AnimationX;
  late Animation<double> _cardSize2AnimationY;
  late Animation<double> _cardRotationAnimation;
  late Animation<double> _cardOverlayHeightFactorAnimation;
  late Animation<double> _cardOverlaySizeAndOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = TransformerPageController();
    widget.loadingController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _isLoadingFirstTime = false;
        _formLoadingController.forward();
      }
    });

    _flipAnimation = Tween<double>(begin: pi / 2, end: 0).animate(
      CurvedAnimation(
        parent: widget.loadingController!,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      ),
    );

    _formLoadingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1150),
      reverseDuration: Duration(milliseconds: 300),
    );

    _routeTransitionController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1100),
    );

    _cardSizeAnimation = Tween<double>(begin: 1.0, end: cardSizeScaleEnd)
        .animate(CurvedAnimation(
      parent: _routeTransitionController,
      curve: Interval(0, .27272727 /* ~300ms */, curve: Curves.easeInOutCirc),
    ));
    // replace 0 with minPositive to pass the test
    // https://github.com/flutter/flutter/issues/42527#issuecomment-575131275
    _cardOverlayHeightFactorAnimation =
        Tween<double>(begin: double.minPositive, end: 1.0)
            .animate(CurvedAnimation(
          parent: _routeTransitionController,
          curve: Interval(.27272727, .5 /* ~250ms */, curve: Curves.linear),
        ));
    _cardOverlaySizeAndOpacityAnimation =
        Tween<double>(begin: 1.0, end: 0).animate(CurvedAnimation(
          parent: _routeTransitionController,
          curve: Interval(.5, .72727272 /* ~250ms */, curve: Curves.linear),
        ));
    _cardSize2AnimationX =
        Tween<double>(begin: 1, end: 1).animate(_routeTransitionController);
    _cardSize2AnimationY =
        Tween<double>(begin: 1, end: 1).animate(_routeTransitionController);
    _cardRotationAnimation =
        Tween<double>(begin: 0, end: pi / 2).animate(CurvedAnimation(
          parent: _routeTransitionController,
          curve: Interval(
              .72727272, 1 /* ~300ms */, curve: Curves.easeInOutCubic),
        ));
  }

  @override
  void dispose() {
    _formLoadingController.dispose();
    _pageController.dispose();
    _routeTransitionController.dispose();
    super.dispose();
  }

  void _switchRecovery(bool recovery) {
    final auth = Provider.of<Auth>(context, listen: false);

    auth.isRecover = recovery;
    auth.reload();
    if (recovery) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
      _pageIndex = 1;
    } else {
      _pageController.previousPage(
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
      _pageIndex = 0;
    }
  }

  Future<void> runLoadingAnimation() {
    if (widget.loadingController!.isDismissed) {
      return widget.loadingController!.forward().then((_) {
        if (!_isLoadingFirstTime) {
          _formLoadingController.forward();
        }
      });
    } else if (widget.loadingController!.isCompleted) {
      return _formLoadingController
          .reverse()
          .then((_) => widget.loadingController!.reverse());
    }
    return Future(()async{});
  }

  Future<void> _forwardChangeRouteAnimation() async {
    final isLogin = Provider
        .of<Auth>(context, listen: false)
        .isLogin;
    final deviceSize = MediaQuery
        .of(context)
        .size;
    final cardSize = getWidgetSize(_cardKey);
    // add .25 to make sure the scaling will cover the whole screen
    final widthRatio =
        deviceSize.width / cardSize!.height + (isLogin ? .25 : .65);
    final heightRatio = deviceSize.height / cardSize.width + .25;

    _cardSize2AnimationX =
        Tween<double>(begin: 1.0, end: heightRatio / cardSizeScaleEnd)
            .animate(CurvedAnimation(
          parent: _routeTransitionController,
          curve: Interval(.72727272, 1, curve: Curves.easeInOutCubic),
        ));
    _cardSize2AnimationY =
        Tween<double>(begin: 1.0, end: widthRatio / cardSizeScaleEnd)
            .animate(CurvedAnimation(
          parent: _routeTransitionController,
          curve: Interval(.72727272, 1, curve: Curves.easeInOutCubic),
        ));
    widget.onSubmit!();
    // ignore: unnecessary_null_comparison
    Future.delayed(Duration(milliseconds: 500), () async {
      if(mounted) {
        _formLoadingController.reverse();
        _routeTransitionController.stop();
        widget.onSubmitCompleted!(isLogin);
      }
    });
  }

  void _reverseChangeRouteAnimation() {
    _routeTransitionController
        .reverse()
        .then((_) => _formLoadingController.forward());
  }

  void runChangeRouteAnimation() {
    if (_routeTransitionController.isCompleted) {
      _reverseChangeRouteAnimation();
    } else if (_routeTransitionController.isDismissed) {
      _forwardChangeRouteAnimation();
    }
  }

  void runChangePageAnimation() {
    final auth = Provider.of<Auth>(context, listen: false);
    _switchRecovery(!auth.isRecover);
  }

  Widget _buildLoadingAnimator({Widget? child, ThemeData? theme}) {
    Widget card;
    Widget overlay;

    // loading at startup
    card = AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) =>
          Transform(
            transform: Matrix.perspective()
              ..rotateX(_flipAnimation.value),
            alignment: Alignment.center,
            child: child,
          ),
      child: child,
    );

    // change-route transition
    overlay = Padding(
      padding: theme!.cardTheme.margin!,
      child: AnimatedBuilder(
        animation: _cardOverlayHeightFactorAnimation,
        builder: (context, child) =>
            ClipPath.shape(
              shape: theme.cardTheme.shape!,
              child: FractionallySizedBox(
                heightFactor: _cardOverlayHeightFactorAnimation.value,
                alignment: Alignment.topCenter,
                child: child,
              ),
            ),
        child: DecoratedBox(
          decoration: BoxDecoration(color: theme.colorScheme.secondary),
        ),
      ),
    );

    overlay = ScaleTransition(
      scale: _cardOverlaySizeAndOpacityAnimation,
      child: FadeTransition(
        opacity: _cardOverlaySizeAndOpacityAnimation,
        child: overlay,
      ),
    );

    return Stack(
      children: <Widget>[
        card,
        Positioned.fill(child: overlay),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceSize = MediaQuery
        .of(context)
        .size;
    final double _top = MediaQuery
        .of(context)
        .padding
        .top;
    final double _bottom = MediaQuery
        .of(context)
        .padding
        .bottom;
    Widget current = Container(
      height: (deviceSize.height - _bottom - _top >= 0)
          ? deviceSize.height - _bottom - _top
          : 0,
      width: deviceSize.width,
      padding: widget.padding,
      child: TransformerPageView(
        physics: NeverScrollableScrollPhysics(),
        pageController: _pageController,
        itemCount: 2,
        index: _pageIndex,
        transformer: CustomPageTransformer(),
        itemBuilder: (BuildContext context, int index) {
          final child = (index == 0)
              ? _buildLoadingAnimator(
            theme: theme,
            child: SafeArea(
              child: SizedBox(
                height: (deviceSize.height - _bottom - _top > 0)
                    ? deviceSize.height - _bottom - _top
                    : 0,
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _LoginCard(
                          hideBirthDate: widget.hideBirthDate,
                          header: widget.header ?? SizedBox(),
                          headerRegister:
                          widget.headerRegister ?? SizedBox(),
                          hideRegister: widget.hideRegister!,
                          key: _cardKey,
                          loadingController: _isLoadingFirstTime
                              ? _formLoadingController
                              : (_formLoadingController..value = 1.0),
                          emailValidator: widget.emailValidator!,
                          fullNameValidator: widget.fullNameValidator!,
                          passwordValidator: widget.passwordValidator!,
                          forgotPassword: widget.forgotPassword,
                          onSwitchRecoveryPassword: () =>
                              _switchRecovery(true),
                          signUpExtra: widget.signUpExtra!,
                          options: widget.options!,
                          onSubmitCompleted: (bool isLogin) {
                            _forwardChangeRouteAnimation().then((_) {
                              widget.onSubmitCompleted!(isLogin);
                            });
                          },
                        ),
                        (factories['loginFeature'] != LoginOption.required)
                            ? ButtonFlat(
                            onPressed: () {
                              goToHome();
                            },
                            child: Text(
                              'Trang chủ'.lang(),
                              style: TextStyle(
                                  color: widget.options!.titleColor??
                                      Colors.white),
                            ))
                            : SizedBox()
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
              : ListView(children: <Widget>[
            SizedBox(
                height: deviceSize.height - _bottom - _top,
                child: Flex(direction: Axis.vertical, children: <Widget>[
                  Expanded(
                      child: Center(
                        child: _RecoverCard(
                            header: widget.header ?? SizedBox(),
                            emailValidator: widget.emailValidator!,
                            onSwitchLogin: () => _switchRecovery(false),
                            options: widget.options!,
                            forgotPassword: widget.forgotPassword!),
                      ))
                ]))
          ]);

          return Align(
            alignment: Alignment.topCenter,
            child: child,
          );
        },
      ),
    );

    return AnimatedBuilder(
      animation: _cardSize2AnimationX,
      builder: (context, snapshot) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateZ(_cardRotationAnimation.value)
            ..scale(_cardSizeAnimation.value, _cardSizeAnimation.value)..scale(
                _cardSize2AnimationX.value, _cardSize2AnimationY.value),
          child: SafeArea(child: current),
        );
      },
    );
  }
}

class _LoginCard extends StatefulWidget {
  _LoginCard({
    Key? key,
    this.loadingController,
    required this.emailValidator,
    required this.fullNameValidator,
    required this.passwordValidator,
    required this.onSwitchRecoveryPassword,
    this.onSwitchAuth,
    this.onSubmitCompleted,
    this.forgotPassword,
    this.signUpExtra,
    this.header,
    this.headerRegister,
    this.hideRegister: false,
    this.hideBirthDate: true, this.options,
  }) : super(key: key);

  final AnimationController? loadingController;
  final FormFieldValidator<String> emailValidator;
  final FormFieldValidator<String> fullNameValidator;
  final FormFieldValidator<String> passwordValidator;
  final Function onSwitchRecoveryPassword;
  final Function? onSwitchAuth;
  final Function(bool isLogin)? onSubmitCompleted;
  final Widget? forgotPassword;
  final Widget? signUpExtra;
  final Widget? header;
  final Widget? headerRegister;
  final bool hideRegister;
  final bool hideBirthDate;
  final AuthPageOption? options;

  @override
  _LoginCardState createState() => _LoginCardState();
}

class _LoginCardState extends State<_LoginCard> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final _fullNameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  late TextEditingController _nameController;
  late TextEditingController _fullNameController;
  late TextEditingController _passController;
  late TextEditingController _confirmPassController;

  var _isLoading = false;
  var _isSubmitting = false;
  var _showShadow = true;

  /// switch between login and signup
  late AnimationController _loadingController;
  late AnimationController _switchAuthController;
  late AnimationController _postSwitchAuthController;
  late AnimationController _submitController;

  late Interval _nameTextFieldLoadingAnimationInterval;
  late Interval _extraFieldLoadingAnimationInterval;
  late Interval _passTextFieldLoadingAnimationInterval;
  late Interval _textButtonLoadingAnimationInterval;
  late Animation<double> _buttonScaleAnimation;

  bool get buttonEnabled => !_isLoading && !_isSubmitting;
  bool _hasFail = false;

  @override
  void initState() {
    super.initState();

    if (mounted) {
      final auth = Provider.of<Auth>(context, listen: false);
      _nameController = TextEditingController(text: auth.email);
      _fullNameController = TextEditingController(text: auth.fullName);
      _passController = TextEditingController(text: auth.password);
      _confirmPassController =
          TextEditingController(text: auth.confirmPassword);

      _loadingController = widget.loadingController ??
          (AnimationController(
            vsync: this,
            duration: Duration(milliseconds: 1150),
            reverseDuration: Duration(milliseconds: 300),
          )
            ..value = 1.0);

      _loadingController.addStatusListener(handleLoadingAnimationStatus);

      _switchAuthController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 800),
      );
      _postSwitchAuthController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 150),
      );
      _submitController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 1000),
      );

      _nameTextFieldLoadingAnimationInterval = const Interval(0, .85);
      _extraFieldLoadingAnimationInterval = const Interval(0.3, 1.0);
      _passTextFieldLoadingAnimationInterval = const Interval(.15, 1.0);
      _textButtonLoadingAnimationInterval =
      const Interval(.6, 1.0, curve: Curves.easeOut);
      _buttonScaleAnimation =
          Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: _loadingController,
            curve: Interval(.4, 1.0, curve: Curves.easeOutBack),
          ));
    }
  }

  void handleLoadingAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.forward) {
      setState(() => _isLoading = true);
    }
    if (status == AnimationStatus.completed) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _submitController.dispose();
    super.dispose();

    _loadingController.removeStatusListener(handleLoadingAnimationStatus);
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();

    _switchAuthController.dispose();
    _postSwitchAuthController.dispose();

  }

  void _switchAuthMode() {
    final auth = Provider.of<Auth>(context, listen: false);
    final newAuthMode = auth.switchAuth();
    if (newAuthMode == AuthMode.Signup) {
      _switchAuthController.forward();
    } else {
      _switchAuthController.reverse();
    }
  }

  Future<bool> _submit() async {
    // a hack to force unfocus the soft keyboard. If not, after change-route
    // animation completes, it will trigger rebuilding this widget and show all
    // textfields and buttons again before going to new route

    final auth = Provider.of<Auth>(context, listen: false);
    if (auth.isSignup && Get.isRegistered<AuthController>()) {
      if (Get
          .find<AuthController>()
          .captcha
          .length == 0) {
        Get
            .find<AuthController>()
            .captchaMessage
            .value = 'Bạn chưa nhập mã xác thực';
      } else {
        Get
            .find<AuthController>()
            .captchaMessage
            .value = '';
      }
    }
    if(widget.options!.extraRuler != null && Get.isRegistered<AuthController>()) {
      if(!Get.find<AuthController>().rule.value) {
        Get.find<AuthController>().ruleMessage.value = 'Bạn chưa đồng ý điều khoản';
      } else {
        Get.find<AuthController>().ruleMessage.value = '';
      }
    }

    FocusScope.of(context).requestFocus(FocusNode());
    if (!_formKey.currentState!.validate()) {
      _hasFail = true;
      return false;
    }
    _formKey.currentState!.save();
    _submitController.forward();
    setState(() => _isSubmitting = true);

    dynamic error;

    if (auth.isLogin) {
      error = await auth.onLogin!(LoginData(
        name: auth.email,
        password: auth.password,
      ));
    } else {
      error = await auth.onSignup!(LoginData(
        name: auth.email,
        fullName: auth.fullName,
        password: auth.password,
      ));
    }

    // workaround to run after _cardSizeAnimation in parent finished
    // need a cleaner way but currently it works so..
    Future.delayed(const Duration(milliseconds: 270), () {
      if (mounted) {
        WidgetsBinding.instance
            !.addPostFrameCallback((_) => setState(() {_showShadow = false;}));
      }
    });

    _submitController.reverse();

    if (error is String && !DartHelper.isNullOrEmpty(error)) {
      Future.delayed(const Duration(milliseconds: 271), () {
        setState(() => _showShadow = true);
        if(error != 'captcha_code'){
          showMessage(error, type: 'ERROR');
        }

      });
      setState(() => _isSubmitting = false);
      return false;
    }
    if(error is bool && error == false){
      setState(() => _isSubmitting = false);
      return false;
    }else{
      widget.onSubmitCompleted!(auth.isLogin);
      return true;
    }

  }

  Widget _buildNameField(double width, LoginMessages messages, Auth auth) {
    return AnimatedTextFormField(
      controller: _nameController,
      width: width,
      loadingController: _loadingController,
      interval: _nameTextFieldLoadingAnimationInterval,
      labelText: messages.usernameHint,
      onChanged: (val){
        if(_hasFail){_formKey.currentState!.validate();}
      },
      prefixIcon: Icon(
        Icons.account_circle,
        size: 22,
      ),
      keyboardType: widget.options!.usernameTextInputType ?? TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (value) {
        if (auth.isLogin) {
          FocusScope.of(context).requestFocus(_passwordFocusNode);
        } else {
          FocusScope.of(context).requestFocus(_fullNameFocusNode);
        }
      },
      validator: widget.emailValidator,
      onSaved: (value) => auth.email = value!,
    );
  }

  Widget _buildFullNameField(double width, LoginMessages messages, Auth auth) {
    return AnimatedTextFormField(
      controller: _fullNameController,
      width: width,
      loadingController: _loadingController,
      interval: _nameTextFieldLoadingAnimationInterval,
      labelText: messages.fullNameHint,
      onChanged: (val){
        if(_hasFail){_formKey.currentState!.validate();}
      },
      prefixIcon: Icon(
        Icons.account_circle,
        size: 22,
      ),
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      focusNode: _fullNameFocusNode,
      onFieldSubmitted: (value) {
        FocusScope.of(context).requestFocus(_passwordFocusNode);
      },
      validator: !auth.isLogin ? widget.fullNameValidator : null,
      onSaved: (value) => auth.fullName = value!,
    );
  }

  Widget _buildPasswordField(double width, LoginMessages messages, Auth auth) {
    return AnimatedPasswordTextFormField(
      animatedWidth: width,
      loadingController: _loadingController,
      interval: _passTextFieldLoadingAnimationInterval,
      labelText: messages.passwordHint,
      controller: _passController,
      onChanged: (val){
        if(_hasFail){_formKey.currentState!.validate();}
      },
      textInputAction:
      auth.isLogin ? TextInputAction.done : TextInputAction.next,
      focusNode: _passwordFocusNode,
      onFieldSubmitted: (value) {
        if (auth.isLogin) {
          _submit();
        } else {
          // SignUp
          FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
        }
      },
      validator: widget.passwordValidator,
      onSaved: (value) => auth.password = value!,
    );
  }

  Widget _buildConfirmPasswordField(double width, LoginMessages messages,
      Auth auth) {
    return AnimatedPasswordTextFormField(
      animatedWidth: width,
      enabled: auth.isSignup,
      loadingController: _loadingController,
      inertiaController: _postSwitchAuthController,
      inertiaDirection: TextFieldInertiaDirection.right,
      labelText: messages.confirmPasswordHint,
      controller: _confirmPassController,
      textInputAction: TextInputAction.done,
      focusNode: _confirmPasswordFocusNode,
      onChanged: (val){
        if(_hasFail){_formKey.currentState!.validate();}
      },
      onFieldSubmitted: (value) => _submit(),
      validator: auth.isSignup
          ? (value) {
        if (value != _passController.text) {
          return messages.confirmPasswordError;
        }
        return empty(value) ? 'Bạn chưa nhập lại mật khẩu'.lang() : null;
      }
          : (value) => null,
      onSaved: (value) => auth.confirmPassword = value!,
    );
  }

  Widget _buildSignUpExtra(double width, LoginMessages messages, Auth auth) {
    return (widget.signUpExtra != null)
        ? AnimatedExtraField(
        width: width,
        loadingController: _loadingController,
        interval: _extraFieldLoadingAnimationInterval,
        child: widget.signUpExtra)
        : SizedBox();
  }

  Widget _buildSignInExtra(double width) {
    return GetX<AuthController>(
      init: AuthController(),
      builder: (_controller) {
        if (_controller.showLoginCaptcha.value) {
          return Padding(
            padding: const EdgeInsets.only(top: 15),
            child: AnimatedExtraField(
                width: width,
                loadingController: _loadingController,
                interval: _extraFieldLoadingAnimationInterval,
                child: FormCaptcha(
                  prefixIcon: Icon(
                    Icons.vpn_key,
                    size: 22,
                  ),
                  buildReloadCaptcha: (reload) {
                    _controller.reloadCaptcha = reload;
                  },
                  reloadInInit: true,
                  errorText: !empty(_controller.captchaMessage.value)
                      ? _controller.captchaMessage.value.lang()
                      : null,
                  onChanged: (data) {
                    _controller.captcha = data;
                  },
                )),
          );
        }
        return SizedBox();
      },
    );
  }

  Widget _buildForgotPassword(ThemeData theme, LoginMessages messages,
      Auth auth) {
    return auth.isLogin
        ? FadeIn(
      controller: _loadingController,
      fadeDirection: FadeDirection.bottomToTop,
      offset: .5,
      curve: _textButtonLoadingAnimationInterval,
      child: ButtonFlat(
        child: Text(
          messages.forgotPasswordButton,
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.left,
        ),
        onPressed: buttonEnabled
            ? () {
          // save state to populate email field on recovery card
          _formKey.currentState!.save();
          widget.onSwitchRecoveryPassword();
        }
            : null,
      ),
    )
        : SizedBox(
      height: 15,
    );
  }

  Widget _buildSubmitButton(ThemeData theme, LoginMessages messages,
      Auth auth) {
    return ScaleTransition(
      scale: _buttonScaleAnimation,
      child: AnimatedButton(
        controller: _submitController,
        loadingColor: theme.primaryColor,
        widthButton: widget.options!.widthLoginButton,
        text: auth.isLogin ? messages.loginButton : messages.signupButton,
        onPressed: () {
          _submit();
        },
      ),
    );
  }

  Widget _buildSwitchAuthButton(ThemeData theme, LoginMessages messages,
      Auth auth) {
    return FadeIn(
      controller: _loadingController,
      offset: .5,
      curve: _textButtonLoadingAnimationInterval,
      fadeDirection: FadeDirection.topToBottom,
      child: ButtonFlat(
        child: AnimatedText(
          text: auth.isSignup ? messages.loginButton : messages.signupButton,
          textRotation: AnimatedTextRotation.down,
        ),
        disabledTextColor: theme.primaryColor,
        onPressed: buttonEnabled ? _switchAuthMode : null,
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textColor: theme.primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: true);
    final isLogin = auth.isLogin;
    final messages = Provider.of<LoginMessages>(context, listen: false);
    final theme = Theme.of(context);
    final deviceSize = MediaQuery
        .of(context)
        .size;
    final cardWidth = min(deviceSize.width * 0.85, 360.0);
    const cardPadding = 16.0;
    final textFieldWidth = cardWidth - cardPadding * 2;
    final Color _bgColor = Colors.transparent;
    final authForm = Form(
      key: _formKey,
      child: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: theme.primaryColor
          )
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.only(
                  left: cardPadding,
                  right: cardPadding,
                  top: cardPadding + 10,
                ),
                width: cardWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildNameField(textFieldWidth, messages, auth),
                    SizedBox(height: isLogin ? 20 : 10),
                  ],
                ),
              ),
              ExpandableContainer(
                backgroundColor: _bgColor,
                controller: _switchAuthController,
                initialState: isLogin
                    ? ExpandableContainerState.shrunk
                    : ExpandableContainerState.expanded,
                alignment: Alignment.topLeft,
                color: theme.cardTheme.color,
                width: cardWidth,
                padding: const EdgeInsets.only(
                    left: cardPadding, right: cardPadding, bottom: 20, top: 10),
                onExpandCompleted: () => _postSwitchAuthController.forward(),
                child: !isLogin
                    ? _buildFullNameField(textFieldWidth, messages, auth)
                    : const SizedBox.shrink(),
              ),
              _buildPasswordField(textFieldWidth, messages, auth),
              if (isLogin) _buildSignInExtra(textFieldWidth),
              const SizedBox(height: 10),
              ExpandableContainer(
                backgroundColor: _bgColor,
                controller: _switchAuthController,
                initialState: isLogin
                    ? ExpandableContainerState.shrunk
                    : ExpandableContainerState.expanded,
                alignment: Alignment.topLeft,
                color: theme.cardTheme.color,
                width: cardWidth,
                padding: const EdgeInsets.symmetric(
                  horizontal: cardPadding,
                  vertical: 10,
                ),
                onExpandCompleted: () => _postSwitchAuthController.forward(),
                child: Column(
                  children: <Widget>[
                    _buildConfirmPasswordField(textFieldWidth, messages, auth),
                    if (!isLogin) ...[
                      if(widget.options!.extraSignUp !=
                          null)widget.options!.extraSignUp!(),
                      _buildSignUpExtra(textFieldWidth, messages, auth),
                      if(widget.options!.extraRuler != null) widget.options!.extraRuler!(),
                    ],
                  ],
                ),
              ),
              Container(
                padding: Paddings.fromRBL(cardPadding),
                width: cardWidth,
                child: Column(
                  children: <Widget>[
                    (widget.forgotPassword != null)
                        ? _buildForgotPassword(theme, messages, auth)
                        : const SizedBox(
                      height: 15,
                    ),
                    _buildSubmitButton(theme, messages, auth),
                    const SizedBox(
                      height: 10,
                    ),
                    if (widget.options!.extraLoginType != null)
                      widget.options!.extraLoginType!(),
                    if (widget.options!.registerPage != null)
                      ButtonFlat(
                          onPressed: () {
                            appNavigator.pushNamed(widget.options!.registerPage.toString());
                          },
                          child: Text('Đăng ký'.lang(),style: TextStyle(color: widget.options!.titleColor??
                              Colors.white),)),
                    if (!widget.hideRegister)
                      _buildSwitchAuthButton(theme, messages, auth),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return FittedBox(
      child: Column(
        children: <Widget>[
          isLogin
              ? ((widget.header != null)
              ? Column(
            children: <Widget>[
              widget.header!,
              const SizedBox(
                height: 15,
              )
            ],
          )
              : const SizedBox.shrink())
              : ((widget.headerRegister != null)
              ? Column(
            children: <Widget>[
              widget.headerRegister!,
              const SizedBox(
                height: 15,
              )
            ],
          )
              : const SizedBox.shrink()),
          Card(
            elevation: _showShadow ? theme.cardTheme.elevation : 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.options!.headerInside != null && isLogin)
                  widget.options!.headerInside!(),
                authForm,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecoverCard extends StatefulWidget {
  _RecoverCard({
    Key? key,
    required this.emailValidator,
    required this.onSwitchLogin,
    this.build,
    this.forgotPassword,
    this.header, this.options,
  }) : super(key: key);

  final FormFieldValidator<String> emailValidator;
  final Function onSwitchLogin;
  final Widget? forgotPassword;
  final Widget? header;
  final AuthPageOption? options;
  final Widget Function(ThemeData theme, LoginMessages messages)? build;

  @override
  _RecoverCardState createState() => _RecoverCardState();
}

class _RecoverCardState extends State<_RecoverCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formRecoverKey = GlobalKey();

  var _isSubmitting = false;

  late AnimationController _submitController;

  @override
  void initState() {
    super.initState();
    _submitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _submitController.dispose();
  }

  Widget _buildBackButton(ThemeData theme, LoginMessages messages) {
    return ButtonFlat(
      child: Text('Đăng nhập'.lang(), style: widget.options!.btnLoginStyle),
      onPressed: !_isSubmitting
          ? () {
        _formRecoverKey.currentState!.save();
        widget.onSwitchLogin();
      }
          : null,
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textColor:
      widget.options!.btnLoginColor ?? theme.secondaryHeaderColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final messages = Provider.of<LoginMessages>(context, listen: false);
    final deviceSize = MediaQuery
        .of(context)
        .size;
    final cardWidth = min(deviceSize.width * 0.75, 360.0);
    const cardPadding = 16.0;
    return FittedBox(
      child: Column(
        children: <Widget>[
          if (widget.header != null) widget.header!,
          if (widget.header != null)
            const SizedBox(
              height: 10,
            ),
          Card(
            child: Container(
              padding: const EdgeInsets.only(
                left: cardPadding,
                top: cardPadding + 10.0,
                right: cardPadding,
                bottom: cardPadding,
              ),
              width: cardWidth,
              alignment: Alignment.center,
              child: Form(key: _formRecoverKey, child: widget.forgotPassword!),
            ),
          ),
          _buildBackButton(theme, messages),
        ],
      ),
    );
  }
}
