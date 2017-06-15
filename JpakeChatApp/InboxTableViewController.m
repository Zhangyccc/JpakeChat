//
//  InboxTableViewController.m
//  Jpake
//
//  Created by Renu Srijith on 15/04/2016.
//  Copyright © 2016 newcastle university. All rights reserved.
//
#import "LoginViewController.h"
#import "InboxTableViewController.h"
#import "NSString+SHA256.h"
#import "DataBasics.h"
#import "theCoreDataStack.h"
#import "BigInteger.h"
#import "jpakeKey.h"

#import "jpakeparticipant.h"

#import "JpakeRound1Payload.h"
#import "JpakeRound2Payload.h"
#import "JpakeRound3Payload.h"

#import "JKey.h"
#import "JParticipant.h"
#import "ChatVCTableViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <GoogleSignIn/GoogleSignIn.h>


@interface InboxTableViewController ()

@end

@implementation InboxTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"Documents Directory: %@", [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
    //Firebase *ref = [[Firebase alloc] initWithUrl:@"https://securejpake.firebaseio.com"];
    //FIRDatabaseReference *ref = [[FIRDatabase database] reference];
    
    
    //[self coredataInitialise];
    //NEW OBSERVE
    [[FIRAuth auth] addAuthStateDidChangeListener:^(FIRAuth * _Nonnull auth, FIRUser * _Nullable user) {
        if (user) {
            NSLog(@"User is signed in with uid: %@", user.uid);
            [[DataBasics dataBasicsInstance] loginUserWithData:user];
            self.currentUser = [DataBasics dataBasicsInstance].currentUser;
        } else {
            NSLog(@"No user is signed in.");
        }
    }];
    
    //OLD OBSERVE
    //    [ref observeAuthEventWithBlock:^(FAuthData *authData) {
    //        if (authData) {
    //            // user authenticated
    //                [[DataBasics dataBasicsInstance] loginUserWithData:authData];
    //            self.currentUser=[DataBasics dataBasicsInstance].currentUser ;
    //
    //        } else {
    //            // No user is signed in
    //            NSLog(@"inside login vC  no user signed in ");
    //        }
    //    }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    
//    self.tabBarController.navigationItem.leftBarButtonItem = nil;
//}
//-(void)coredataInitialise{
//    theCoreDataStack *coreDataStack=[theCoreDataStack defaultStack];
//    
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"JParticipant" inManagedObjectContext:coreDataStack.managedObjectContext];
//    
//    
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    [request setEntity:entity];
//    
//    NSError *error;
//    NSArray *objects = [coreDataStack.managedObjectContext executeFetchRequest:request
//                                                                         error:&error];
//    
//    for (NSManagedObject *object in objects)
//    {
//        [coreDataStack.managedObjectContext deleteObject:object];
//        NSLog(@"deleted participant ");
//        
//    }
//    [coreDataStack.managedObjectContext save:&error];
//    //
//    
//    
//    NSEntityDescription *entity1 = [NSEntityDescription entityForName:@"JKey" inManagedObjectContext:coreDataStack.managedObjectContext];
//    
//    
//    NSFetchRequest *request1 = [[NSFetchRequest alloc] init];
//    [request1 setEntity:entity1];
//    
//    NSError *error1;
//    NSArray *objects1 = [coreDataStack.managedObjectContext executeFetchRequest:request1
//                                                                          error:&error1];
//    
//    for (NSManagedObject *object in objects1)
//    {
//        [coreDataStack.managedObjectContext deleteObject:object];
//        NSLog(@"deleted key s");
//        
//    }
//    [coreDataStack.managedObjectContext save:&error1];
//    
//    //
//}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    //self.tabBarController.navigationItem.leftBarButtonItem = nil;
    self.navigationController.visibleViewController.navigationItem.title = @"Conversations";
    //self.title = @"Conversations ";
    //Firebase *ref = [[Firebase alloc] initWithUrl:@"https://securejpake.firebaseio.com"];
    //FIRDatabaseReference *ref = [[FIRDatabase database] reference];
    
    //NEW OBSERVE
    [[FIRAuth auth] addAuthStateDidChangeListener:^(FIRAuth * _Nonnull auth, FIRUser * _Nullable user) {
        if (user) {
            NSLog(@"User is signed in with uid: %@", user.uid);
            [[DataBasics dataBasicsInstance] loginUserWithData:user];
//            self.currentUser=[DataBasics dataBasicsInstance].currentUser;
        } else {
            NSLog(@"No user is signed in.");
        }
    }];
    
    //OLD OBSERVE
    //        [ref observeAuthEventWithBlock:^(FAuthData *authData) {
    //            if (authData) {
    //                // user authenticated
    //                    [[DataBasics dataBasicsInstance] loginUserWithData:authData];
    //                self.currentUser=[DataBasics dataBasicsInstance].currentUser ;
    //
    //            } else {
    //                // No user is signed in
    //
    //            }
    //        }];
    
    
    self.users=[[NSMutableArray alloc]init ];
    self.currentUser=[DataBasics dataBasicsInstance].currentUser;
    NSLog(@"current user uid %@",self.currentUser.uId);
    FIRDatabaseReference * ref1=[[DataBasics dataBasicsInstance]getUsersRef] ;
    [[ref1 queryOrderedByKey] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        
        if(!([snapshot.key isEqualToString:[DataBasics dataBasicsInstance].currentUser.uId]))
        {
            User *uobj=[[User alloc]initwithData:snapshot.value[@"email"] id:snapshot.key];
            [self.users addObject:uobj];
            [self.tableView reloadData];
        }
        
    }];
    
    [self startTimer];
    
}

