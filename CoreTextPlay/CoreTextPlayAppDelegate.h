//
//  CoreTextPlayAppDelegate.h
//  CoreTextPlay
//
//  Created by Donny Kurniawan on 9/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CoreTextPlayViewController;

@interface CoreTextPlayAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet CoreTextPlayViewController *viewController;

@end
