//
//  FriendListViewControllerTableViewController.m
//  JpakeChatApp
//
//  Created by Yuchi Zhang on 2017/5/28.
//  Copyright © 2017年 newcastle university. All rights reserved.
//
#import "ChatVCTableViewController.h"
#import "FriendListViewControllerTableViewController.h"
#import "User.h"
@import Firebase;
#import "DataBasics.h"

@interface FriendListViewControllerTableViewController ()

@end

@implementation FriendListViewControllerTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    _refforconversation= [[FIRDatabase database] reference];
    _refforConVinId = [[DataBasics dataBasicsInstance] getMyUserConversation:[FIRAuth auth].currentUser.uid];
    //[self GetFriends];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.visibleViewController.navigationItem.title = @"Friend List";
    
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
    NSLog(@"NewFriendTableViewController -> current user uid %@",self.currentUser.uId);
    [self GetFriends];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}
#pragma mark - Table view data source



-(void)GetFriends{
    //Get chatId
    [[_refforConVinId queryOrderedByKey] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        //        chatId = snapshot.value[@"chatId"];
        //        NSLog(@"snapshot value is: %@", snapshot.value);
        //        NSLog(@"chatID is: %@", chatId);
        __block NSString *chatId = nil;
        if(snapshot.value == [NSNull null]){
            NSLog(@"No added friends");
        }
        else{
            NSLog(@"Find user!");
            NSLog(@"chatId is: %@",snapshot.value[@"chatId"]);
            chatId = snapshot.value[@"chatId"];
            
            //Get receiver and senders' name
            _refforconversation = [[DataBasics dataBasicsInstance]pathToKeys:chatId];
            [_refforconversation observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshotforuser) {
                //NSLog(@"snapshot value is:  %@",snapshotforuser.value);
                NSLog(@"snapshot key is: %@", snapshotforuser.key);
                if(!(snapshotforuser.exists)){
                    NSLog(@"No added Friends");
                }
                //Keyexchange process not complete
                else if(snapshotforuser.value[@"validatedFlag"] == 0){
                    NSLog(@"Keyexchange process not complete!");
                }
                else{
                    __block NSString *receiverEmail = nil;
                    __block NSString *senderEmail = nil;
                    receiverEmail = snapshotforuser.value[@"receiver"];
                    senderEmail = snapshotforuser.value[@"sender"];
                    if([receiverEmail isEqualToString:[FIRAuth auth].currentUser.email]){
                        //Get UID
                        FIRDatabaseReference * ref1=[[DataBasics dataBasicsInstance]getUsersRef] ;
                        __block NSString *userId = nil;
                        
                        //Search user
                        [ref1 observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshotforuid) {
                            
                            if(!(snapshotforuid.exists))
                            {
                                NSLog(@"Error in uid");
                            }
                            else if([snapshotforuid.value[@"email"] isEqualToString:senderEmail]){
                                NSLog(@"snapshotforuid key is: %@",snapshotforuid.key);
                                userId = snapshotforuid.key;
                                //Add User
                                User *uobj=[[User alloc]initwithData:senderEmail id:userId];
                                [self.users addObject:uobj];
                                [self.tableView reloadData];
                            }
                        }];

                        //NSLog(@"snapshotforuid key is: %@",userId);
                        
                    }
                    else if([senderEmail isEqualToString:[FIRAuth auth].currentUser.email]){
                        //Get UID
                        FIRDatabaseReference * ref2=[[DataBasics dataBasicsInstance]getUsersRef] ;
                        __block NSString *userId = nil;
                        
                        //Search user
                        [ref2 observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshotforuid) {
                            
                            if(!(snapshotforuid.exists))
                            {
                                NSLog(@"Error in uid");
                            }
                            else if([snapshotforuid.value[@"email"] isEqualToString:receiverEmail]){
                                NSLog(@"snapshotforuid key is: %@",snapshotforuid.key);
                                userId = snapshotforuid.key;
                                //Add User
                                User *uobj=[[User alloc]initwithData:receiverEmail id:userId];
                                [self.users addObject:uobj];
                                [self.tableView reloadData];
                            }
                        }];
                       
                    }
                    else{
                        NSLog(@"Unknow error in searching friends");
                    }
                }
            }];
        }
        //Get chatId
    }];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.users count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    User *usr=self.users [indexPath.row];
    cell.textLabel.text=usr.userEmail;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    User *otherUser=[self.users objectAtIndex:indexPath.row];
    self.otherUser=otherUser;
    
    //    //check whther there is already any conversations between these users
    NSString *myUserID=[FIRAuth auth].currentUser.uid;
    //his ID wrong!!
    NSString *hisUSerID=otherUser.uId;
    //NSString *hisUserName=otherUser.userEmail;
    
    FIRDatabaseReference *conversationRef =[[DataBasics dataBasicsInstance]pathToUserConversation:myUserID otherUserID:hisUSerID];
    
    NSLog(@"myuserID: %@ hisuserID: %@",myUserID,hisUSerID);
    [conversationRef observeSingleEventOfType:FIRDataEventTypeValue
     
                                    withBlock:^(FIRDataSnapshot *snapshot) {
                                        if (snapshot.value == [NSNull null])
                                            //                        if (!snapshot.exists)
                                        {
                                            NSLog(@"Wrong Friend ");
                                            NSString* title=@"Unknown error";
                                            NSString*msg = @"Please contact admin";
                                            
                                            [self errorManagement:title message:msg];
                                        }
                                        
                                        //Else check friends table and see if the Pflg is 0 then send an alert saying keyexchange not done
                                        else { //else3
                                            //NSLog(@"Snapshot.vlaue %@",snapshot.value[@"chatId"]);
                                            NSString* chatId=snapshot.value[@"chatId"];
                                            self.conversationId=chatId;
                                            _ConversationRef = [[DataBasics dataBasicsInstance]pathToFriends:chatId];
                                            
                                            [_ConversationRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot1) {
                                                if (snapshot1.value == [NSNull null]){
                                                    //                                if (!snapshot1.exists){
                                                    NSLog(@"Error in friends Addition ");
                                                }
                                                else//else2
                                                {
                                                    if ([snapshot1.value[@"Pflag"] isEqual: @0] ){
                                                        NSLog(@"Wrong Friend ");
                                                        NSString* title=@"Unknown error";
                                                        NSString*msg = @"Please contact admin";
                                                        
                                                        [self errorManagement:title message:msg];
                                                    }
                                                    else //else1
                                                        
                                                    {
                                                        
                                                        if ([snapshot1.value[@"Pflag"] isEqual: @1]) {
                                                            //perform segue
                                                            NSLog(@"Loading");
                                                            //[self errorManagement:title message:msg];
                                                            //From AddFriendViewController to ShowConversation
                                                            [self performSegueWithIdentifier:@"ListToChat" sender:self];
                                                            
                                                        }
                                                        
                                                    }//else1
                                                }//else2
                                            }];
                                        }//else 3
                                    }];
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    
    ChatVCTableViewController *cTableViewcontroller= (ChatVCTableViewController*)segue.destinationViewController;
    
    cTableViewcontroller.otherUser=self.otherUser;
    cTableViewcontroller.currentUser=self.currentUser;
    cTableViewcontroller.conversationId=self.conversationId;
    
    
    
    
}



-(void)errorManagement:(NSString* )title  message:(NSString*) message
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
