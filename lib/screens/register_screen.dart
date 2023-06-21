import 'package:flutter/material.dart';
import 'package:products_app/providers/login_form_provider.dart';
import 'package:products_app/services/services.dart';
import 'package:provider/provider.dart';

import 'package:products_app/ui/input_decorations.dart';
import 'package:products_app/widgets/widgets.dart';


class RegisterScreen extends StatelessWidget {
   
  const RegisterScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: SingleChildScrollView(
          child: Column(
            children: [
               const SizedBox(height: 250),
               CardContainer(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Text('Create Account', style: Theme.of(context).textTheme.headline4),
                    
                    ChangeNotifierProvider(
                      create: (_) => LoginFormProvider(),
                      child: _LoginForm()
                    )
                    

                ])
               ),
               const SizedBox( height: 50),
               TextButton(
                onPressed: ()=> Navigator.pushReplacementNamed(context, 'login'),
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Colors.indigo.withOpacity(0.1)),
                  shape: MaterialStateProperty.all( const StadiumBorder() )
                ), 
                child: const Text('Do you have an account?', style: TextStyle( fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
               ),
               const SizedBox( height: 50),
            ],
          ),
        )
      )
    );
  }
}

class _LoginForm extends StatelessWidget {


  @override
  Widget build(BuildContext context) {

    final registerForm = Provider.of<LoginFormProvider>(context);
    
    return Container(
      child: Form(
        // TODO: Mantener la referencia al key

        key: registerForm.formKey,

        autovalidateMode: AutovalidateMode.onUserInteraction,
        
        child: Column(
          children: [
            TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecorations.authInputDecoration(
                hintText: 'example@gmail.com',
                labelText: 'Email Address',
                prefixIcon: Icons.alternate_email_outlined
              ),
              onChanged: (value) => registerForm.email = value,
              validator: (value){
                String pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                RegExp regExp  = RegExp(pattern);

                return regExp.hasMatch(value ?? '')
                  ? null
                  : 'The value is not a email';
              },
            ),
            const SizedBox(height: 30),
            TextFormField(
              autocorrect: false,
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecorations.authInputDecoration(
                hintText: '*********',
                labelText: 'Password',
                prefixIcon: Icons.lock_outline
              ),
              onChanged: (value) => registerForm.password = value,
              validator: (value){
                
                if( value != null && value.length >= 6) return null;

                return 'Password must be 6 characters';
              },
            ),
            const SizedBox( height: 30),
            MaterialButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              color: Colors.deepPurple,
              disabledColor: Colors.grey,
              elevation: 0,
              onPressed: registerForm.isLoading ? null : () async{

                final authService = Provider.of<AuthService>(context, listen: false);

                FocusScope.of(context).unfocus();
                if(!registerForm.isValidForm())return ;

                registerForm.isLoading = true;

                final String? errorMessage = await authService.createUser(registerForm.email, registerForm.password);

                if(errorMessage == null){
                Navigator.pushReplacementNamed(context, 'home');
                }else{
                  // TODO: Show error on screen
                  print(errorMessage);
                  registerForm.isLoading = false;
                }
                

              },
              child: Container( 
                padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                child: Text(
                  registerForm.isLoading?
                  'Loading...':
                  'Login', 
                  style: const TextStyle( color:Colors.white)
                ),
              ))
          ],
        ),
      ),
    );
  }
}