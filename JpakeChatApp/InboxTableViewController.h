//
//  InboxTableViewController.h
//  Jpake
//
//  Created by Renu Srijith on 15/04/2016.
//  Copyright © 2016 newcastle university. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Firebase;
#import "User.h"

@interface InboxTableViewController : UITableViewController



@property(strong,nonatomic) User *currentUser;
@property(strong,nonatomic) User *otherUser;


@property(nonatomic,strong) NSMutableArray *users;
@property(nonatomic,strong) NSMutableArray *keys;
@property(nonatomic,strong)NSString* conversationId;

@property(nonatomic,strong )NSTimer *TimeOfActiveUser;
@property (assign,getter=isWorking) BOOL working;


- (IBAction)logout:(id)sender;

-(void)keyExchangeProcess;

//-(void)sendInitialPassword:(Firebase*)friendsRef keys:(Firebase*)keyRef otherUser:(NSString*)hisUsername ;
-(void)sendInitialPassword:(FIRDatabaseReference*)friendsRef
                      keys:(FIRDatabaseReference*)keyRef
                 otherUser:(NSString*)hisUsername
                     hisId:(NSString*)hisUSerID
           conversationRef:(FIRDatabaseReference*)conversationRef
                   chatKey:(NSString*)chatID;


-(void)getJpakeRound1Alice:(NSString*)pswd
                 otherUSer:(NSString *)
hisUSername keys:(FIRDatabaseReference*)keyRef;

-(void)sendInitialPasswordBob:(NSString*)key
                otherUserName:(NSString*)otherUsername
               FirebaseKeyRef:(FIRDatabaseReference*)keyRef
                PayloadString:(NSString*)payloadString;

-(void)getJPakeRound1Bob:(NSString*)pwd
            otherUserNme:(NSString*)otheruserName
           payloadString:(NSString*)payload
                  keyRef:(FIRDatabaseReference*)keyRef;

-(void)getJpakeRound2Alice:(NSString*)otherUserName
                    KeyRef:(FIRDatabaseReference*)keyRef
             payloadString:(NSString*)payload;

-(void)getJpakeRound2Bob:(NSString*)otherUserName
                  KeyRef:(FIRDatabaseReference*)keyRef
           payloadString:(NSString*)payload;

-(void)getJpakeRound3Bob:(NSString*)otherUserName
                  KeyRef:(FIRDatabaseReference*)keyRef
                 payload:(NSString*)payload;


-(void)validateJpakeround3Alice:(NSString*)otherUserName
                         KeyRef:(FIRDatabaseReference*)keyRef
                        payload:(NSString*)
payload ChatID:(NSString*)chatId;

-(void)errorManagement:(NSString* )title  message:(NSString*) message;
//-(void)coredataInitialise;




@end
