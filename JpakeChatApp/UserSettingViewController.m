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


@interface UserSettingViewController ()

@end

@implementation UserSettingViewController
@synthesize profileImageView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2;
    profileImageView.clipsToBounds = true;
    self.databaseRef = [[FIRDatabase database] reference];
    self.storageRef = [[FIRStorage storage] reference];
    [self loadProfileData];
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
        if(user.uid == [DataBasics dataBasicsInstance].currentUser.uId) {
            [_databaseRef observeSingleEventOfType:FIRDataEventTypeChildAdded  withBlock:^(FIRDataSnapshot *snapshot) {
                NSLog(@"loading data");
//                Get profile via facebookID!
//                NSString *FacebookId = [FBSDKAccessToken currentAccessToken].userID;
//                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", FacebookId]];
//                NSData *imageData = [NSData dataWithContentsOfURL:url];
//                self.profileImageView.image = [UIImage imageWithData:imageData];
                NSURL *url = [NSURL URLWithString:snapshot.value[@"photo"]];
                NSData *imageData = [NSData dataWithContentsOfURL:url];
                self.profileImageView.image = [UIImage imageWithData:imageData];
                self.displayNameText.text = snapshot.value[@"username"];
                if([snapshot.value[@"password"]  isEqualToString: Facebook] || [snapshot.value[@"password"]  isEqualToString: Google]){
                    //self.passwordText.text = snapshot.value[@"password"];
                    //self.passwordText = FALSE;
                    self.passwordText.enabled = NO;
                    [self errorManagement:@"Third Party User" message:@"Cannot change your password"];
                }
                else{
                    self.passwordText.text = snapshot.value[@"password"];
                }
                [_LoaddataSpinner stopAnimating];
                
            }];
        }
        else {
            NSLog(@"Error user");
            [_LoaddataSpinner stopAnimating];
        }
    }];
    
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
//    [_LoaddataSpinner startAnimating];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [self updateUsersProfile];
//    [_LoaddataSpinner stopAnimating];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)updateUsersProfile{
    [_LoaddataSpinner startAnimating];
    //Disable all input during spinner animating!
//    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [[FIRAuth auth] addAuthStateDidChangeListener:^(FIRAuth *auth, FIRUser *user) {
        if(user.uid == [DataBasics dataBasicsInstance].currentUser.uId && profileImageView.image != nil) {
            FIRStorageReference *imageRef = [[_storageRef child:@"profile_images"]child:user.uid];
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
                            NSString *profilePhotoURL = URL.absoluteString;
                            NSString *newUserName = self.displayNameText.text;
                            NSString *newPassword = self.passwordText.text;
                            [_databaseRef observeSingleEventOfType:FIRDataEventTypeChildAdded  withBlock:^(FIRDataSnapshot *snapshot)
                            {
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
                                            NSLog(@"Profile successfully Update!");
                                            [_LoaddataSpinner stopAnimating];
                                            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                                        }
                                    }];
                                }
                                else{
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
                                            [_LoaddataSpinner stopAnimating];
                                            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                                        }
                                        else{
                                            NSLog(@"Profile successfully Update!");
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
