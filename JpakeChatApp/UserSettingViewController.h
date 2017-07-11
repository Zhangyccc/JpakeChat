//
//  UserSettingViewController.h
//  JpakeChatApp
//
//  Created by Yuchi Zhang on 2017/5/28.
//  Copyright © 2017年 newcastle university. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Firebase;

@interface UserSettingViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>
@property (strong, nonatomic) FIRDatabaseReference *databaseRef;
@property (strong, nonatomic) FIRStorageReference *storageRef;

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UITextField *displayNameText;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *LoaddataSpinner;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
- (IBAction)getPhotoFromLibrary:(UIButton *)sender;

-(void)loadProfileData;
-(void)errorManagement:(NSString* )title  message:(NSString*) message;
- (IBAction)saveProfile:(id)sender;
- (IBAction)cancel:(id)sender;

@end