-(void )startTimer{
    
    self.working = TRUE;
    if(self.working )
    {
        self.TimeOfActiveUser = [NSTimer scheduledTimerWithTimeInterval:10.0  target:self selector:@selector(keyExchangeProcess) userInfo:nil repeats:YES];
        
    }
}
-(void)keyExchangeProcess


{
    NSLog(@"keyExchange Process");
    
    //NSString *myId=[DataBasics dataBasicsInstance].currentUser.uId;
    NSString *myId=self.currentUser.uId;
    NSLog(@"MyID inside keyexchange %@",myId);
    FIRDatabaseReference * refkey=[[DataBasics dataBasicsInstance]getMyUserConversation:myId];
    NSLog(@"refkey %@",refkey);
    
    [[refkey queryOrderedByKey] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot)
     {
         if (!(snapshot.value == [NSNull null]))
         {            NSLog(@"snapshot insd ");
             
             [self.keys addObject:snapshot.value[@"chatId"]];
             NSString *chatId=snapshot.value[@"chatId"];
             FIRDatabaseReference *keyDb =[[DataBasics dataBasicsInstance]pathToKeys:chatId];
             [[keyDb queryOrderedByKey]observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot1) {
                 
                 NSString *hisName=snapshot1.value[@"sender"];
                 //Debug hisName == Firebase?????????????
                 //NSLog(@"hisname %@",hisName);
                 NSString *payload=snapshot1.value[@"payload"];
                 NSString  *myName=snapshot1.value[@"receiver"];
                 if(![snapshot1.value[@"sender"] isEqualToString:[DataBasics dataBasicsInstance].currentUser.userEmail]) // sender is not the current user
                 {
                     
                     if([snapshot1.value[@"validatedFlag"] isEqualToNumber:@0] )
                     {
                         
                         NSLog(@"hisname %@",hisName);
                         NSLog(@"myname %@",myName);
                         if([snapshot1.value [@"round"] isEqualToNumber:@1] && [snapshot1.value[@"senderNameTag"] isEqualToString:@"alice"])
                         {

                             [self.TimeOfActiveUser invalidate];
                             //
                             [self sendInitialPasswordBob:chatId otherUserName:hisName FirebaseKeyRef:keyDb PayloadString:payload];
                             
                             [self startTimer];
 
                         }//if of round
                         if([snapshot1.value [@"round"] isEqualToNumber:@1] && [snapshot1.value[@"senderNameTag"] isEqualToString:@"bob"])
                         {
                             [self.TimeOfActiveUser invalidate];
                             
                             NSLog(@"getJPake Round2alice");
                             [self getJpakeRound2Alice:hisName KeyRef:keyDb payloadString:payload];
                             [self startTimer];

                         }
                         if([snapshot1.value [@"round"] isEqualToNumber:@2] && [snapshot1.value[@"senderNameTag"] isEqualToString:@"alice"])
                         {
                             [self.TimeOfActiveUser invalidate];
                             
                             [self getJpakeRound2Bob:hisName KeyRef:keyDb payloadString:payload];
                             [self startTimer];
                             
                         }
                         
                         if([snapshot1.value [@"round"] isEqualToNumber:@2] && [snapshot1.value[@"senderNameTag"] isEqualToString:@"bob"])
                         { [self.TimeOfActiveUser invalidate];
                             
                             [self getJpakeAliceKeyGenerationRound3:hisName KeyRef:keyDb payload:payload];
                             [self startTimer];
                             
                         }
                         
                         if([snapshot1.value [@"round"] isEqualToNumber:@3] && [snapshot1.value[@"senderNameTag"] isEqualToString:@"alice"])
                             //[self getJpakeround3Bob:sender payload:payload];
                         { [self.TimeOfActiveUser invalidate];
                             
                             [self getJpakeRound3Bob:hisName KeyRef:keyDb payload:payload];
                             [self startTimer];
                             
                             
                         }
                         
                         if([snapshot1.value [@"round"] isEqualToNumber:@3] && [snapshot1.value[@"senderNameTag"] isEqualToString:@"bob"])
                             
                         {
                             [self.TimeOfActiveUser invalidate];
                             
                             [self validateJpakeround3Alice:hisName KeyRef:keyDb payload:payload ChatID:chatId];
                             [self startTimer];
                             
                             
                         }
                     }//if of validation flag
                 } // if of sender snapshot
             }];//KEYDB
         }//if value not is nsnull
     }];//refkey block completion
    
    
    
}


