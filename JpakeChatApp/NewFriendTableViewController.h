//
//  NewFriendTableViewController.h
//  JpakeChatApp
//
//  Created by Yuchi Zhang on 2017/6/15.
//  Copyright © 2017年 newcastle university. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
@import Firebase;

@interface NewFriendTableViewController : UITableViewController

@property(strong,nonatomic) User *currentUser;
@property(strong,nonatomic) User *otherUser;
@property(nonatomic,strong) FIRDatabaseReference *ref;
@property(nonatomic,strong) FIRDatabaseReference *ConversationRef;


@property(nonatomic,strong) NSMutableArray *users;
@property(nonatomic,strong) NSMutableArray *keys;

@property(nonatomic,strong) NSString* NewFriendId;
@property(nonatomic,strong) NSString* conversationId;

@property(nonatomic,strong )NSTimer *TimeOfActiveUser;
@property (assign,getter=isWorking) BOOL working;

@end
