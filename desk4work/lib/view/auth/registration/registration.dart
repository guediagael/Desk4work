import 'package:desk4work/api/auth_api.dart';
import 'package:desk4work/utils/constants.dart';
import 'package:desk4work/utils/string_resources.dart';
import 'package:desk4work/view/auth/registration/welcome.dart';
import 'package:desk4work/view/common/box_decoration_util.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationScreen extends StatefulWidget{

  @override
  State<StatefulWidget> createState() => RegistrationScreenState();

}

class RegistrationScreenState extends State<RegistrationScreen>{
  var _formKey = GlobalKey<FormState>();
  Size _screenSize;
  TextEditingController _loginController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _passwordConfirmController = TextEditingController();

  AuthApi _authApi = AuthApi();

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    return Scaffold(
//      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.transparent,
      body: Container(
        margin: EdgeInsets.only(top: (_screenSize.height * .078).toDouble()),
        width: (_screenSize.width * .84).toDouble(),
        child: ListView(
          reverse: true,
//          mainAxisAlignment: MainAxisAlignment.start,
//          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/logo_horizontal_color_shaded.png',
              fit: BoxFit.contain,
              width:(_screenSize.width * .4311).toDouble() ,
              height: (_screenSize.height * .0836).toDouble(),
            ),
            Container(
              margin: EdgeInsets.only(top: (_screenSize.height * .0633).toDouble()),
              child: Form(child: _getForm(), key: _formKey,),

            ),
            _getSendFormButton(),
            Padding( padding: EdgeInsets.only(bottom: (_screenSize.height * .0735).toDouble()),)

          ].reversed.toList(),
        ),
      ),
    );
  }
  Widget _getForm(){
    double formFieldPaddingVert = (_screenSize.height * .0195).toDouble();
    double formFieldPaddingHor = (_screenSize.width * .0667).toDouble();
    return Column(
      children: <Widget>[
        TextFormField(
          autocorrect: false,
          controller: _loginController,
          decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(28.0))
            ),
            contentPadding: EdgeInsets.symmetric(vertical: formFieldPaddingVert, horizontal: formFieldPaddingHor),
            hintText: StringResources.of(context).hLogin,
          ),
          validator: (login) {
            if (login.isEmpty ) return StringResources.of(context).eEmptyLogin;
          },
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: (_screenSize.height * .014).toDouble()),
        ),
        TextFormField(
          keyboardType: TextInputType.emailAddress,
          controller: _emailController,
          decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(28.0)),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: formFieldPaddingVert, horizontal: formFieldPaddingHor),
              hintText: StringResources.of(context).hEmail),
          validator: (email) {
            if (email.isEmpty)
              return StringResources.of(context).eEmptyEmail;
          },
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: (_screenSize.height * .014).toDouble()),
        ),
        TextFormField(
          keyboardType: TextInputType.phone,
          controller: _phoneController,
          decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(28.0)),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: formFieldPaddingVert, horizontal: formFieldPaddingHor),
              hintText: StringResources.of(context).hPhone),
          validator: (phone) {
            if (phone.isEmpty)
              return StringResources.of(context).eEmptyPhone;
          },
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: (_screenSize.height * .014).toDouble()),
        ),
        TextFormField(
          obscureText: true,
          controller: _passwordController,
          decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(28.0)),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: formFieldPaddingVert, horizontal: formFieldPaddingHor),
              hintText: StringResources.of(context).hPassword),
          validator: (password) {
            if (password.isEmpty)
              return StringResources.of(context).eEmptyPassword;
          },
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: (_screenSize.height * .014).toDouble()),
        ),
        TextFormField(
          obscureText: true,
          controller: _passwordConfirmController,
          decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(28.0)),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: formFieldPaddingVert, horizontal: formFieldPaddingHor),
              hintText: StringResources.of(context).hPasswordConfirm),
          validator: (passwordConfirm) {
            if (passwordConfirm.isEmpty)
              return StringResources.of(context).eEmptyPasswordConfirm;
            else if(! _passwordsMatching())
              return StringResources.of(context).eNotMatchingPasswords;
          },
        )
      ],
    );
  }

  Widget _getSendFormButton(){
    return Container(
        margin: EdgeInsets.only(top: (_screenSize.height * .0405).toDouble()),
        width: (_screenSize.width * .84).toDouble(),
        height: (_screenSize.height * .0825).toDouble(),
        decoration:  BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            gradient: BoxDecorationUtil.getOrangeGradient().gradient,
            borderRadius: BorderRadius.all(Radius.circular(28.0))),
        child: Center(
          child: InkWell(
            child: Text(
              StringResources.of(context).bRegister,
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              if (_formKey.currentState.validate()) _sendForm();
            },
          ),
        ));
  }

  _sendForm(){
    String login = _loginController.text;
    String email = _emailController.text;
    String phone = _phoneController.text;
    String password = _passwordController.text;
    String passwordConfirm = _passwordConfirmController.text;

    try{
      _authApi.register(login, email, phone, password, passwordConfirm)
          .then((response){
            if(response !=null && response[ConstantsManager.EMAIL_KEY] !=null){
              String email = response[ConstantsManager.EMAIL_KEY];
              String firstName= response[ConstantsManager.FIRST_NAME];
              String password = response[ConstantsManager.PASSWORD_KEY];
              SharedPreferences.getInstance().then((sp){
                sp.setString(ConstantsManager.EMAIL_KEY, email);
                sp.setString(ConstantsManager.FIRST_NAME, firstName);
                sp.setString(ConstantsManager.PASSWORD_KEY, password);
              }).then((_){
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (ctx)=>WelcomeScreen(firstName)));
              });
            }else _showMessage("ERROR"); //TODO
      });
    }catch (e){
//      TODO
    }
  }

  bool _passwordsMatching(){
    String password = _passwordController.text;
    String passwordConfirm = _passwordConfirmController.text;
    if(password.length > 0 && passwordConfirm.length > 0){
      return (passwordConfirm.trim() == password.trim());
    }
    return false;
  }

  _showMessage(String message){

  }

}