-(void)validateJpakeround3Alice:(NSString*)otherUserName   KeyRef:(FIRDatabaseReference*)keyRef payload:(NSString*)
payload ChatID:(NSString*)chatId
{
    NSLog(@"inside Jpake Round3 Alice validation part ");
    BigInteger *keyingMaterial=[[BigInteger alloc]initWithInt32:0];
    NSString *presentUser=self.currentUser.userEmail;
    
    theCoreDataStack *coreDataStack=[theCoreDataStack defaultStack];
    //Get the stored key value !!
    NSEntityDescription *entityKey = [NSEntityDescription entityForName:@"JKey" inManagedObjectContext:coreDataStack.managedObjectContext];
    
    
    NSFetchRequest *requestKey = [[NSFetchRequest alloc] init];
    [requestKey setEntity:entityKey];
    NSPredicate *predKey =[NSPredicate predicateWithFormat:@"%K == %@ AND  %K == %@",@"toName",otherUserName,@"myName",presentUser];
    [requestKey  setPredicate:predKey];
    
    NSSortDescriptor *sortDescriptorkey = [NSSortDescriptor sortDescriptorWithKey:@"toName" ascending:YES];
    
    [requestKey setSortDescriptors:@[sortDescriptorkey]];
    
    NSError *error1;
    NSArray *objectsKey = [coreDataStack.managedObjectContext executeFetchRequest:requestKey
                                                                            error:&error1];
    if ([objectsKey count] == 1)
//    if (true)
    {
        NSLog(@"inside key obects count for keydatabase--1");
        for(NSManagedObject *object in objectsKey)
            
        {
            NSLog(@"Getting alice key call  class");
            
            
            
            NSError *err1;
            NSString* keyString=[object valueForKey:@"key"];
            
            NSData *keyData = [[NSData alloc] initWithBase64EncodedString:keyString options:0];
            jpakeKey *keyValue=[NSKeyedUnarchiver unarchiveTopLevelObjectWithData:keyData error:&err1];
            keyingMaterial=[keyValue getKeyingMaterial];
            
        }
        
        
    }
    
    
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"JParticipant" inManagedObjectContext:coreDataStack.managedObjectContext];
    
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    
    
    
    
    NSPredicate *pred =[NSPredicate predicateWithFormat:@"%K == %@ AND  %K == %@",@"toName",otherUserName,@"myName",presentUser];
    
    
    //    NSPredicate *pred =[NSPredicate predicateWithFormat:@"%K == %@",@"receiver",sender.username];
    
    [request setPredicate:pred];
    
    NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"toName" ascending:YES];
    
    [request setSortDescriptors:@[sortDescriptor1]];
    
    
    
    NSError *error;
    NSArray *objects = [coreDataStack.managedObjectContext executeFetchRequest:request
                                                                         error:&error];
    
    if ([objects count] == 1)
        
    {
        NSLog(@"inside obects count alice participant --1");
        for(NSManagedObject *object in objects)
            
        {
            NSLog(@"Getting alice participant class");
            
            
            NSData *aliceParticipant=[object valueForKey:@"data"];
            NSError *Err=nil;
            jpakeparticipant *alice=[NSKeyedUnarchiver unarchiveTopLevelObjectWithData:aliceParticipant error:&Err];
            
            NSError *err1=nil;
            NSData *payloadData = [[NSData alloc] initWithBase64EncodedString:payload options:0];
            JpakeRound3Payload *bobr3=[NSKeyedUnarchiver unarchiveTopLevelObjectWithData:payloadData error:&err1];
            
            [alice validateRound3Payloadreceived:bobr3 keyingmaterial:keyingMaterial];
            
            //Add PFLg to 1 in friends
            
            NSDictionary *keyExchange =
            @{
              @"sender": presentUser,
              @"receiver":otherUserName,
              @"payload":@"",
              @"round":@3,
              @"validatedFlag":@1,
              @"senderNameTag":@"alice"
              };
            
            NSLog(@"keyExchange %@",keyExchange);
            [keyRef setValue:keyExchange];
            
            
            FIRDatabaseReference * ref1=[[DataBasics dataBasicsInstance]pathToFriends:chatId];
            [ref1 observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot1) {
                if (snapshot1.value == [NSNull null]){
                    NSLog(@"Error in friends Addition ");
                    
                }
                else//else2
                {
                    if ([snapshot1.value[@"Pflag"] isEqual: @0] ){
                        NSDictionary *newUser =
                        @{
                          @"pswdHash": @"",
                          @"Pflag": @1
                          };
                        [ref1 setValue:newUser];
                        
                    }
                }
                
            }];
            
            
            NSData* aliceBack=[NSKeyedArchiver archivedDataWithRootObject:alice];
            [object setValue:aliceBack forKey:@"data"];
            [coreDataStack.managedObjectContext save:&error];
            
        }
    }
    
    
    
    
}
-(void)getJpakeRound3Bob:(NSString*)otherUserName   KeyRef:(FIRDatabaseReference*)keyRef payload:(NSString*)payload

