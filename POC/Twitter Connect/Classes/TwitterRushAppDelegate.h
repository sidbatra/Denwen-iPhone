//
//  TwitterRushAppDelegate.h
//  TwitterRush


#import <UIKit/UIKit.h>

@class TwitterRushViewController;

@interface TwitterRushAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    TwitterRushViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet TwitterRushViewController *viewController;

@end

