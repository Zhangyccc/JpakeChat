//
//  DataBasics.h
//  Jpake
//
//  Created by Renu Srijith on 20/04/2016.
//  Copyright © 2016 newcastle university. All rights reserved.
//
//This is the class which handles the firebase calls

#import <Foundation/Foundation.h>
#import <Firebase.h>
#import "User.h"
#import <JSQMessages.h>

@interface DataBasics : NSObject{}

@property(nonatomic,strong) FIRDatabaseReference *ref;
@property(nonatomic,strong) User* currentUser;



+(DataBasics*)dataBasicsInstance;



-(void)loginUserWithData:(FIRUser*) authData;
-(FIRDatabaseReference*)getUsersRef;









-(FIRDatabaseReference*)getConversationsRef;
-(FIRDatabaseReference*)getKeysRef;
-(FIRDatabaseReference*)getFriendsRef;



-(FIRDatabaseReference*)pathToConversation:(NSString*)convId;
-(FIRDatabaseReference*)pathToFriends:(NSString*)chatId;

-(FIRDatabaseReference*)pathToKeys:(NSString*)chatId;

-(FIRDatabaseReference*)pathToUserConversation:(NSString*)user  otherUserID:(NSString*)otherUserId;

-(FIRDatabaseReference*)getConnectionsRef:(NSString*)userId;

-(FIRDatabaseReference*)getMyUserConversation:(NSString*)uid;


//-(void)sendMessage:(JSQMessage*) msg convID:(NSString*)convId;
-(void)sendMessage:(JSQMessage*) msg convID:(NSString*)convId macTag:(NSString*)mtag  iv:(NSString*)iv;





@end