{
    NSLog(@"inside Jpake Round3 bob ");
    BigInteger *keyingMaterial=[[BigInteger alloc]initWithInt32:0];
    NSString *presentUser=self.currentUser.userEmail;
    
    theCoreDataStack *coreDataStack=[theCoreDataStack defaultStack];
    //Get the stored key value !!
    NSEntityDescription *entityKey = [NSEntityDescription entityForName:@"JKey" inManagedObjectContext:coreDataStack.managedObjectContext];
    
    
    NSFetchRequest *requestKey = [[NSFetchRequest alloc] init];
    [requestKey setEntity:entityKey];
    NSPredicate *predKey =[NSPredicate predicateWithFormat:@"%K == %@ AND  %K == %@",@"toName",otherUserName,@"myName",presentUser];
    [requestKey  setPredicate:predKey];
    
    NSSortDescriptor *sortDescriptorkey = [NSSortDescriptor sortDescriptorWithKey:@"toName" ascending:YES];
    
    [requestKey setSortDescriptors:@[sortDescriptorkey]];
    
    NSError *error1;
    NSArray *objectsKey = [coreDataStack.managedObjectContext executeFetchRequest:requestKey
                                                                            error:&error1];
    if ([objectsKey count] == 1)
        
    {
        NSLog(@"inside key obects count --1");
        for(NSManagedObject *object in objectsKey)
            
        {
            NSLog(@"Getting bob participant class");
            NSString* keyString=[object valueForKey:@"key"];
            
            NSData *keyData = [[NSData alloc] initWithBase64EncodedString:keyString options:0];
            NSError *err1;
            jpakeKey *keyValue=[NSKeyedUnarchiver unarchiveTopLevelObjectWithData:keyData error:&err1];
            keyingMaterial=[keyValue getKeyingMaterial];
            
        }
    }
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"JParticipant" inManagedObjectContext:coreDataStack.managedObjectContext];
    
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    
    
    
    
    NSPredicate *pred =[NSPredicate predicateWithFormat:@"%K == %@ AND  %K == %@",@"toName",otherUserName,@"myName",presentUser];
    
    
    //    NSPredicate *pred =[NSPredicate predicateWithFormat:@"%K == %@",@"receiver",sender.username];
    
    [request setPredicate:pred];
    
    NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"toName" ascending:YES];
    
    [request setSortDescriptors:@[sortDescriptor1]];
    
    
    
    NSError *error;
    NSArray *objects = [coreDataStack.managedObjectContext executeFetchRequest:request
                                                                         error:&error];
    
    if ([objects count] == 1)
        
    {
        NSLog(@"inside obects count --1 %@",objects);
        
        for(NSManagedObject *object in objects)
            
        {
            
            NSData *bobParticipant=[object valueForKey:@"data"];
            NSLog(@"bobparticiapnt %@",bobParticipant);
            NSError *Err=nil;
            jpakeparticipant *bob=[NSKeyedUnarchiver unarchiveTopLevelObjectWithData:bobParticipant error:&Err];
            NSLog(@"bob Paricipant Received %@",bob);
            NSError *err1=nil;
            NSData *payloadData = [[NSData alloc] initWithBase64EncodedString:payload options:0];
            NSLog(@"jsut before create aliceR3");
            JpakeRound3Payload *alicer3=[NSKeyedUnarchiver unarchiveTopLevelObjectWithData:payloadData error:&err1];
            NSLog(@"jsut before create bobr3");
            
            JpakeRound3Payload *bobr3=[bob createRound3toSend:keyingMaterial];
            
            NSLog(@"jsut before validation ");
            
            [bob validateRound3Payloadreceived:alicer3 keyingmaterial:keyingMaterial];
            
            
            NSLog(@"jsut afetr  validaiton ");
            
            NSData *data=[NSKeyedArchiver archivedDataWithRootObject:bobr3];
            
            NSString *payString=[data base64EncodedStringWithOptions:0];
            
            
            
            
            NSDictionary *keyExchange =
            @{
              @"sender": presentUser,
              @"receiver":otherUserName,
              @"payload":payString,
              @"round":@3,
              @"validatedFlag":@0,
              @"senderNameTag":@"bob"
              };
            
            NSLog(@"keyExchange %@",keyExchange);
            [keyRef setValue:keyExchange];
            
            
            NSData* bobback=[NSKeyedArchiver archivedDataWithRootObject:bob];
            [object setValue:bobback forKey:@"data"];
            [coreDataStack.managedObjectContext save:&error];
            
        }
    }
    
    
    
}
-(void)getJpakeAliceKeyGenerationRound3:(NSString*)otherUserName   KeyRef:(FIRDatabaseReference*)keyRef payload:(NSString*)payload

