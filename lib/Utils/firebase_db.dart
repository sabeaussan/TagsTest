import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tags/Models/comments.dart';
import 'package:tags/Models/discussion.dart';
import 'package:tags/Models/message.dart';
import 'package:tags/Models/post.dart';
import 'package:tags/Models/tags.dart';
import 'package:tags/Models/tags_message.dart';
import 'package:tags/Models/user.dart';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tags/Models/userPost.dart';
import 'package:tags/UI/post_tile.dart';





final FirebaseDB db =FirebaseDB();

class FirebaseDB {

  //TODO: vérifier les Future et async/posé la question sur stackOverFlow
  //TODO: enlever les runTransaction inutile
  
  
  /*-------------------------------Firestore-----------------------------------------*/
  
  final CollectionReference userRef = Firestore.instance.collection('User');
  final CollectionReference tagsRef = Firestore.instance.collection('Tags');
  final CollectionReference discussionRef = Firestore.instance.collection('Discussions');
  final CollectionReference postCommentRef = Firestore.instance.collection('PostComments');


  void deletePostFireStore(PostTile post) async { 
    await _deleteImage(post.id,post.tagsId);
    await userRef.document(post.ownerId).collection("UserPost").document(post.id).delete();
    await tagsRef.document(post.tagsId).collection("TagsPost").document(post.id).delete();
    await postCommentRef.document(post.id).delete();
    updateOldTags(post.tagsId,"nbMessage",-1);
  }

  void deleteCommentFirestore(String tagId,String postId,String id) async { 
    await postCommentRef.document(postId).collection("Comments").document(id).delete();
    updateOldPost(postId,tagId,"nbComments",-1);
  }
  

  void deleteDiscussionFireStore(String discId,String uid) async { 
    //memory leaks
    await userRef.document(uid).collection("Discussion").document(discId).delete();
  }

  void deleteTagsMessageFirestore(String tagId,String id) async { 
    await tagsRef.document(tagId).collection("TagsMessage").document(id).delete();
    updateOldTags(tagId,"nbMessage",-1);
  }

  Future<User> getUser(String uid) async {
    final DocumentSnapshot userSnapshot = await userRef.document(uid).get();
    final User user =User.fromDocumentSnapshot(userSnapshot);
    return user;
  }
  
  Future<void>  createUserFirestore(User user) async{
    Firestore.instance.runTransaction((Transaction transaction) async {
      await userRef.document(user.id).setData(user.toJson()).catchError((e){
        print(e);
      });
    }).then((value){
      print("User created");
    });
  }
  

  Future<void> createPostFirestore(Post post,File imageFile) async {
      DocumentReference tagDocReference =  tagsRef.document(post.tagOwner.id).collection("TagsPost").document();
      String postId = tagDocReference.documentID;
      String imageUrl = await  uploadImagePost(post.tagOwner.id,imageFile,postId);
      post.setImageUrl(imageUrl);
      post.setId(postId);
      UserPost userPost = UserPost.fromPost(post);
      await userRef.document(post.creator.id).collection("UserPost").document(userPost.id).setData(userPost.toJson())
      .catchError((e)=> print(e));
      await tagDocReference.setData(post.toJson())
      .catchError((e)=>print(e));
      updateOldTags(post.tagOwner.id,"nbPost",1);
  }

  Future<void> createPostCommentFirestore(Comment comment,String tagId,String postId) async {
      DocumentReference commentDocRef =  postCommentRef.document(comment.postId).collection("Comments").document();
      String postCommentId = commentDocRef.documentID;
      comment.setId(postCommentId);
      await commentDocRef.setData(comment.toJson())
      .catchError((e)=>print(e));
      updateOldPost(postId, tagId,"nbComments",1);
  }

