//
//  signupViewController.m
//  Jpake
//
//  Created by Renu Srijith on 15/04/2016.
//  Copyright © 2016 newcastle university. All rights reserved.
//

#import "signupViewController.h"
#include "InboxTableViewController.h"
#include "DataBasics.h"
@import FirebaseAuth;
@import Firebase;


@interface signupViewController ()

@end

@implementation signupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton =YES;
    _ref = [[FIRDatabase database] reference];
    
//侧滑返回
//    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
//    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
//    //backBarButtonItem = barItem;
//    self.navigationItem.backBarButtonItem = barItem;
//    [self.view addSubview:backButton];
    //self.ref =[[Firebase alloc] initWithUrl:@"https://securejpake.firebaseio.com"];
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

- (IBAction)signup:(id)sender {
    [_SignupSpinner startAnimating];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    NSString *username=[self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password=[self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *email=[self.emailaddressField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([username length] ==0 || [password length]==0  || [email length]==0)
    {
        
        
        NSString * errortitle=@" Signup  Error ";
        NSString *message=@"Oops make sure you enter valid username and password !!!";
        [self signupError:errortitle message:message];
        [_SignupSpinner stopAnimating];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }
    
    else
    {
        [[FIRAuth auth] createUserWithEmail:email password:password
                         completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
                         if (error)
                         {
                             if (error.code == FIRAuthErrorCodeNetworkError) {
                                 NSLog(@"NetworkError.");
                                 [self signupError:@"NetworkError." message:@"try again"];
                                 [_SignupSpinner stopAnimating];
                                 [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                             }
                             if (error.code == FIRAuthErrorCodeTooManyRequests) {
                                 NSLog(@"Too Many Requests.");
                                 [self signupError:@"Too Many Requests." message:@"try again"];
                                 [_SignupSpinner stopAnimating];
                                 [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                             }
                             if (error.code == FIRAuthErrorCodeInvalidEmail)
                             {
                                 NSLog(@"Invalid Email.");
                                 [self signupError:@"Invalid Email." message:@"try again"];
                                 [_SignupSpinner stopAnimating];
                                 [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                             }
                             if (error.code == FIRAuthErrorCodeWeakPassword) {
                                 NSLog(@"The password must be 6 characters long or more.");
                                 [self signupError:@"The password must be 6 characters long or more." message:@"try again"];
                                 [_SignupSpinner stopAnimating];
                                 [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                             }
                             else
                             {[self signupError:@"unknown error" message:@"try again"];}
                             [_SignupSpinner stopAnimating];
                             [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                         }
                         else
                         {
                             //  Login the New User with authUser
                             NSLog(@"user createed successfully .now trying to logggin that user in ");
                             [[FIRAuth auth] signInWithEmail:email password:password completion:^(FIRUser * user, NSError * error)
                              {
                                  if (error)
                                  {
                                      NSLog(@"Error logging in %@",error);
                                      [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                                  }
                                  else {
                                      NSDictionary *newUser = @{
                                                                @"provider": user.providerID, //authData.provider
                                                                @"username": username,
                                                                @"email": email,
                                                                @"password": password,
                                                                @"photo": @"https://firebasestorage.googleapis.com/v0/b/jpakechat.appspot.com/o/avatar512pixel.png?alt=media&token=c8505024-65f8-4cc1-a30a-cf5e69a29a46"
                                                                };
                                      NSLog(@"users dictionary %@" ,newUser);
                                      [[[_ref child:@"users"]
                                        child:user.uid] updateChildValues:newUser];
                                      [[DataBasics dataBasicsInstance] loginUserWithData:user];
                                      [[NSUserDefaults standardUserDefaults] setValue:user.uid forKey:@"uid"];
                                      
                                  }
                              }];
                             //NSString *uid = [result objectForKey:@"uid"];
                             //NSLog(@"Successfully created user account with uid: %@", uid);
                             
                             // [self.navigationController popToRootViewControllerAnimated:YES];
                             InboxTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"Inbox"];
                             
                             [self presentViewController:vc animated:YES completion:nil];
                             [_SignupSpinner stopAnimating];
                             [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                             
                             
                             //[self performSegueWithIdentifier:@"NewUserLoggedIn" sender:self];
                             
                             
                         }
                     }];
    }
}

//            [self.ref createUser:email   password:password
//            withValueCompletionBlock:^(NSError *error, NSDictionary *result) {
//
//
//                if (error)
//                {
//
//                    NSLog(@"Error %@",error);
//                    [self signupError:@"Error in signing up with firebase" message:@"try again"];
//                }
//
//                else
//                {
//           //  Login the New User with authUser
//
//                    NSLog(@"user createed successfully .now trying to logggin that user in ");
//
//                    [self.ref authUser:email password:password
//              withCompletionBlock:^(NSError *error, FAuthData *authData) {
//                  if (error)
//                  {
//                      NSLog(@"Error logging in %@",error);
//                  }
//                  else {
//                      NSDictionary *newUser = @{
//                                                @"provider": authData.provider,
//                                                @"username": username,
//                                                @"email": email
//                                                };
//                      NSLog(@"users dictionary %@" ,newUser);
//                      [[[self.ref childByAppendingPath:@"users"]
//                        childByAppendingPath:authData.uid] updateChildValues:newUser];
//                  [[DataBasics dataBasicsInstance] loginUserWithData:authData];
//                      [[NSUserDefaults standardUserDefaults] setValue:authData.uid forKey:@"uid"];
//
//                  }
//              }];
//
//           NSString *uid = [result objectForKey:@"uid"];
//           NSLog(@"Successfully created user account with uid: %@", uid);
//
//          // [self.navigationController popToRootViewControllerAnimated:YES];
//                    InboxTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"Inbox"];
//
//                    [self presentViewController:vc animated:YES completion:nil];
//
//
//            //[self performSegueWithIdentifier:@"NewUserLoggedIn" sender:self];
//
//
//       }
//   }];
//           
//           
//}


-(void)signupError:(NSString* )title  message:(NSString*) message
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
