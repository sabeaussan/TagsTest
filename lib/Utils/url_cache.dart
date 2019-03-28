
import 'package:tags/Utils/firebase_db.dart';

class UrlCache {

  static List<Map <String,String>> _urlStorage=[];

  static void _storeUrl(String uid,String url){
    final Map<String,String> _storageItem = {uid : url};
    print("_storeUrl : "+_storageItem.toString());
    _urlStorage.add(_storageItem);
    print("_urlStorage :"+_urlStorage.toString());
  }

  static Map<String,String> _isCached(String uid){
    Map<String,String> cachedItem;
    _urlStorage.forEach((storedItem){
      print("_isCached : "+storedItem.keys.single);
      if(storedItem.containsKey(uid)) cachedItem=storedItem;
    });
    return cachedItem;
  }


  static Future<String> getUrl(String uid) async {
    Map <String,String> cachedItem = _isCached(uid);
    print("get Url : "+cachedItem.toString());
    print("_urlStorageBefore :"+_urlStorage.toString());
    if(cachedItem!=null) return cachedItem.values.single;
    else {
      //TODO : gérer les cas ou l'url est nulle pour éviter des appels serveurs inutile
      print("fetching url");
      String url = await db.getUserPhototUrl(uid);
      cachedItem={uid : url};
      if(url!=null && !_urlStorage.contains(cachedItem)) _storeUrl(uid, url);
      return url;
    }
  }



  
}