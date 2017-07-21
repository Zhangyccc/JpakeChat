//
//  FriendListViewControllerTableViewController.h
//  JpakeChatApp
//
//  Created by Yuchi Zhang on 2017/5/28.
//  Copyright © 2017年 newcastle university. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
@import Firebase;

@interface FriendListViewControllerTableViewController : UITableViewController

@property(nonatomic,strong) NSMutableArray *users;

@property(strong,nonatomic) User *currentUser;
@property(strong,nonatomic) User *otherUser;
@property(nonatomic,strong) FIRDatabaseReference *refforConVinId;
@property(nonatomic,strong) FIRDatabaseReference *refforconversation;
@property(nonatomic,strong) NSString* conversationId;
@property(nonatomic,strong) FIRDatabaseReference *ConversationRef;



@end
