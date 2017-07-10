//
//  DataBasics.m
//  Jpake
//
//  Created by Renu Srijith on 20/04/2016.
//  Copyright © 2016 newcastle university. All rights reserved.
//

#import "DataBasics.h"


@implementation DataBasics
-(id)init
{
    //self=[super init];
    // if(self){
    if (self = [super init]) {
        //self.ref=[[Firebase alloc]initWithUrl:@"https://securejpake.firebaseio.com"];
        self.ref = [[FIRDatabase database] reference];
    }
    
    return self;
}
+(DataBasics*)dataBasicsInstance{
    static DataBasics* myDatabasics=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        myDatabasics = [[self alloc] init];
    });
    return myDatabasics;
    
}

-(void)loginUserWithData:(FIRUser*) authData

{
    NSLog(@"authdata in daTA basics %@",authData.uid);
    self.currentUser = [[User alloc] initwithData:authData.email id:(authData.uid)];
    
    //    NSLog(@"from databaseics current user email %@ current user id %@",self.currentUser.userEmail,self.currentUser.uId);
    
}

-(FIRDatabaseReference*)getUsersRef
{
    return [self.ref child:@"users"];
}



-(FIRDatabaseReference*)pathToConversation:(NSString*)convId
{
    return [[self.ref child:@"conversations"]child:convId];
}




-(FIRDatabaseReference*)pathToUserConversation:(NSString*)user  otherUserID:(NSString*)otherUserId
{
    return [[[[self.ref child:@"users"]child:user]child:@"conversations"]child:otherUserId];
    
}

//
-(FIRDatabaseReference*)getConversationsRef{
    return [self.ref child:@"conversations"];
}


-(FIRDatabaseReference*)getMyUserConversation:(NSString*)uid
{
    return [[[self.ref child:@"users" ]child:uid]child:@"conversations"];
    
}



//-(Firebase*)pathToConversation:(NSString*)convId
//{
//    return [[self.ref childByAppendingPath:@"conversations"]childByAppendingPath:convId];
//}


-(FIRDatabaseReference*)pathToFriends:(NSString*)chatId
{
    return [[self.ref child:@"friends"]child:chatId];
    
}
-(FIRDatabaseReference*)pathToKeys:(NSString*)chatId
{
    return [[self.ref child:@"keys"]child:chatId];
    
}






-(FIRDatabaseReference*)getKeysRef{
    return [self.ref child:@"keys"];
}

-(FIRDatabaseReference*)getFriendsRef{
    return [self.ref child:@"friends"];
    
}
-(FIRDatabaseReference*)getConnectionsRef:(NSString*)userId
{
    return [[[self.ref child:@"users"]child:userId] child:@"connections"];
}
-(void)sendMessage:(JSQMessage*) msg convID:(NSString*)convId macTag:(NSString*)mtag  iv:(NSString*)iv{
    
    
    
    //    let messagesRef = ref.childByAppendingPath("conversations/\(toChat)")
    FIRDatabaseReference *msgRef= [[self.ref child:@"conversations"]child:convId];
    NSDictionary *newUser = @{
                              @"text": msg.text,
                              @"sender": msg.senderId,
                              @"displayName": msg.senderDisplayName,
                              @"macTag":mtag,
                              @"iv":iv
                              };
    [[msgRef childByAutoId]setValue:newUser];
    
    
}


@end
