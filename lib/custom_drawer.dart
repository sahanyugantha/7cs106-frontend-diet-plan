import 'package:flutter/material.dart';
//import 'login_page.dart';
//import 'registration_page.dart';
//import 'user_settings_page.dart';
// appBar: AppBar(
//   title: Text('Home'),
//   backgroundColor: Colors.blueAccent,
// ),
class CustomDrawer extends StatelessWidget {
  final dynamic userData; // Replace dynamic with your user model if needed

  CustomDrawer({this.userData});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: userData != null
                ? drawerTitle(userData)
                : SizedBox(),
          ),
          if (userData == null) ...[
            ListTile(
              title: Text('Login'),
              leading: Icon(Icons.login),
              onTap: () {
                Navigator.push(
                  context,
               //   MaterialPageRoute(builder: (context) => LoginPage()),
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Register'),
              leading: Icon(Icons.person_add),
              onTap: () {
                Navigator.push(
                  context,
                  //MaterialPageRoute(builder: (context) => RegistrationPage()),
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
            ),
          ] else ...[
            ListTile(
              title: Text('Settings'),
              leading: Icon(Icons.settings),
              // onTap: () {
              //   // Navigator.push(
              //   //   context,
              //   //   MaterialPageRoute(
              //   //     builder: (context) => UserSettingsPage(userData: userData),
              //   //   ),
              //   );
              // },
            ),
            ListTile(
              title: Text('Logout'),
              leading: Icon(Icons.logout),
              onTap: () {
                // Add logout functionality here
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget drawerTitle(dynamic userData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(userData['profilePictureUrl']), // Replace with your actual user data
        ),
        SizedBox(height: 10),
        Text(
          userData['username'], // Replace with your actual user data
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        Text(
          userData['email'], // Replace with your actual user data
          style: TextStyle(fontSize: 14, color: Colors.white70),
        ),
      ],
    );
  }

}

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Text('Login Screen'),
      ),
    );
  }
}

class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Center(
        child: Text('Register Screen'),
      ),
    );
  }
}