{
    NSLog(@"inside aliceValidationkeygeneration");
    BigInteger *keyingMaterial=[[BigInteger alloc]initWithInt32:0];
    
    
    theCoreDataStack *coreDataStack=[theCoreDataStack defaultStack];
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"JParticipant" inManagedObjectContext:coreDataStack.managedObjectContext];
    
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    
    NSString *presentUser=self.currentUser.userEmail;
    
    
    NSPredicate *pred =[NSPredicate predicateWithFormat:@"%K == %@ AND  %K == %@",@"toName",otherUserName,@"myName",presentUser];
    
    
    //    NSPredicate *pred =[NSPredicate predicateWithFormat:@"%K == %@",@"receiver",sender.username];
    
    [request setPredicate:pred];
    
    NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"toName" ascending:YES];
    
    [request setSortDescriptors:@[sortDescriptor1]];
    
    
    
    NSError *error;
    NSArray *objects = [coreDataStack.managedObjectContext executeFetchRequest:request
                                                                         error:&error];
    
    if ([objects count] == 1)
        
    {
        NSLog(@"inside obects count --1");
        for(NSManagedObject *object in objects)
            
        {
            NSLog(@"Getting Alice participant class");
            
            
            NSData *aliceParticipant=[object valueForKey:@"data"];
            NSError *Err=nil;
            jpakeparticipant *alice=[NSKeyedUnarchiver unarchiveTopLevelObjectWithData:aliceParticipant error:&Err];
            NSLog(@"Alice  %@",alice);
            NSError *err1=nil;
            NSData *payloadData = [[NSData alloc] initWithBase64EncodedString:payload options:0];
            JpakeRound2Payload *bobr2=[NSKeyedUnarchiver unarchiveTopLevelObjectWithData:payloadData error:&err1];
            [alice validadateRound2PayloadReceived:bobr2];
            keyingMaterial=[alice calculateKeyingMaterial];
            
            JpakeRound3Payload *aliceround3=[alice createRound3toSend:keyingMaterial];
            NSData *data=[NSKeyedArchiver archivedDataWithRootObject:aliceround3];
            //  [self createKeyExchange:sender round:@3 data:data senderNameTag:@"alice"];
            
            NSString *payString=[data base64EncodedStringWithOptions:0];
            NSDictionary *keyExchange =
            @{
              @"sender": presentUser,
              @"receiver":otherUserName,
              @"payload":payString,
              @"round":@3,
              @"validatedFlag":@0,
              @"senderNameTag":@"alice"
              };
            
            
            [keyRef setValue:keyExchange];
            
            
            NSData* aliceBack=[NSKeyedArchiver archivedDataWithRootObject:alice];
            [object setValue:aliceBack forKey:@"data"];
            [coreDataStack.managedObjectContext save:&error];
            
        }
    }
    
    //Add the keyingmaterial entity for BOB
    jpakeKey *key=[[jpakeKey alloc]initWithkeyingMaterial:keyingMaterial];
    NSData *keyData=[NSKeyedArchiver archivedDataWithRootObject:key];
    NSString *keyString=[keyData base64EncodedStringWithOptions:0];
    
    NSLog(@"keyString %@",keyString);
    
    JKey *entry=[NSEntityDescription insertNewObjectForEntityForName:@"JKey" inManagedObjectContext:coreDataStack.managedObjectContext];
    entry.key=keyString;
    entry.myName=presentUser;
    entry.toName=otherUserName;
    [coreDataStack saveContext];
    
    
    //Adding PFlag to 1 in Friends table
    
    
    
}

-(void)getJpakeRound2Bob:(NSString*)otherUserName KeyRef:(FIRDatabaseReference*)keyRef payloadString:(NSString*)payload{
    
    {
        
        NSLog(@"inside Jpake Round2 bob ");
        BigInteger *keyingMaterial=[[BigInteger alloc]initWithInt32:0];
        
        theCoreDataStack *coreDataStack=[theCoreDataStack defaultStack];
        
        NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"JParticipant" inManagedObjectContext:coreDataStack.managedObjectContext];
        
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDesc];
        
        
        NSString *presentUser=self.currentUser.userEmail;
        
        
        NSPredicate *pred =[NSPredicate predicateWithFormat:@"%K == %@ AND  %K == %@",@"toName",otherUserName,@"myName",presentUser];
        
        
        //    NSPredicate *pred =[NSPredicate predicateWithFormat:@"%K == %@",@"receiver",sender.username];
        
        [request setPredicate:pred];
        
        NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"toName" ascending:YES];
        
        [request setSortDescriptors:@[sortDescriptor1]];
        
        
        
        NSError *error;
        NSArray *objects = [coreDataStack.managedObjectContext executeFetchRequest:request
                                                                             error:&error];
        
        if ([objects count] == 1)
            
        {
            NSLog(@"inside obects count --1");
            for(NSManagedObject *object in objects)
                
            {
                NSLog(@"Getting bob participant class");
                
                
                NSData *bobParticipant=[object valueForKey:@"data"];
                NSError *Err=nil;
                jpakeparticipant *bob=[NSKeyedUnarchiver unarchiveTopLevelObjectWithData:bobParticipant error:&Err];
                
                NSError *err1=nil;
                NSData *payloadData = [[NSData alloc] initWithBase64EncodedString:payload options:0];
                JpakeRound2Payload *alicer2=[NSKeyedUnarchiver unarchiveTopLevelObjectWithData:payloadData error:&err1];
                JpakeRound2Payload *bobr2=[bob createRound2toSend];
                [bob validadateRound2PayloadReceived:alicer2];
                
                
                //
                keyingMaterial=[bob calculateKeyingMaterial];
                
                NSData *data=[NSKeyedArchiver archivedDataWithRootObject:bobr2];
                //  [self createKeyExchange:sender round:@2 data:data senderNameTag:@"bob"];
                
                NSString *payString=[data base64EncodedStringWithOptions:0];
                
                
                
                NSDictionary *keyExchange =
                @{
                  @"sender": presentUser,
                  @"receiver":otherUserName,
                  @"payload":payString,
                  @"round":@2,
                  @"validatedFlag":@0,
                  @"senderNameTag":@"bob"
                  };
                [keyRef setValue:keyExchange];
                
                
                
                NSData* bobback=[NSKeyedArchiver archivedDataWithRootObject:bob];
                [object setValue:bobback forKey:@"data"];
                [coreDataStack.managedObjectContext save:&error];
                
            }
        }
        
        //Add the keyingmaterial entity for BOB
        jpakeKey *key=[[jpakeKey alloc]initWithkeyingMaterial:keyingMaterial];
        NSData *keyData=[NSKeyedArchiver archivedDataWithRootObject:key];
        NSString *keyString=[keyData base64EncodedStringWithOptions:0];
        
        NSLog(@"key string in Bob %@",keyString);
        
        
        JKey *entry=[NSEntityDescription insertNewObjectForEntityForName:@"JKey" inManagedObjectContext:coreDataStack.managedObjectContext];
        entry.key=keyString;
        
        entry.myName=presentUser;
        entry.toName=otherUserName;
        [coreDataStack saveContext];
        
        
    }
    
}


