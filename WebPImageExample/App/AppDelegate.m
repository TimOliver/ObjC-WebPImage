//
//  AppDelegate.m
//  WebPImage
//
//  Created by Tim Oliver on 28/12/2021.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    if (@available(iOS 13.0, *)) { }
    else {
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen.mainScreen bounds]];
        self.window.rootViewController = [[ViewController alloc] init];
        [self.window makeKeyAndVisible];
    }

    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application
configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession
                              options:(UISceneConnectionOptions *)options API_AVAILABLE(ios(13.0))
{
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

@end
