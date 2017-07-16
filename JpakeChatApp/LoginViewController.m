//
//  LoginViewController.m
//  Jpake
//
//  Created by Renu Srijith on 15/04/2016.
//  Copyright © 2016 newcastle university. All rights reserved.
//

#import "LoginViewController.h"
@import Firebase;
#import "DataBasics.h"
#import <objc/runtime.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FirebaseAuth/FirebaseAuth.h>
#import <GoogleSignIn/GoogleSignIn.h>


@interface LoginViewController ()

@end

@implementation LoginViewController
//@synthesize EmailLoginButton;
@synthesize FacebookloginButton;
@synthesize GoogleLoginButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    //FIRDatabase reference必备！！！！！！
    self.ref = [[FIRDatabase database] reference];
    self.navigationItem.hidesBackButton =YES;
    //Google delegate
    //GoogleLoginButton.frame = CGRectMake(132, 414, 150, 30);
    [GIDSignIn sharedInstance].uiDelegate = self;
    
    FacebookloginButton = [[FBSDKLoginButton alloc] init];
    FacebookloginButton.delegate = self;
    CGFloat verticalPosition = 1.0;
    CGFloat positionOfFrame = self.view.center.y - self.view.center.y / verticalPosition;
    CGFloat positionX = self.view.center.x - (FacebookloginButton.frame.size.width + 42) / 3;
    CGFloat positionY = self.view.center.y - (FacebookloginButton.frame.size.height + 15) / 4;
    CGFloat finalPositionY = positionY + positionOfFrame;
    //CGFloat finalPositionY = positionY;
    //Frame of the Login Button
    CGFloat widthOfFBButton = FacebookloginButton.frame.size.width - 32;
    CGFloat heightOfFBButton = FacebookloginButton.frame.size.height + 12;
    //Placing the button on the frame
    FacebookloginButton.frame = CGRectMake(positionX, finalPositionY, widthOfFBButton, heightOfFBButton);
    //FacebookloginButton.frame = CGRectMake(112, 329, 150, 35);
    FacebookloginButton.readPermissions = @[@"public_profile", @"email"];
//    NSLayoutConstraint *FbConstraints = [NSLayoutConstraint constraintWithItem:self.passwordField attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
//    [self.FacebookloginButton setTranslatesAutoresizingMaskIntoConstraints:NO];
//    [self.view addConstraint:FbConstraints];
//    [self.FacebookloginButton addConstraint:FbConstraints];
    [self.view addSubview:FacebookloginButton];
    
    
    

    //FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    //loginButton.delegate = self;
    // Optional: Place the button in the center of your view.
    //loginButton.center = self.view.center;
    //[self.view addSubview:loginButton];
    //loginButton.readPermissions = @[@"public_profile", @"email"];
//    if ([FBSDKAccessToken currentAccessToken]) {
//        // User is logged in, do work such as go to next view controller.
//    
////      [self.navigationController popToRootViewControllerAnimated:YES];
//        [self performSegueWithIdentifier:@"showConversations" sender:self];
//        
//    }


    
    //NEW OBSERVE 作用同上面的if,都要跳转到聊天界面，通过segue identifier(线),负责谷歌登陆进来跳转界面
    [[FIRAuth auth] addAuthStateDidChangeListener:^(FIRAuth *auth, FIRUser *user) {
        if(user) {
            NSLog(@"User is signed in with uid: %@", user.uid);
            [self performSegueWithIdentifier:@"showConversations" sender:self];
        }
        else {
            NSLog(@"No user is signed in.");
        }
    }];
    
    //OLD OBSERVE
    //    [ref observeAuthEventWithBlock:^(FAuthData *authData) {
    //        if (authData) {
    //            // user authenticated
    //           NSLog(@"inside loginVC moving to inbox");
    //            [self performSegueWithIdentifier:@"showConversations" sender:self];
    //
    //        } else {
    //            // No user is signed in
    //            NSLog(@"inside login vC  no user signed in ");
    //        }
    //    }];
}