-(void)getJpakeRound2Alice:(NSString*)otherUserName KeyRef:(FIRDatabaseReference*)keyRef payloadString:(NSString*)payload{
    
    
    NSLog(@"inside Jpake Round2 alice ");
    theCoreDataStack *coreDataStack=[theCoreDataStack defaultStack];
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"JParticipant" inManagedObjectContext:coreDataStack.managedObjectContext];
    
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSString *presentUser=self.currentUser.userEmail;
    NSLog(@"inside getJpake Rond2 Persendt user %@",presentUser);
    NSLog(@"inside getJpake Rond2 Persendt user %@",otherUserName);
    
    NSPredicate *pred =[NSPredicate predicateWithFormat:@"%K == %@ AND  %K == %@",@"toName",otherUserName,@"myName",presentUser];
    [request setPredicate:pred];
    
    NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"toName" ascending:YES];
    
    [request setSortDescriptors:@[sortDescriptor1]];
    
    
    
    
    NSError *error;
    NSArray *objects = [coreDataStack.managedObjectContext executeFetchRequest:request
                                                                         error:&error];
    
    if ([objects count] == 1)
        
    {
        NSLog(@"inside objects count --1");
        for(NSManagedObject *object in objects)
            
        {
            NSLog(@"Getting Alice participant class");
            
            
            NSData *aliceParticipant=[object valueForKey:@"data"];
            
            NSError *Err=nil;
            jpakeparticipant *alice=[NSKeyedUnarchiver unarchiveTopLevelObjectWithData:aliceParticipant error:&Err];
            
            NSLog(@"Alice participant %@",alice);
            NSError *err1=nil;
            NSData *payloadData = [[NSData alloc] initWithBase64EncodedString:payload options:0];
            
            JpakeRound1Payload *bobr1=[NSKeyedUnarchiver unarchiveTopLevelObjectWithData:payloadData error:&err1];
            [alice validadateRound1PayloadReceived:bobr1];
            
            
            
            JpakeRound2Payload *alicer2=[alice createRound2toSend];
            NSData *data=[NSKeyedArchiver archivedDataWithRootObject:alicer2];
            
            
            NSString *payString=[data base64EncodedStringWithOptions:0];
            
            
            
            NSDictionary *keyExchange =
            @{
              @"sender": presentUser,
              @"receiver":otherUserName,
              @"payload":payString,
              @"round":@2,
              @"validatedFlag":@0,
              @"senderNameTag":@"alice"
              };
            [keyRef setValue:keyExchange];
            
            
            NSData* aliceback=[NSKeyedArchiver archivedDataWithRootObject:alice];
            [object setValue:aliceback forKey:@"data"];
            [coreDataStack.managedObjectContext save:&error];
            
        }
        
    }
}



