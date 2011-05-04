//
//  DWDoneButtonView.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 * Custom done button view for the login/signup nav bar
 */
@interface DWDoneButtonView : UIView {
    UIButton *doneButton;
}

/**
 * Custom init to specify the target for button events
 */
- (id)initWithFrame:(CGRect)frame andTarget:(id)target;

@end
