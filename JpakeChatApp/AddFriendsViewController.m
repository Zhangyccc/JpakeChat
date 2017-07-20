//
//  AddFriendsViewController.m
//  
//
//  Created by Yuchi Zhang on 2017/6/12.
//
//

#import "NewFriendTableViewController.h"
#import "AddFriendsViewController.h"
#import "DataBasics.h"
#import <objc/runtime.h>
@import Firebase;
#import <FirebaseAuth/FirebaseAuth.h>
#import "User.h"


@interface AddFriendsViewController ()

@end

@implementation AddFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ref = [[FIRDatabase database] reference];
    self.ref1=[[DataBasics dataBasicsInstance]getUsersRef] ;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)AddFriendAction:(id)sender {
    //NSString *friendemail=[self.FriendEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *friendemail = [self.FriendEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *Myemail = [FIRAuth auth].currentUser.email;
    NSLog(@"Current user email: %@", Myemail);
    NSLog(@"Textfield email: %@", friendemail);
    __block NSString *frienduid;
    //static NSInteger flag = 0;
    
    //If friend mail = nil
    if([friendemail length]==0){
        NSLog(@"Friend email length == 0");
        [self EmailError:@"Email Error !! " message:@"Make sure you enter a valid username and password !! "];
    }
    //If add muself
    else if([Myemail isEqualToString: friendemail]){
        NSLog(@"Can not add yourself");
        [self EmailError:@"Can not add yourself !! " message:@"Make sure you enter a valid email address !! "];
    }
    //Check if user exists
    //ref1= getuserref ref= databaseref
    else{
        [[[[_ref child:@"users"] queryOrderedByChild:@"email" ] queryEqualToValue:friendemail] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshotforuser) {
//            if(!(snapshotforuser.exists)){
            if(snapshotforuser.value == [NSNull null]){
                NSLog(@"No such user!");
                [self EmailError:@"No such user !! " message:@"Make sure you enter a correct email address !! "];
            }
            else{
                //Get user uid
                [[[[_ref child:@"users"] queryOrderedByChild:@"email"] queryEqualToValue:friendemail] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *  snapshotforuid) {
                frienduid = snapshotforuid.key;
                    //Pass value to NewFriendUid that will be given to NewFriendViewController!
                    _NewFriendUid = frienduid;
                NSLog(@"Friend uid is: %@", frienduid);
                NSLog(@"snapshotforuser value is: %@", snapshotforuser.value);
                [self.navigationController popToRootViewControllerAnimated:YES];
                [self performSegueWithIdentifier:@"ToUserList" sender:self];
                }];
            }
        }];
    }
}
//        [[[[_ref child:@"users"] queryOrderedByChild:@"email" ] queryEqualToValue:friendemail]
//         observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshotforuser) {
//             if(!(snapshotforuser.exists)){
//                 NSLog(@"No such user");
//                 [self EmailError:@"No such user !! " message:@"Make sure you enter a correct email address !! "];
//             }
//             else{
//                 [[[[_ref child:@"users"] queryOrderedByChild:@"email"] queryEqualToValue:friendemail]
//                 observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *  snapshotforuid) {
//                     frienduid = snapshotforuid.key;
//                     NSLog(@"snapshot value is: %@", snapshotforuid.value);
//                     NSLog(@"friend uid is: %@", frienduid);
//                     NSLog(@"Find user!");
//                     [[_ref1 queryOrderedByKey] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
//                         NSLog(@"user uid: %@", snapshot.key);
//                         if([snapshot.key isEqualToString:frienduid] ){
//                             NSLog(@"Find user");
////                             NewFriendTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"NewFriend"];
////                             User *uobj=[[User alloc]initwithData:snapshot.value[@"email"] id:snapshot.key];
////                             [self.users addObject:uobj];
////                             [vc.tableView reloadData];
//                             //[self presentViewController:vc animated:YES completion:nil];
//                         }
//                         else{
//                             NSLog(@"Searching!");
//                         }
//                     }];//_ref1
//                 }];//else snapshotforuid
//             }//else
//         }];//else snapshotforuser
//    }    //ELSE
//}//IBACTION




//[[[[_ref child:@"users"] queryOrderedByChild:@"email" ] queryEqualToValue:friendemail]
// observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshotforuid) {
//     if(snapshotforuid.exists){
//         frienduid = snapshotforuid.key;
//         //NSLog(@"%@", frienduid);
//         NSLog(@"snapshot value is: %@", snapshotforuid.value);
//         NSLog(@"friend uid is: %@", frienduid);
//         NSLog(@"Found user!");
//     }
//     else{
//         NSLog(@"No such user");
//         [self EmailError:@"No such user !! " message:@"Make sure you enter a correct email address !! "];
//     }
// }];

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"ToUserList"]){
        UINavigationController *navigationController = segue.destinationViewController;
        NewFriendTableViewController *NewFriendViewcontroller = (NewFriendTableViewController *)navigationController.topViewController;
        NewFriendViewcontroller.NewFriendId=self.NewFriendUid;
        NewFriendViewcontroller.otherUser=self.otherUser;
        NewFriendViewcontroller.currentUser=self.currentUser;
        NewFriendViewcontroller.conversationId=self.conversationId;
    }
    
}

-(void)EmailError:(NSString* )title  message:(NSString*) message
{
    
    UIAlertController *alert= [UIAlertController
                               alertControllerWithTitle:title
                               message:message
                               preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                               handler:nil];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                   handler:nil];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}
@end