-(void)getJPakeRound1Bob:(NSString*)pwd otherUserNme:(NSString*)otheruserName payloadString:(NSString*)payload  keyRef:(FIRDatabaseReference*)keyRef
{
    NSLog(@"getJPake round1 Bob by bob ");
    
    NSString *currentUsername=[DataBasics dataBasicsInstance ].currentUser.userEmail;
    jpakeparticipant *bob=[[jpakeparticipant alloc]initWithParticipantId:@"bob" password:pwd];
    
    NSError *err1=nil;
    //Convert paylaod string to nsdata
    NSData *payloadData = [[NSData alloc] initWithBase64EncodedString:payload options:0];
    JpakeRound1Payload *alicer1=[NSKeyedUnarchiver unarchiveTopLevelObjectWithData:payloadData error:&err1];
    JpakeRound1Payload *r1bob=[bob createRound1toSend];
    [bob validadateRound1PayloadReceived:alicer1];
    
    NSData *bob1=[NSKeyedArchiver archivedDataWithRootObject:bob];
    
    
    //Add jpakeParticiant Bob to coredata
    
    
    theCoreDataStack *coreDataStack=[theCoreDataStack defaultStack];
    JParticipant *entry=[NSEntityDescription insertNewObjectForEntityForName:@"JParticipant" inManagedObjectContext:coreDataStack.managedObjectContext];
    entry.data=bob1;
    entry.myName=currentUsername;
    entry.toName=otheruserName;
    [coreDataStack saveContext];
    
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:r1bob];
    NSString *payString=[data base64EncodedStringWithOptions:0];
    
    NSDictionary *keyExchange =
    @{
      @"sender": currentUsername,
      @"receiver":otheruserName,
      @"payload":payString,
      @"round":@1,
      @"validatedFlag":@0,
      @"senderNameTag":@"bob"
      };
    [keyRef setValue:keyExchange];
    
    
    
    
    
}

-(void)getJpakeRound1Alice:(NSString*)pswd otherUSer:(NSString *) hisUSername keys:(FIRDatabaseReference*)keyRef
{
    
    NSLog(@"getJpake Round1 alice ");
    
    jpakeparticipant *alice=[[jpakeparticipant alloc]initWithParticipantId:@"alice" password:pswd];
    JpakeRound1Payload *r1alice=[alice createRound1toSend];
    
    
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:r1alice];
    
    NSData *alice1=[NSKeyedArchiver archivedDataWithRootObject:alice];
    //Add jpakeParticiant Alice to coredata
    
    
    theCoreDataStack *coreDataStack=[theCoreDataStack defaultStack];
    JParticipant *entry=[NSEntityDescription insertNewObjectForEntityForName:@"JParticipant" inManagedObjectContext:coreDataStack.managedObjectContext];
    entry.data=alice1;
    entry.myName=[DataBasics dataBasicsInstance].currentUser.userEmail;
    entry.toName=hisUSername;
    [coreDataStack saveContext];
    
    NSString *stringForm = [data base64EncodedStringWithOptions:0];
    
    
    
    NSDictionary *keyExchange =
    @{
      @"sender": [DataBasics dataBasicsInstance].currentUser.userEmail,
      @"receiver":hisUSername,
      @"payload":stringForm,
      @"round":@1,
      @"validatedFlag":@0,
      @"senderNameTag":@"alice"
      };
    
    [keyRef setValue:keyExchange];
    
    
    
}


