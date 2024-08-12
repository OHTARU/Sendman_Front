
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SessionGoogle{
  late String username;
  late String url;
  late String token;
  SessionGoogle(){
    _read();
  }
  Future<void> _read() async{
    const storage = FlutterSecureStorage();
    String? username = await storage.read(key: "username");
    String? url = await storage.read(key: "url");
    String? token = await storage.read(key: "token");
    if(username != null && token != null){
      this.username = username;
      this.token = token;
    }else{
      this.username = "anonymous";
      this.token = "anonymous";
    }
    if(url != null){
      this.url = url;
    }
  }
  SessionGoogle.save(GoogleSignInAccount user){
    _save(user);
  }
  Future<void> _save(GoogleSignInAccount user) async{
    const storage = FlutterSecureStorage();
    String? token = "";
    storage.write(key: "username", value: user.displayName);
    storage.write(key: "url", value: user.photoUrl);
    user.authentication.then((val)=>{
      token = val.accessToken
    });
    storage.write(key: "token", value: token);
    this.token = token!;
    username = user.displayName!;
    url = user.photoUrl!;
  }
}