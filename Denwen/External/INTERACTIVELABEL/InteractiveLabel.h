//
//  InteractiveLabel.h
//  TwitterrificTouch
//
//  Created by Craig Hockenberry on 4/2/08.
//  Copyright 2008 The Iconfactory. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "RKLMatchEnumerator.h"
#import "DWConstants.h"


// NOTE: Yeah, it would make more sense to subclass UILabel to do this. But all the
// the UIButtons that got placed on top of the UILabel were not tappable. No amount of
// tinkering with userInteractionEnabled and the responder chain could be found to
// work around this issue.
//
// Instead, a normal view is used and an UILabel methods are supported through forward
// invocation.

@interface InteractiveLabel : UIView 
{
	UILabel *label;
	id _eventTarget;
	NSInteger _tagSeed;
	NSInteger _urlIndex;
}

@property (nonatomic, retain) UILabel *label;

- (id)initWithFrame:(CGRect)frame withTarget:(id)target;
- (void)customizeUIFromText:(NSString*)data andUpdateFrame:(CGRect)frame andSeed:(NSInteger)tagSeed;
- (void)changeButtonBackgroundColor:(UIColor*)color;

@end
