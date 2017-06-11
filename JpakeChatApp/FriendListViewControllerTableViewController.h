//
//  FriendListViewControllerTableViewController.h
//  JpakeChatApp
//
//  Created by Yuchi Zhang on 2017/5/28.
//  Copyright © 2017年 newcastle university. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendListViewControllerTableViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addFriend;

- (IBAction)addFriend:(id)sender;
@end
