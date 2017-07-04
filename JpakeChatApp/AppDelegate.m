//
//  AppDelegate.m
//  JpakeChatApp
//
//  Created by Renu Srijith on 24/04/2016.
//  Copyright © 2016 newcastle university. All rights reserved.
//

#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "DataBasics.h"
#import <UIColor+JSQMessages.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [FIRApp configure];
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    [GIDSignIn sharedInstance].clientID = [FIRApp defaultApp].options.clientID;
    [GIDSignIn sharedInstance].delegate = self;
//    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    
    BOOL Facebookhandled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                  openURL:url
                                                        sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                                               annotation:options[UIApplicationOpenURLOptionsAnnotationKey]
                    ];
    
    BOOL Googlehandled = [[GIDSignIn sharedInstance] handleURL:url
                                             sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                                    annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    // Add any custom logic here.
    if(Facebookhandled)
    {return Facebookhandled;}
    else
    {return Googlehandled;}
}

//For iOS8 and earlier version
- (BOOL)application:(UIApplication* )application
            openURL:(NSURL* )url
  sourceApplication:(NSString* )sourceApplication
         annotation:(id)annotation {
    return [[GIDSignIn sharedInstance] handleURL:url
                               sourceApplication:sourceApplication
                                      annotation:annotation];
}

- (void)signIn:(GIDSignIn* )signIn
didSignInForUser:(GIDGoogleUser* )user
     withError:(NSError* )error {
    UIActivityIndicatorView *LoginAiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    //LoginAiv.center = self.window.center;
    //[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    LoginAiv.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/5);
    LoginAiv.color = UIColor.redColor;
    [self.window.rootViewController.view addSubview:LoginAiv];
    [LoginAiv startAnimating];
//    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
//    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
//    [self navigationItem].rightBarButtonItem = barButton;
//    [activityIndicator startAnimating];
    if (error == nil) {
        GIDAuthentication *authentication = user.authentication;
        FIRAuthCredential *credential =
        [FIRGoogleAuthProvider credentialWithIDToken:authentication.idToken
                                         accessToken:authentication.accessToken];
        [[FIRAuth auth] signInWithCredential:credential
                                  completion:^(FIRUser *user, NSError *error) {
                                      if (error) {
                                          NSLog(@"Sign in failed: %@", error.localizedDescription);
                                      } else {
                                          user = [FIRAuth auth].currentUser;
                                          NSDictionary *newUser = @{
                                                                    //@"provider": [FIRAuth auth].currentUser.providerID, //authData.provider
                                                                    @"provider": @"Google",
                                                                    //@"username": [FIRAuth auth].currentUser.displayName,
                                                                    @"email": [FIRAuth auth].currentUser.email,
                                                                    @"password": @"Google"
                                                                    };
                                          NSLog(@"users dictionary %@" ,newUser);
                                          self.ref = [[FIRDatabase database] reference];
                                          [[[[_ref child:@"users"] queryOrderedByChild:@"email" ] queryEqualToValue:[FIRAuth auth].currentUser.email]
                                           observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
                                               NSLog(@"snapshot: %@", snapshot.value);
                                               //If user exists
                                               if(!snapshot.exists)
                                               {
                                                   NSLog(@"Adding new user");
                                                   [[[_ref child:@"users"]
                                                     child:[FIRAuth auth].currentUser.uid] updateChildValues:newUser];
                                                   [[DataBasics dataBasicsInstance] loginUserWithData:user];
                                                   [[NSUserDefaults standardUserDefaults] setValue:user.uid forKey:@"uid"];
                                                   [LoginAiv stopAnimating];
                                               }
                                               else{
                                                   NSLog(@"Google user exists");
                                               }
                                           }];
//                                          [[[_ref child:@"users"]
//                                            child:[FIRAuth auth].currentUser.uid] updateChildValues:newUser];
//                                          //NSLog(@"userEmail:",user.email); email == nil ---> DataBasicsinstance loginuserwithdata
//                                          [[DataBasics dataBasicsInstance] loginUserWithData:user];
//                                          [[NSUserDefaults standardUserDefaults] setValue:user.uid forKey:@"uid"];
//                                          [LoginAiv stopAnimating];
                                      }
                                      
                                  }];
        
    } else {
        NSLog(@"%@", error.localizedDescription);
        [LoginAiv stopAnimating];
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
   // [self saveContext];
}

#pragma mark - Core Data stack



@end