//The First step
-(void)sendInitialPasswordBob:(NSString*)key otherUserName:(NSString*)otherUsername FirebaseKeyRef:(FIRDatabaseReference*)keyRef  PayloadString:(NSString*)payloadString
{
    NSLog(@"send initial password to BOB");
    NSString *msg=[NSString stringWithFormat:@"%@/%@", @"Enter the shared secret to ", otherUsername];
    UIAlertController *alert= [UIAlertController
                               alertControllerWithTitle:@"Password"
                               message:msg
                               preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action){
                                                   //Do Some action here
                                                   UITextField *textField = alert.textFields[0];
                                                   NSString *pswd=textField.text;
                                                   NSString *pHash=[pswd SHA256];
                                                   
                                                   FIRDatabaseReference * refF=[[DataBasics dataBasicsInstance]pathToFriends:key];
                                                   [refF observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot1) {
                                                       
                                                       if(![pHash isEqualToString:snapshot1.value[@"pswdHash"]]){
                                                           NSLog(@"Password mismatches ,Check Again ");
                                                           
                                                           NSString* title=@"Shared secret mismatches !";
                                                           NSString*msg = @"Confirm the shared secret once again !!";
                                                           
                                                           [self errorManagement:title message:msg];
                                                           
                                                           
                                                       }//if password mismatches
                                                       else
                                                       {
                                                           //Send bob round 1
                                                           
                                                           [self getJPakeRound1Bob:pswd otherUserNme:otherUsername payloadString:payloadString keyRef:keyRef];
                                                           
                                                       }
                                                       
                                                       
                                                   }];
                                                   
                                                   
                                                   
                                               }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style: UIAlertActionStyleCancel
                                                   handler:
                             ^(UIAlertAction * action) {
                                 
                                 NSLog(@"cancel btn");
                                 
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"shared Secret";
        textField.keyboardType = UIKeyboardTypeDefault;
    }];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    
    
    
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.users count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    User *usr=self.users [indexPath.row];
    
    //cell.textLabel.font=[UIFont systemFontOfSize:14.0];
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
//    cell.textLabel.layer.borderColor = [[UIColor grayColor] CGColor];
//    cell.textLabel.layer.borderWidth = 2;
    cell.textLabel.text=usr.userEmail;
    //cell.textLabel.text.UTF8String = usr.userEmail;
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    User *otherUser=[self.users objectAtIndex:indexPath.row];
    self.otherUser=otherUser;
    
    //check whther there is already any conversations between these users
    NSString *myUserID=[DataBasics dataBasicsInstance].currentUser.uId;
    NSString *hisUSerID=otherUser.uId;
    NSString *hisUserName=otherUser.userEmail;
    
    
    FIRDatabaseReference *conversationRef =[[DataBasics dataBasicsInstance]pathToUserConversation:myUserID otherUserID:hisUSerID];
    
    NSLog(@"myuserID: %@ hisuserID: %@",myUserID,hisUSerID);
    [conversationRef observeSingleEventOfType:FIRDataEventTypeValue
     
                    withBlock:^(FIRDataSnapshot *snapshot) {
                        if (snapshot.value == [NSNull null])
                        {
                            
                            NSString *newConversationRefKey=[[[DataBasics dataBasicsInstance]getConversationsRef]childByAutoId].key;
                            FIRDatabaseReference *friend=[[DataBasics dataBasicsInstance]pathToFriends:newConversationRefKey];
                            FIRDatabaseReference *key=[[DataBasics dataBasicsInstance]pathToKeys:newConversationRefKey];
                            
                            //Add details to friends Table
                            
                            self.conversationId=newConversationRefKey;
                            
                            //
                            
                            [self.TimeOfActiveUser invalidate];
                            
                            [self sendInitialPassword:friend keys:key otherUser:hisUserName hisId:hisUSerID conversationRef:conversationRef chatKey:newConversationRefKey];
                            [self startTimer];
                        }
                        
                        //Else check friends table and see if the Pflg is 0 then send an alert saying keyexchange notdone
                        else { //else3
                            //NSLog(@"Snapshot.vlaue %@",snapshot.value[@"chatId"]);
                            NSString* chatId=snapshot.value[@"chatId"];
                            self.conversationId=chatId;
                            FIRDatabaseReference * ref1=[[DataBasics dataBasicsInstance]pathToFriends:chatId];
                            
                            [ref1 observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot1) {
                                if (snapshot1.value == [NSNull null]){
                                    NSLog(@"Error in friends Addition ");
                                }
                                else//else2
                                {
                                    if ([snapshot1.value[@"Pflag"] isEqual: @0] ){
                                        NSLog(@"Key Exchange not yet completed ");
                                        NSString* title=@"Key Exchange not yet completed!!";
                                        NSString*msg = @"Wait until successful Key exchange completion";
                                        
                                        [self errorManagement:title message:msg];
                                    }
                                    else //else1
                                        
                                    {
                                        
                                        if ([snapshot1.value[@"Pflag"] isEqual: @1]) {
                                            //perform segue
                                            
                                            
                                            [self performSegueWithIdentifier:@"showChat" sender:self];
                                            
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

-(void)sendInitialPassword:(FIRDatabaseReference*)friendsRef  keys:(FIRDatabaseReference*)keyRef otherUser:(NSString*)hisUsername
                     hisId:(NSString*)hisUSerID conversationRef:(FIRDatabaseReference*)conversationRef chatKey:(NSString*)chatID
{
    UIAlertController *alert= [UIAlertController
                               alertControllerWithTitle:@"Password"
                               message:@"Enter the shared secret"
                               preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action){
                                                   //Do Some action here
                                                   UITextField *textField = alert.textFields[0];
                                                   
                                                   NSString *pswd=textField.text;
                                                   NSString *pswdHash=[pswd SHA256];
                                                   
                                                   NSDictionary *newUser =
                                                   @{
                                                     @"pswdHash": pswdHash,
                                                     @"Pflag": @0
                                                     };
                                                   [friendsRef setValue:newUser];
                                                   
                                                   NSDictionary *conversation =
                                                   @{
                                                     @"chatId": chatID
                                                     };
                                                   [conversationRef setValue:conversation];
                                                   
                                                   NSString *myUserID=[DataBasics dataBasicsInstance].currentUser.uId;
                                                   FIRDatabaseReference *secondUserConversation =[[DataBasics dataBasicsInstance]pathToUserConversation:hisUSerID otherUserID:myUserID];
                                                   
                                                   [secondUserConversation setValue:conversation];
                                                   
                                                   [self getJpakeRound1Alice:pswd otherUSer:hisUsername keys:keyRef];
                                                   
                                                   
                                                   
                                               }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                   handler:
                             ^(UIAlertAction * action) {
                                 
                                 NSLog(@"cancel btn");
                                 
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"shared Secret";
        textField.keyboardType = UIKeyboardTypeDefault;
    }];
    
    [self presentViewController:alert animated:YES completion:nil];
}



- (IBAction)logout:(id)sender
{
    
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"uid"];
    //Firebase *ref = [[Firebase alloc] initWithUrl:@"https://securejpake.firebaseio.com"];
    //FIRDatabaseReference *ref = [[FIRDatabase database] reference];
    //Fireabase logout
    [[FIRAuth auth] signOut:nil];
    //[ref unauth];
    //Facebook logout
    FBSDKAccessToken.currentAccessToken = nil;
    //Google logout
    [[GIDSignIn sharedInstance] signOut];
    
    LoginViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"Login"];
    
    [self presentViewController:vc animated:YES completion:nil];
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
