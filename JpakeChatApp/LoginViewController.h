//
//  LoginViewController.h
//  Jpake
//
//  Created by Renu Srijith on 15/04/2016.
//  Copyright © 2016 newcastle university. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
@import Firebase;
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <GoogleSignIn/GoogleSignIn.h>


@interface LoginViewController : UIViewController<FBSDKLoginButtonDelegate, GIDSignInUIDelegate>
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (nonatomic, strong) UIColor *borderColorFromUIColor;
//@property (weak, nonatomic) IBOutlet id<FBSDKLoginButtonDelegate> delegate;
@property (strong, nonatomic) IBOutlet FBSDKLoginButton *loginButton;
@property(strong, nonatomic) IBOutlet GIDSignInButton *GoogleLoginButton;


-(void) setBorderColorFromUIColor:(UIColor *)borderColorFromUIColor;
- (IBAction)login:(id)sender;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *LoginLoadingSpinner;


@end
