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

@property(nonatomic,strong) NSMutableArray *users;
@property(nonatomic,strong) NSString* NewFriendId;


@end
