//
//  NewFriendTableViewController.m
//  JpakeChatApp
//
//  Created by Yuchi Zhang on 2017/6/15.
//  Copyright © 2017年 newcastle university. All rights reserved.
//

#import "NewFriendTableViewController.h"
#import <FirebaseAuth/FirebaseAuth.h>
@import Firebase;
#import "DataBasics.h"

@interface NewFriendTableViewController ()

@end

@implementation NewFriendTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _ref =[[FIRDatabase database] reference];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.users count];
}

-(void) viewWillAppear:(BOOL)animated{
    self.navigationController.visibleViewController.navigationItem.title = @"User";
    self.title = @"User ";
    [[FIRAuth auth] addAuthStateDidChangeListener:^(FIRAuth *auth, FIRUser *user) {
        if (user) {
            [[DataBasics dataBasicsInstance] loginUserWithData:user];
            self.currentUser=[DataBasics dataBasicsInstance].currentUser;
        } else {
            NSLog(@"No user is signed in.");
        }
    }];
    
    self.users=[[NSMutableArray alloc]init ];
    self.currentUser=[DataBasics dataBasicsInstance].currentUser;
    NSLog(@"current user uid %@",self.currentUser.uId);
    
    
    FIRDatabaseReference * ref1=[[DataBasics dataBasicsInstance]getUsersRef] ;
    [[ref1 queryOrderedByKey] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        
        if([snapshot.key isEqualToString:_NewFriendId])
        {
            User *uobj=[[User alloc]initwithData:snapshot.value[@"email"] id:snapshot.key];
            [self.users addObject:uobj];
            [self.tableView reloadData];
        }
        
    }];
}





- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    User *usr=self.users [indexPath.row];
    
    //cell.textLabel.font=[UIFont systemFontOfSize:14.0];
    cell.textLabel.text=usr.userEmail;
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
//    User *otherUser=[self.users objectAtIndex:indexPath.row];
//    self.otherUser=otherUser;
//    
//    //check whther there is already any conversations between these users
//    NSString *myUserID=[DataBasics dataBasicsInstance].currentUser.uId;
//    NSString *hisUSerID=otherUser.uId;
//    NSString *hisUserName=otherUser.userEmail;
//    
//    
//    FIRDatabaseReference *conversationRef =[[DataBasics dataBasicsInstance]pathToUserConversation:myUserID otherUserID:hisUSerID];
//    
//    NSLog(@"myuserID: %@ hisuserID: %@",myUserID,hisUSerID);
//    [conversationRef observeSingleEventOfType:FIRDataEventTypeValue
//     
//                                    withBlock:^(FIRDataSnapshot *snapshot) {
//                                        if (snapshot.value == [NSNull null])
//                                            //                        if (!snapshot.exists)
//                                        {
//                                            
//                                            NSString *newConversationRefKey=[[[DataBasics dataBasicsInstance]getConversationsRef]childByAutoId].key;
//                                            FIRDatabaseReference *friend=[[DataBasics dataBasicsInstance]pathToFriends:newConversationRefKey];
//                                            FIRDatabaseReference *key=[[DataBasics dataBasicsInstance]pathToKeys:newConversationRefKey];
//                                            
//                                            //Add details to friends Table
//                                            
//                                            self.conversationId=newConversationRefKey;
//                                            
//                                            //
//                                            
//                                            [self.TimeOfActiveUser invalidate];
//                                            
//                                            [self sendInitialPassword:friend keys:key otherUser:hisUserName hisId:hisUSerID conversationRef:conversationRef chatKey:newConversationRefKey];
//                                            [self startTimer];
//                                        }
//                                        
//                                        //Else check friends table and see if the Pflg is 0 then send an alert saying keyexchange not done
//                                        else { //else3
//                                            //NSLog(@"Snapshot.vlaue %@",snapshot.value[@"chatId"]);
//                                            NSString* chatId=snapshot.value[@"chatId"];
//                                            self.conversationId=chatId;
//                                            FIRDatabaseReference * ref1=[[DataBasics dataBasicsInstance]pathToFriends:chatId];
//                                            
//                                            [ref1 observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot1) {
//                                                if (snapshot1.value == [NSNull null]){
//                                                    //                                if (!snapshot1.exists){
//                                                    NSLog(@"Error in friends Addition ");
//                                                }
//                                                else//else2
//                                                {
//                                                    if ([snapshot1.value[@"Pflag"] isEqual: @0] ){
//                                                        NSLog(@"Key Exchange not yet completed ");
//                                                        NSString* title=@"Key Exchange not yet completed!!";
//                                                        NSString*msg = @"Wait until successful Key exchange completion";
//                                                        
//                                                        [self errorManagement:title message:msg];
//                                                    }
//                                                    else //else1
//                                                        
//                                                    {
//                                                        
//                                                        if ([snapshot1.value[@"Pflag"] isEqual: @1]) {
//                                                            //perform segue
//                                                            
//                                                            
//                                                            [self performSegueWithIdentifier:@"showChat" sender:self];
//                                                            
//                                                        }
//                                                        
//                                                    }//else1
//                                                }//else2
//                                            }];
//                                        }//else 3
//                                    }];
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


@end
