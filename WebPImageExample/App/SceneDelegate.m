//
//  SceneDelegate.m
//  WebPImage
//
//  Created by Tim Oliver on 28/12/2021.
//

#import "SceneDelegate.h"
#import "ViewController.h"

@interface SceneDelegate ()

@end

@implementation SceneDelegate

- (void)scene:(UIScene *)scene
willConnectToSession:(UISceneSession *)session
      options:(UISceneConnectionOptions *)connectionOptions API_AVAILABLE(ios(13.0))
{
    self.window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
    self.window.rootViewController = [[ViewController alloc] init];
    [self.window makeKeyAndVisible];
}

@end
