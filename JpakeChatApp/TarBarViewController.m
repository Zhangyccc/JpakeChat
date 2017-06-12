//
//  TarBarViewController.m
//  JpakeChatApp
//
//  Created by Yuchi Zhang on 2017/5/28.
//  Copyright © 2017年 newcastle university. All rights reserved.
//

#import "TarBarViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import "LoginViewController.h"
#import "AddFriendsViewController.h"
#import "DataBasics.h"
#import "theCoreDataStack.h"
#import "BigInteger.h"
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface TarBarViewController ()

@end

@implementation TarBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.navigationItem.hidesBackButton =YES;
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

- (IBAction)logout:(id)sender
{
    
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"uid"];
    //Fireabase logout
    [[FIRAuth auth] signOut:nil];
    //[ref unauth];
    //Facebook logout
    FBSDKAccessToken.currentAccessToken = nil;
    //Google logout
    [[GIDSignIn sharedInstance] signOut];
    
    LoginViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"Login"];
    
    [self presentViewController:vc animated:YES completion:nil];
    NSLog(@"Logged out");
}

- (IBAction)AddFriends:(id)sender {
    NSLog(@"Pressed");
    AddFriendsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddFriends"];
    [self presentViewController:vc animated:YES completion:nil];
}


@end
