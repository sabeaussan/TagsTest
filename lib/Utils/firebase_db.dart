import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tags/Models/comment.dart';
import 'package:tags/Models/discussion.dart';
import 'package:tags/Models/message.dart';
import 'package:tags/Models/post.dart';
import 'package:tags/Models/publicmark.dart';
import 'package:tags/Models/tags_message.dart';
import 'package:tags/Models/user.dart';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tags/Models/userPost.dart';
import 'package:tags/UI/post_tile.dart';
import 'package:geoflutterfire/geoflutterfire.dart';





final FirebaseDB db =FirebaseDB();

class FirebaseDB {

  
  /*-------------------------------Firestore-----------------------------------------*/
  
  final CollectionReference userRef = Firestore.instance.collection('User');
  final CollectionReference tagsRef = Firestore.instance.collection('Tags');
  final CollectionReference discussionRef = Firestore.instance.collection('Discussions');
  final CollectionReference postCommentRef = Firestore.instance.collection('PostComments');
  Geoflutterfire geoflutterfire = Geoflutterfire();


  Future<void> deletePostFireStore(PostTile post) async { 
    //TODO : diminuer pop de 1
    await _deleteImage(post.id,post.tagsId);
    await userRef.document(post.ownerId).collection("UserPost").document(post.id).delete();
    await tagsRef.document(post.tagsId).collection("TagsPost").document(post.id).delete();
    await postCommentRef.document(post.id).delete();
    //updateMarkNbMsg(post.tagsId,"nbMessage",-1);  TODO: chelou !!!
  }

  Future<void> deleteCommentFirestore(String tagId,String postId,String id) async { 
    await postCommentRef.document(postId).collection("Comments").document(id).delete();
    //updatePostNbComments(postId,tagId,-1);
  }
  

  Future<void> deleteDiscussionFireStore(String discId,String uid) async { 
    //memory leaks
    await userRef.document(uid).collection("Discussion").document(discId).delete();
  }