  void updateOldPost(String postId, String tagId,String newInfo,int arg){
      DocumentReference postDocRef = tagsRef.document(tagId).collection("TagsPost").document(postId);
      Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentSnapshot postToUpdateSnapshot = await transaction.get(postDocRef);    //compte comme une lecture, voir si il y & pas moyen 
        if(postToUpdateSnapshot.exists){
          await transaction.update(
            postToUpdateSnapshot.reference,<String, dynamic>{newInfo : postToUpdateSnapshot.data[newInfo] + arg}
          ).catchError((e)=> print(e));
        }
      });
    }

    void updateOldUserPost(String postId, String uid, bool hasBeenSeen){
      DocumentReference postDocRef = userRef.document(uid).collection("UserPost").document(postId);
      Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentSnapshot postToUpdateSnapshot = await transaction.get(postDocRef);    //compte comme une lecture, voir si il y & pas moyen 
        if(postToUpdateSnapshot.exists){
          await transaction.update(
            postToUpdateSnapshot.reference,<String, dynamic>{
              "lastCommentSeen" : hasBeenSeen,
              "timeStamp"       : timeStamp()
              }
          ).catchError((e)=> print(e));
        }
      });
    }

    String timeStamp() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<void> sendMessageFirestore(String discussionId,Message message,User currentuser, User partner) async {
    DocumentReference discussionDocReference = discussionRef.document(discussionId).collection("Message").document();
    message.setId(discussionDocReference.documentID);
    await discussionDocReference.setData(message.toJson()).catchError((e)=>print(e));
    DocumentReference currentUserDiscussionDocReference =userRef.document(currentuser.id).collection("Discussion").document(discussionId);
    DocumentReference partnerDiscussionDocReference =userRef.document(partner.id).collection("Discussion").document(discussionId);
    if(currentuser!=null && partner!=null){
        //TODO: ne pas réécrire dans discussion a chaque envoie de message
        //TODO: faire un setId sur pour la discussion
        Discussion currentUserDiscussion =Discussion(message.content, true,partner.photoUrl, partner.userName,partner.id, timeStamp());
        currentUserDiscussion.setId(currentUserDiscussionDocReference.documentID);
        currentUserDiscussionDocReference.setData(currentUserDiscussion.toJson()).catchError((e)=>print(e));
        Discussion partnerDiscussion =Discussion(message.content,false,currentuser.photoUrl ,currentuser.userName,currentuser.id, timeStamp());
        partnerDiscussion.setId(partnerDiscussionDocReference.documentID);
        partnerDiscussionDocReference.setData(partnerDiscussion.toJson()).catchError((e)=>print(e));
    }
  }


  void updateDiscussion(String uid,String discussionId) async {
    print("updateDiscussion");
    //Sert à mettre a jour la conversation pour que seul les messages non vus soit notifié
    //Elle s'utilise uniquement lorsqu'on sort de la chat room cad dans le dispose
    DocumentReference currentUserDiscussionDocReference = userRef.document(uid).collection("Discussion").document(discussionId);
      await currentUserDiscussionDocReference.updateData(
        <String, dynamic>{"lastMessageSeen" : true}
      ).catchError((e)=> print(e));
    
  }

  Future<void> sendTagMessageFirestore(TagsMessage message) async {
      DocumentReference discussionDocReference = tagsRef.document(message.tagOwnerId).collection("TagsMessage").document();
      message.setId(discussionDocReference.documentID);
      await discussionDocReference.setData(message.toJson()).catchError((e)=>print(e));
      updateOldTags(message.tagOwnerId,"nbMessage",1);
    }
  
    Future<Tags> createTag(Tags tag, User oldUser ) async {
      Firestore.instance.runTransaction((Transaction transaction) async {
        DocumentReference tagDocReference =  tagsRef.document();
        String tagId = tagDocReference.documentID;
        tag.setId(tagId);
        await tagDocReference.setData(tag.toJson()).catchError((e)=>print(e));
      });
      return tag;
    }
  
    //TODO: une seule fonction update est nécéssaire
  
    void updateOldTags(String oldTagsId,String newInfo,int arg){
      DocumentReference tagToUpdateRef = tagsRef.document(oldTagsId);
      Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentSnapshot tagToUpdateSnapshot = await transaction.get(tagToUpdateRef);
        if(tagToUpdateSnapshot.exists){
          await transaction.update(
            tagToUpdateSnapshot.reference,<String, dynamic>{newInfo : tagToUpdateSnapshot.data[newInfo] + arg}
          ).catchError((e)=> print(e));
        }
      });
    }

    

  
   /* void updateOldUser(User oldUser,String newInfo){
      DocumentReference userToUpdateRef = userRef.document(oldUser.id);
      Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentSnapshot userToUpdateSnapshot = await transaction.get(userToUpdateRef);
        if(userToUpdateSnapshot.exists){
          await transaction.update(
            userToUpdateSnapshot.reference,<String, dynamic>{newInfo : userToUpdateSnapshot.data[newInfo] + 1}
          ).catchError((e)=> print(e));
        }
      });
    }*/

    void updateOldUserFav(User oldUser,String postId,int arg){
      DocumentReference userToUpdateRef = userRef.document(oldUser.id);
      Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentSnapshot userToUpdateSnapshot = await transaction.get(userToUpdateRef);
        if(userToUpdateSnapshot.exists){
          arg==1 ? 
          await transaction.update(
           userToUpdateSnapshot.reference,<String, dynamic>{"favPostId" : FieldValue.arrayUnion([postId]) }
          ).catchError((e)=> print(e))
          :
          await transaction.update(
           userToUpdateSnapshot.reference,<String, dynamic>{"favPostId" : FieldValue.arrayRemove([postId]) }
          ).catchError((e)=> print(e));
        }
      });
    }

    void updateOldUserFavTags(User oldUser,String tagId,int arg){
      DocumentReference userToUpdateRef = userRef.document(oldUser.id);
      Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentSnapshot userToUpdateSnapshot = await transaction.get(userToUpdateRef);
        if(userToUpdateSnapshot.exists){
          arg==1 ? 
          await transaction.update(
           userToUpdateSnapshot.reference,<String, dynamic>{"favTagsId" : FieldValue.arrayUnion([tagId]) }
          ).catchError((e)=> print(e))
          :
          await transaction.update(
           userToUpdateSnapshot.reference,<String, dynamic>{"favTagsId" : FieldValue.arrayRemove([tagId]) }
          ).catchError((e)=> print(e));
        }
      });
    }
  
    
  
  
    void updateUser(User oldUser,String prenom,String nom, String userName,String bio)  {      //rename updateProfileUser
      //Comparer a oldUser pour savoir ce qu'il faut changer exactement
      if(oldUser.prenom ==prenom && oldUser.nom==nom && oldUser.userName==userName && oldUser.bio==bio) return;
      DocumentReference userToUpdateRef = userRef.document(oldUser.id);
      Firestore.instance.runTransaction((Transaction transaction) async {
        DocumentSnapshot userToUpdateSnapshot = await transaction.get(userToUpdateRef);
        if(userToUpdateSnapshot.exists){
          await transaction.update(
            userToUpdateSnapshot.reference, {
            'nom': nom,
            'prenom' : prenom,
            'userName' :userName,
            'bio' : bio
            }
          ).catchError((e)=> print(e));
        }
      });
    }
  
    Future<void> updateUserPhoto(User user,File userPhoto) async {
      String photoUrl = await  uploadImage(user.id,userPhoto);
      DocumentReference userToUpdateRef = userRef.document(user.id);
      Firestore.instance.runTransaction((Transaction transaction) async {
        DocumentSnapshot userToUpdateSnapshot = await transaction.get(userToUpdateRef);
        if(userToUpdateSnapshot.exists){
          await transaction.update(
            userToUpdateSnapshot.reference, {
            'photoUrl' : photoUrl
            }
          ).catchError((e)=> print(e));
        }
      });
      return;
    }
  
  
    
  
  
    /*-----------------------------------------------------------------------------------*/
  
  
    /*---------------------------------FirebasAuth---------------------------------------*/
  
  
    final FirebaseAuth _auth =FirebaseAuth.instance;
  
  
    
  
  
    Future<FirebaseUser> signInUser (String mail, String passWord) async {
      //envoie un snpashot dans le stream onAuthChanged
      final FirebaseUser fbUser =await _auth.signInWithEmailAndPassword(email: mail,password: passWord);
      return fbUser;
    }
  
    Future<void> signOutUser()async {
      await _auth.signOut();
    }
  
    Future<FirebaseUser> createUser (String mail, String passWord,String nom,String prenom, String userName) async {
      //TODO: rajouter un nom d'utilisateur dans le createUser + textField dans LoginPage
      final FirebaseUser fbUser = await _auth.createUserWithEmailAndPassword(email: mail,password: passWord);
      String id =fbUser.uid;
      final User user = User(mail,passWord,nom,prenom,id,userName,"",null,null,null,null);
      await db.createUserFirestore(user);
      return fbUser;
    }
  
    Future<String> getCurrentUserId() async{
      FirebaseUser fbUser = await FirebaseAuth.instance.currentUser();
      return fbUser.uid;
    }
  
  
  
  
    Future<User> getCurrentUser() async{
      //TODO: le currentUser Id est dispo depuis le main
      final String currentUserId =await getCurrentUserId();
      DocumentReference currentUser = userRef.document(currentUserId);
      DocumentSnapshot currentUserSnapshot = await currentUser.get();
      return User.fromDocumentSnapshot(currentUserSnapshot);
    }
  
  
  
  
    /*---------------------------------------------------------------------------------------*/
  
  
    /*-----------------------------------Firebase Storage----------------------------------------------*/
    
    final StorageReference _userRefStorage =FirebaseStorage().ref().child("userPhotoProfile");
    final StorageReference _postRefStorage =FirebaseStorage().ref().child("post");
  
    Future<String> uploadImage(String uid,File userPhoto) async {
      final StorageUploadTask task = _userRefStorage.child(uid).putFile(userPhoto);
      final StorageTaskSnapshot snapshot = await task.onComplete;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    }

    Future<void> _deleteImage(String id,String tagId) async {
      //TODO: manage les erreurs
      final StorageReference refStorage = _postRefStorage.child(tagId).child(id);
      await refStorage.delete();
    }

    Future<String> getUserPhototUrl(String uid) async {
      final String userPhotoUrl = await _userRefStorage.child(uid).getDownloadURL().catchError(
        (e)=> print(e)
      );
      return userPhotoUrl;
    }
  
    Future<String> uploadImagePost(String tagId,File userPhoto,String postId) async {
      final StorageUploadTask task = _postRefStorage.child(tagId).child(postId).putFile(userPhoto);
      final StorageTaskSnapshot snapshot = await task.onComplete;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    }
  
  
  
  
    /*---------------------------------------------------------------------------------------*/
    
  
  }
 