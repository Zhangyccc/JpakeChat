//
//  ChatVCTableViewController.h
//  JpakeChatApp
//
//  Created by Renu Srijith on 01/06/2016.
//  Copyright © 2016 newcastle university. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import <Firebase.h>

#import "JSQMessagesViewController.h"
#import "JSQMessages.h"



@interface ChatVCTableViewController : JSQMessagesViewController

@property(strong,nonatomic)User *currentUser;
@property(strong,nonatomic) User *otherUser;



@property(strong,nonatomic) NSString *key;
@property(strong,nonatomic) NSString *kenc;
@property(strong,nonatomic) NSData *kencData;
@property(strong,nonatomic) NSString *kmac;
@property(strong,nonatomic) NSData *kmacData;

@property(strong,nonatomic) Firebase *conversationRef;
@property(strong,nonatomic) NSString *conversationId;
//@property(strong,nonatomic) NSString *senderId;

@property(strong,nonatomic) NSMutableArray *msgArray;


@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;

-(void)checkForMsges:(User*)otherUser;
-(void)loadMessagesForConversation:(NSString*)convID;

//- (NSString *) encryptString:(NSString*)plaintext withKey:(NSString*)key;
- (NSString *) encryptString:(NSString*)plaintext withKey:(NSString*)key withIV:(NSData*)ivString;
- (NSString *) decryptString:(NSString *)ciphertext withKey:(NSString*)key withIV:(NSData*)iVString;





@end