//内存不足 释放内存
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Facebook Login button
- (void)loginButton:(FBSDKLoginButton *)loginButton
didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
              error:(NSError *)error {
    [_LoginLoadingSpinner startAnimating];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    if(result.isCancelled)
    {
        NSLog(@"Login cancelled");
        [_LoginLoadingSpinner stopAnimating];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        return;
    }
    else if (error == nil) {
        FIRAuthCredential *credential = [FIRFacebookAuthProvider
                                         credentialWithAccessToken:[FBSDKAccessToken currentAccessToken]
                                         .tokenString];
        //NSString *email;
        [[FIRAuth auth] signInWithCredential:credential
                                  completion:^(FIRUser *user, NSError *error) {
                                      if (error) {
                                          //NSLog(@"Sign in failed: %@", error.localizedDescription);
                                          NSLog(@"Error logging in %@",error);
                                          NSString *Err=error.description;
                                          [self loginError:@"Login Error " message:Err];
                                          [_LoginLoadingSpinner stopAnimating];
                                          [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                                      }
                                      else {
                                          user = [FIRAuth auth].currentUser;
                                          NSDictionary *newUser = @{
                                                                    //@"provider": [FIRAuth auth].currentUser.providerID, //authData.provider
                                                                    @"provider": @"Facebook",
                                                                    @"username": [FIRAuth auth].currentUser.displayName,
                                                                    @"email": [FIRAuth auth].currentUser.email,
                                                                    @"password": @"Facebook",
                                                                    @"photo": user.photoURL.absoluteString
                                                                    };
                                          NSLog(@"users dictionary %@" ,newUser);
                                          //if([FIRAuth auth].currentUser.email)
                                          [[[[_ref child:@"users"] queryOrderedByChild:@"email" ] queryEqualToValue:[FIRAuth auth].currentUser.email]
                                          observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
                                              NSLog(@"snapshot: %@", snapshot.value);
                                              //If user exists?
                                              if(snapshot.value == [NSNull null])
                                              {
                                                  NSLog(@"Adding new user");
                                                  [[[_ref child:@"users"]
                                                  child:[FIRAuth auth].currentUser.uid] updateChildValues:newUser];
                                                  [[DataBasics dataBasicsInstance] loginUserWithData:user];
                                                  [[NSUserDefaults standardUserDefaults] setValue:user.uid forKey:@"uid"];
                                                  [_LoginLoadingSpinner stopAnimating];
                                                  [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                                              }
                                              else{
                                                  NSLog(@"Facebook user exists");
                                                  [_LoginLoadingSpinner stopAnimating];
                                                  [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                                              }
                                          }];
                                      }

                                  }];
    }
    else {
        NSLog(@"%@", error.localizedDescription);
        [_LoginLoadingSpinner stopAnimating];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }
}


////////////////////////////
//此函数暂时只是走于形式，因为logout按钮已经提前退出登录状态
-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
    NSError *error;
    [[FIRAuth auth] signOut:&error];
    if (!error) {
        NSLog(@"log out successful");
        [_LoginLoadingSpinner stopAnimating];
    }
    
//    FBSDKAccessToken *currentAccessToken = nil;
//    FBSDKProfile *currentProfile = nil;
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logOut];
    [_LoginLoadingSpinner stopAnimating];
    
}
//Set border color
//-(UIColor*)borderColorFromUIColor{
//    return objc_getAssociatedObject(self, @selector(borderColorFromUIColor));
//}


//- (void)setBorderColorFromUIColor:(UIColor *)color{
//    objc_setAssociatedObject(self, @selector(borderColorFromUIColor), color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}

//-(void)setBorderColorFromUI:(UIColor*)color{
//    self.borderColor = color.CGColor;
    