  Future<void> deleteTagsMessageFirestore(String tagId,String id) async { 
    await tagsRef.document(tagId).collection("TagsMessage").document(id).delete();
    updateMarkNbMsg(tagId,"nbMessage",-1);
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
  

  Future<Post> createPostFirestore(Post post,File imageFile) async {
      DocumentReference markDocReference =  tagsRef.document(post.tagOwner.id).collection("TagsPost").document();
      String postId = markDocReference.documentID;
      String imageUrl = await  uploadImagePost(post.tagOwner.id,imageFile,postId);
      post.setImageUrl(imageUrl);
      post.setId(postId);
      UserPost userPost = UserPost.fromPost(post);
      await userRef.document(post.creator.id).collection("UserPost").document(userPost.id).setData(userPost.toJson())
      .catchError((e)=> print(e));
      await markDocReference.setData(post.toJson())
      .catchError((e)=>print(e));
      await updateMarkImage(post.tagOwner.id,"nbPost",post,1);
      return post;
  }

  Future<void> createPostCommentFirestore(Comment comment,String tagId,String postId) async {
      DocumentReference commentDocRef =  postCommentRef.document(comment.postId).collection("Comments").document();
      String postCommentId = commentDocRef.documentID;
      comment.setId(postCommentId);
      await commentDocRef.setData(comment.toJson())
      .catchError((e)=>print(e));
  }


  Future <void> updateLikesPost(String postId, String tagId,User liker) async {
    final Map<dynamic,dynamic> mapIdUserName = {liker.id : liker.userName};
    DocumentReference postDocRef = tagsRef.document(tagId).collection("TagsPost").document(postId);
    Firestore.instance.runTransaction((Transaction transaction) async {
    DocumentSnapshot postToUpdateSnapshot = await transaction.get(postDocRef);    //compte comme une lecture, voir si il y & pas moyen 
      if(postToUpdateSnapshot.exists){
        await transaction.update(
          postToUpdateSnapshot.reference,<String, dynamic>{
            "nbLikes" : postToUpdateSnapshot.data["nbLikes"] + 1,
            "likers" : FieldValue.arrayUnion([mapIdUserName]),
            "nbLikesNotSeen" : postToUpdateSnapshot.data["nbLikesNotSeen"] + 1
          }
        ).catchError((e)=> print(e));
      }
    });
  }

  Future<void> updatePostNbComments(String postId, String tagId,bool needToNotifyOwner) async {
    DocumentReference postDocRef = tagsRef.document(tagId).collection("TagsPost").document(postId);
    Firestore.instance.runTransaction((Transaction transaction) async {
    DocumentSnapshot postToUpdateSnapshot = await transaction.get(postDocRef);    //compte comme une lecture, voir si il y & pas moyen 
      if(postToUpdateSnapshot.exists){
        needToNotifyOwner?
        await transaction.update(
          postToUpdateSnapshot.reference,<String, dynamic>{
            "nbComments" : postToUpdateSnapshot.data["nbComments"] + 1,
            "nbCommentsNotSeen" : postToUpdateSnapshot.data["nbCommentsNotSeen"]+1
            }
        ).catchError((e)=> print(e))
        :
        await transaction.update(
          postToUpdateSnapshot.reference,<String, dynamic>{
            "nbComments" : postToUpdateSnapshot.data["nbComments"] + 1,
            }
        ).catchError((e)=> print(e));
      }
    });
  }

  Future<void> incrementNbCommentNotSeen(String postId, String markId) async {
    DocumentReference postDocRef = tagsRef.document(markId).collection("TagsPost").document(postId);
    Firestore.instance.runTransaction((Transaction transaction) async {
    DocumentSnapshot postToUpdateSnapshot = await transaction.get(postDocRef);    //compte comme une lecture, voir si il y & pas moyen 
      if(postToUpdateSnapshot.exists){
        await transaction.update(
          postToUpdateSnapshot.reference,<String, dynamic>{}
          ).catchError((e)=> print(e));
        }
      });
  }

  Future<void> updateLikeUserPost(String uid,String postId,String likerUserName, bool seen) async {
    DocumentReference postDocRef = userRef.document(uid).collection("UserPost").document(postId);
    Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentSnapshot postToUpdateSnapshot = await transaction.get(postDocRef);    //compte comme une lecture, voir si il y & pas moyen 
      if(postToUpdateSnapshot.exists){
        seen?
          await transaction.update(
            postToUpdateSnapshot.reference,<String, dynamic>{
              "lastLikeSeen" : seen,
              "timeStamp"       : timeStamp()
            }
          ).catchError((e)=> print(e))
        :
          await transaction.update(
            postToUpdateSnapshot.reference,<String, dynamic>{
              "lastLikeSeen" : seen,
              "lastLikerUserName" : likerUserName,
              "timeStamp"       : timeStamp()
            }
          ).catchError((e)=> print(e));
      }
    });
  }


  Future<void> updateCommentUserPost(String uid,String postId,Comment comment, bool seen) async {
    DocumentReference postDocRef = userRef.document(uid).collection("UserPost").document(postId);
    Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentSnapshot postToUpdateSnapshot = await transaction.get(postDocRef);    //compte comme une lecture, voir si il y & pas moyen 
      print(" ############ UPDATING USER POST ##########");
      if(postToUpdateSnapshot.exists){
        seen?
          await transaction.update(
            postToUpdateSnapshot.reference,<String, dynamic>{
              "lastCommentSeen" : seen,
              "timeStamp"       : timeStamp()
            }
          ).catchError((e)=> print(e))
        :
          await transaction.update(
            postToUpdateSnapshot.reference,<String, dynamic>{
              "lastCommentSeen" : seen,
              "lastCommentUserName" : comment.username,
              "lastComment" : comment.content,
              "timeStamp"       : timeStamp()
            }
          ).catchError((e)=> print(e));
      }
    });
  }

  Future<void> resetNbNotSeen(String postId, String markId,String field) async {
    DocumentReference postDocRef = tagsRef.document(markId).collection("TagsPost").document(postId);
    Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentSnapshot postToUpdateSnapshot = await transaction.get(postDocRef);    //compte comme une lecture, voir si il y & pas moyen 
      if(postToUpdateSnapshot.exists){
        await transaction.update(
          postToUpdateSnapshot.reference,<String, dynamic>{
            field : 0,
          }
        ).catchError((e)=> print(e));
      }
    });
  }

  

  Future<void> updateUserLastConnectionTime(String uid) async {
    //Cette fonction met à jour le champ lastConnectionTime du document user
      DocumentReference userDocRef = userRef.document(uid);
      Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentSnapshot userToUpdateSnapshot = await transaction.get(userDocRef);    //compte comme une lecture, voir si il y & pas moyen 
        if(userToUpdateSnapshot.exists){
          await transaction.update(
            userToUpdateSnapshot.reference,<String, dynamic>{
              "lastConnectionTime" : timeStamp(),
              }
          ).catchError((e)=> print(e));
        }
      });
    } 

    String timeStamp() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<void> sendMessageFirestore(String discussionId,String messageContent,User currentuser, User partner) async {
    DocumentReference discussionDocReference = discussionRef.document(discussionId).collection("Message").document();
    final Message message = Message(discussionDocReference.documentID,currentuser.id,messageContent,timeStamp());
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
      updateMarkNbMsg(message.tagOwnerId,"nbMessage",1);
    }
  
    Future<PublicMark> createTag(PublicMark tag) async {
      DocumentReference tagDocReference =  tagsRef.document();
      String tagId = tagDocReference.documentID;
      tag.setLastPostTimeStamp(timeStamp());
      GeoFirePoint userLocation = geoflutterfire.point(latitude: tag.lat,longitude: tag.long);
      tag.setId(tagId);
      await tagDocReference.setData(tag.toJson(userLocation.data)).catchError((e)=>print(e));
      return tag;
    }
  
    //TODO: une seule fonction update est nécéssaire

    Future<void> updateMarkNbFav(String markId,int arg) async {
      DocumentReference markToUpdateRef = tagsRef.document(markId);
      Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentSnapshot markToUpdateSnapshot = await transaction.get(markToUpdateRef);
        if(markToUpdateSnapshot.exists){
          await transaction.update(
            markToUpdateSnapshot.reference,<String, dynamic>
            {
              "nbFav" : markToUpdateSnapshot.data["nbFav"] + arg,
              "popularity" : markToUpdateSnapshot.data["nbFav"] + 10*arg,
            }
          ).catchError((e)=> print(e));
        }
      });
    }
  
    Future<void> updateMarkNbMsg(String markId,String newInfo,int arg) async {
      DocumentReference tagToUpdateRef = tagsRef.document(markId);
      Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentSnapshot tagToUpdateSnapshot = await transaction.get(tagToUpdateRef);
        if(tagToUpdateSnapshot.exists){
          await transaction.update(
            tagToUpdateSnapshot.reference,<String, dynamic>
            {
              newInfo : tagToUpdateSnapshot.data[newInfo] + arg,

            }
          ).catchError((e)=> print(e));
        }
      });
    }

    Future<void> updateMarksViews(String markId) async {
      DocumentReference markToUpdateRef = tagsRef.document(markId);
      Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentSnapshot markToUpdateSnapshot = await transaction.get(markToUpdateRef);
        if(markToUpdateSnapshot.exists){
          await transaction.update(
            markToUpdateSnapshot.reference,<String, dynamic>
            {
              "nbViews" : markToUpdateSnapshot.data["nbViews"] + 1,
              "popularity" : markToUpdateSnapshot.data["popularity"] + 1
            }
          ).catchError((e)=> print(e));
        }
      });
    }

    Future<void> updateUserNbMarks(User user) async {
      //Cette fonction met à jour le champ lastConnectionTime du document user
      DocumentReference userDocRef = userRef.document(user.id);
      Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentSnapshot userToUpdateSnapshot = await transaction.get(userDocRef);    //compte comme une lecture, voir si il y & pas moyen 
        if(userToUpdateSnapshot.exists){
          await transaction.update(
            userToUpdateSnapshot.reference,<String, dynamic>{
              "nbMarks" : user.nbMarks + 1,
              }
          ).catchError((e)=> print(e));
        }
      });
    } 

    

    Future<void> updateMarkImage(String markId,String newInfo,Post lastPost,int arg) async{
      //TODO: quand un utlisateur supprime son post, supprime aussi le post de la photo 
      //si c'était le dernier posté
      DocumentReference tagToUpdateRef = tagsRef.document(markId);
      Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentSnapshot tagToUpdateSnapshot = await transaction.get(tagToUpdateRef);
        if(tagToUpdateSnapshot.exists){
          print("----------- DEBUG UPDATEOLDTAGSIMAGE ------------"+tagToUpdateSnapshot.documentID);
          await transaction.update(
            tagToUpdateSnapshot.reference,<String, dynamic>
            {
              newInfo : tagToUpdateSnapshot.data[newInfo] + arg,
              "lastPostImageUrl" : lastPost.imageUrl,
              "lastPostImageWidth" : lastPost.imageWidth,
              "lastPostImageHeight" : lastPost.imageHeight,
              "lastPostTimeStamp" : lastPost.timeStamp,
              "popularity" : tagToUpdateSnapshot.data["popularity"] + 3*arg
            }
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

    Future<void> updateUserFavPost(User oldUser,String postId,int arg) async {
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


    /*void updateUserContacts(User currentUser,User partner,int arg){
      DocumentReference userToUpdateRef = userRef.document(currentUser.id);
      Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentSnapshot userToUpdateSnapshot = await transaction.get(userToUpdateRef);
        if(userToUpdateSnapshot.exists){
          arg==1 ? 
          await transaction.update(
           userToUpdateSnapshot.reference,<String, dynamic>{"contacts" : FieldValue.arrayUnion([partner.id]) }
          ).catchError((e)=> print(e))
          :
          await transaction.update(
           userToUpdateSnapshot.reference,<String, dynamic>{"contacts" : FieldValue.arrayRemove([partner.id]) }
          ).catchError((e)=> print(e));
        }
      });
    }*/

    Future<void> updateOldUserFavTags(User oldUser,String tagId,bool toAdd) async {
      DocumentReference userToUpdateRef = userRef.document(oldUser.id);
      Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentSnapshot userToUpdateSnapshot = await transaction.get(userToUpdateRef);
        if(userToUpdateSnapshot.exists){
          if(toAdd){
            await transaction.update(
              userToUpdateSnapshot.reference,<String, dynamic>{"favTagsId" : FieldValue.arrayUnion([tagId]) }
            ).catchError((e)=> print(e));
          }
          else{
            await transaction.update(
              userToUpdateSnapshot.reference,<String, dynamic>{"favTagsId" : FieldValue.arrayRemove([tagId]) }
              ).catchError((e)=> print(e));
          } 
        }
      });
    }
  
    
  
  
    Future<void> updateUser(User oldUser,String prenom,String nom, String userName,String bio)  async{      //rename updateProfileUser
      //Comparer a oldUser pour savoir ce qu'il faut changer exactement
      if(oldUser.prenom ==prenom && oldUser.nom==nom && oldUser.userName==userName && oldUser.bio==bio) return;
      print(userName);
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
  
  
    /*---------------------------------FirebaseAuth---------------------------------------*/
  
  
    final FirebaseAuth _auth =FirebaseAuth.instance;
  
  
    
  
  
    Future<FirebaseUser> signInUser (String mail, String passWord) async {
      //envoie un snpashot dans le stream onAuthChanged
      final FirebaseUser authResult = await _auth.signInWithEmailAndPassword(email: mail,password: passWord).catchError(
        (e){
          print("###### DEBUG SA PUTAIN DE RACE !!!!!!!! ############ : "+e.code.toString());
          AuthException error = e;
          print(error.code);
          }
        );
      //final FirebaseUser fbUser = authResult.user;
      return authResult;
    }
  
    Future<void> signOutUser(String uid) async {
      db.updateUserLastConnectionTime(uid);
      await _auth.signOut();
    }
  
    Future<FirebaseUser> createUser (String mail, String passWord,String nom,String prenom, String userName) async {
      final FirebaseUser authResult = await _auth.createUserWithEmailAndPassword(email: mail,password: passWord);
      //final FirebaseUser fbUser = authResult.user;
      String id =authResult.uid;
      final User user = User(mail,passWord,nom,prenom,id,userName,timeStamp());
      await db.createUserFirestore(user);
      return authResult;
    }
  
    Future<String> getCurrentUserId() async{
      FirebaseUser fbUser = await FirebaseAuth.instance.currentUser();
      return fbUser.uid;
    }
  
  
  
  
    Future<User> getCurrentUser(String uid) async{
      //final String currentUserId =await getCurrentUserId();
      DocumentReference currentUser = userRef.document(uid);
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
      final String userPhotoUrl = await _userRefStorage.child(uid).getDownloadURL();//.catchError(
        //(e)=> print(e)
      //);
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
 