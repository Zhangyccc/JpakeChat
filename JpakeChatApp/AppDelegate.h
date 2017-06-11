//
//  AppDelegate.h
//  JpakeChatApp
//
//  Created by Renu Srijith on 24/04/2016.
//  Copyright © 2016 newcastle university. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
@import Firebase;
#import <GoogleSignIn/GoogleSignIn.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, GIDSignInDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FIRDatabaseReference *ref;



@end