//}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (IBAction)login:(id)sender {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    NSString *email=[self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password=[self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [_LoginLoadingSpinner startAnimating];
    if([email length]==0 || [password length]==0  )
    {
        
        [self loginError:@"Login Error !! " message:@"Make sure you enter a valid username and password !! "];
        [_LoginLoadingSpinner stopAnimating];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        //
        
    }
    
    else
    {
//        FIRAuthCredential *credential = [FIREmailPasswordAuthProvider credentialWithEmail:email password:password];
        //NEW LOGIN
        [[FIRAuth auth] signInWithEmail:email password:password completion:^(FIRUser *user, NSError *error) {
            if (error) {
                if (error.code == FIRAuthErrorCodeNetworkError) {
                    NSLog(@"NetworkError.");
                    [self loginError:@"NetworkError." message:@"try again"];
                    [_LoginLoadingSpinner stopAnimating];
                    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                }
                if (error.code == FIRAuthErrorCodeTooManyRequests) {
                    NSLog(@"Too Many Requests.");
                    [self loginError:@"Too Many Requests." message:@"try again"];
                    [_LoginLoadingSpinner stopAnimating];
                    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                }
                if (error.code == FIRAuthErrorCodeWrongPassword) {
                    NSLog(@"Mismatch password and email.");
                    [self loginError:@"Mismatch password and email." message:@"try again"];
                    [_LoginLoadingSpinner stopAnimating];
                    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                }
                if (error.code == FIRAuthErrorCodeInvalidEmail) {
                    NSLog(@"Invalid Email.");
                    [self loginError:@"Invalid Email." message:@"try again"];
                    [_LoginLoadingSpinner stopAnimating];
                    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                }
                if (error.code == FIRAuthErrorCodeUserNotFound) {
                    NSLog(@"User not found.");
                    [self loginError:@"User not found." message:@"try again"];
                    [_LoginLoadingSpinner stopAnimating];
                    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                }
                else
                {
                    [self loginError:@"unknown error" message:@"try again"];
                    [_LoginLoadingSpinner stopAnimating];
                    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                }
                //NSLog(@"Sign in failed: %@", error.localizedDescription);
//                NSLog(@"Error logging in %@",error);
//                NSString *Err=error.description;
//                [self loginError:@"Login Error " message:Err];
//                [_LoginLoadingSpinner stopAnimating];
                
            } else {
                NSLog(@"Signed in with uid: %@", user.uid);
                [[DataBasics dataBasicsInstance] loginUserWithData:user];
                [[NSUserDefaults standardUserDefaults] setValue:user.uid forKey:@"uid"];
                [self.navigationController popToRootViewControllerAnimated:YES];
                [self performSegueWithIdentifier:@"showConversations" sender:self];
                [_LoginLoadingSpinner stopAnimating];
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            }
        }];
        
        
        
        
        //OLD LOGIN
        //DataBasics *mydat=[DataBasics dataBasicsInstance];
        //        [[DataBasics dataBasicsInstance].ref authUser:email password:password
        //        withCompletionBlock:^(NSError *error, FAuthData *authData) {
        //      if (error)
        //            {
        //                NSLog(@"Error logging in %@",error);
        //                NSString *Err=error.description;
        //                [self loginError:@"Login Error " message:Err];
        //            }
        //      else {
        //
        //          [[DataBasics dataBasicsInstance] loginUserWithData:authData];
        //           [[NSUserDefaults standardUserDefaults] setValue:authData.uid forKey:@"uid"];
        //           [self.navigationController popToRootViewControllerAnimated:YES];
        //          [self performSegueWithIdentifier:@"showConversations" sender:self];
        //
        //            }
        //        }];
        
        //            {
        //                [self.navigationController popToRootViewControllerAnimated:YES];
        //            }
        
        
        
        
        
        
    } //else
    
} //sender
-(void)loginError:(NSString* )title  message:(NSString*) message
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
