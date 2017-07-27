//
//  UserSettingViewController.m
//  JpakeChatApp
//
//  Created by Yuchi Zhang on 2017/5/28.
//  Copyright © 2017年 newcastle university. All rights reserved.
//

#import "UserSettingViewController.h"
@import FirebaseAuth;
#import "DataBasics.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import "NSString+SHA256.h"

@interface UserSettingViewController ()

@end

@implementation UserSettingViewController
@synthesize profileImageView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2;
    profileImageView.clipsToBounds = true;
    //self.databaseRef = [[FIRDatabase database] reference];
    self.storageRef = [[FIRStorage storage] reference];
    self.searchRef = [[FIRDatabase database] reference];
    [self loadProfileData];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    //Hide
    //self.passwordText.enabled = NO;
}


- (IBAction)getPhotoFromLibrary:(UIButton *)sender {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no photo library."
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        
    }
    else{
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.profileImageView.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)loadProfileData{
//    _databaseRef = [[FIRDatabase database] reference];
    [_LoaddataSpinner startAnimating];
    _databaseRef=[[DataBasics dataBasicsInstance]getUsersRef];
    NSString *Facebook = @"Facebook";
    NSString *Google = @"Google";
    [[FIRAuth auth] addAuthStateDidChangeListener:^(FIRAuth *auth, FIRUser *user) {
        //If user is current user
        if(user.uid == [DataBasics dataBasicsInstance].currentUser.uId) {
            //Get photo URL
            NSString *userID = [FIRAuth auth].currentUser.uid;
            [[[_searchRef child:@"users"] child:userID] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                if(!(snapshot.value == [NSNull null])){
                NSLog(@"loading data");
                    NSLog(@"snaposhot value is: %@",snapshot.value);
//                Get profile via facebookID!
//                NSString *FacebookId = [FBSDKAccessToken currentAccessToken].userID;
//                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", FacebookId]];
//                NSData *imageData = [NSData dataWithContentsOfURL:url];
//                self.profileImageView.image = [UIImage imageWithData:imageData];
                NSURL *url = [NSURL URLWithString:snapshot.value[@"photo"]];
                NSData *imageData = [NSData dataWithContentsOfURL:url];
                self.profileImageView.image = [UIImage imageWithData:imageData];
                NSLog(@"Photo loaded!");
                NSLog(@"URL is: %@", url);
                //load user name
                self.displayNameText.text = snapshot.value[@"username"];
                //If current user is third party user, do not change password
                if([snapshot.value[@"password"]  isEqualToString: Facebook] || [snapshot.value[@"password"]  isEqualToString: Google]){
                    self.passwordText.enabled = NO;
                    [self errorManagement:@"Third Party User" message:@"Cannot change your password"];
                }
                //If not, change password
                else{
                    self.passwordText.text = snapshot.value[@"password"];
                }
                [_LoaddataSpinner stopAnimating];
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                }
                else{
                    NSLog(@"No such user");
                    [_LoaddataSpinner stopAnimating];
                    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                }
            }];
                //snapshot value = null
            
                
            //user uid = current user uid
        }
             
        else {
            NSLog(@"Error user");
            [_LoaddataSpinner stopAnimating];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];

        }
    }];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];

    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.visibleViewController.navigationItem.title = @"User Setting";
    //self.tabBarController.navigationItem.leftBarButtonItem = nil;
    //[self loadProfileData];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
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

- (IBAction)saveProfile:(id)sender {
    //Before finish updating profile, ignore all interaction events
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [self updateUsersProfile];
}

- (IBAction)cancel:(id)sender {
    //[self loadProfileData];
    [self.view setNeedsDisplay];
    //[self dismissViewControllerAnimated:YES completion:nil];
}

-(void)updateUsersProfile{
    [_LoaddataSpinner startAnimating];
    [[FIRAuth auth] addAuthStateDidChangeListener:^(FIRAuth *auth, FIRUser *user) {
        //If user is current user
        if(user.uid == [DataBasics dataBasicsInstance].currentUser.uId && profileImageView.image != nil) {
            //FIRStorageRef
            FIRStorageReference *imageRef = [[_storageRef child:@"profile_images"]child:user.uid];
            //upload photo in the profileImageView
            UIImage *image =  profileImageView.image;
            NSData *newImage = UIImagePNGRepresentation(image);
            [imageRef putData:newImage metadata:nil completion:^(FIRStorageMetadata *metadata, NSError *error) {
                if(error != nil){
                    NSLog(@"error:%@", error);
                    [_LoaddataSpinner stopAnimating];
                    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                }
                else{
                    [imageRef downloadURLWithCompletion:^(NSURL *URL, NSError *error) {
                        if(error != nil){
                            NSLog(@"error:%@", error);
                            [_LoaddataSpinner stopAnimating];
                            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                        }
                        else{
                            //Create new dictionary object
                            NSString *profilePhotoURL = URL.absoluteString;
                            NSString *newUserName = self.displayNameText.text;
                            NSString *newPassword = [self.passwordText.text SHA256];
                            [_databaseRef observeSingleEventOfType:FIRDataEventTypeChildAdded  withBlock:^(FIRDataSnapshot *snapshot)
                            {
                                //If third party user
                                if([snapshot.value[@"password"]  isEqualToString: @"Facebook"] || [snapshot.value[@"password"]  isEqualToString: @"Google"])
                                {
                                    NSString *uid = [FIRAuth auth].currentUser.uid;
                                    NSDictionary *newProfile = @{
                                                                 @"username": newUserName,
                                                                 @"password": snapshot.value[@"password"],
                                                                 @"photo": profilePhotoURL
                                                                 };
                                    NSLog(@"newProfile %@",newProfile);
                                    [[_databaseRef child:uid] updateChildValues:newProfile withCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
                                        if(error != nil){
                                            NSLog(@"error: %@", error);
                                            [_LoaddataSpinner stopAnimating];
                                            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                                        }
                                        else{
                                            //After update, end ignoring interaction events
                                            NSLog(@"Profile successfully Update!");
                                            [_LoaddataSpinner stopAnimating];
                                            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                                        }
                                    }];
                                }
                                else{
                                    //Update username and photoURL
                                    NSString *uid = [FIRAuth auth].currentUser.uid;
                                    NSDictionary *newProfile = @{
                                                                 @"username": newUserName,
                                                                 @"password": newPassword,
                                                                 @"photo": profilePhotoURL
                                                                 };
                                    NSLog(@"newProfile %@",newProfile);
                                    [[_databaseRef child:uid] updateChildValues:newProfile withCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
                                        if(error != nil){
                                            NSLog(@"error: %@", error);
                                        }
                                        else{
                                            //After update, end ignoring interaction events
                                            NSLog(@"Username and Photo successfully Updated!");
                                            
                                        }
                                    }];
                                    //Update Password
                                    FIRUser *user = [FIRAuth auth].currentUser;
                                    [user updatePassword:newPassword completion:^(NSError *error) {
                                        if(error){
                                            NSLog(@"Error----Change password");
                                            [_LoaddataSpinner stopAnimating];
                                            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                                        }
                                        else{
                                            NSLog(@"Password changed");
                                            [_LoaddataSpinner stopAnimating];
                                            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                                        }
                                    }];
                                }
                            }];
                            
                        }
                    }];
                }
            }];
        }
    }];
}






@end
