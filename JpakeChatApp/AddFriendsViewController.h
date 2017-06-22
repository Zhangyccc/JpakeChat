//
//  AddFriendsViewController.h
//  
//
//  Created by Yuchi Zhang on 2017/6/12.
//
//

#import <UIKit/UIKit.h>
@import Firebase;

@interface AddFriendsViewController : UIViewController

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) FIRDatabaseReference *ref1;
@property (weak, nonatomic) IBOutlet UITextField *FriendEmail;
@property(nonatomic,strong) NSMutableArray *users;
@property(nonatomic,strong )NSTimer *TimeOfActiveUser;
@property (assign,getter=isWorking) BOOL working;

- (IBAction)AddFriendAction:(id)sender;

@end
