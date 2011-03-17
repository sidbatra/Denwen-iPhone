//
//  DWVideoViewController.h
//  Denwen
//
//  Created by Siddharth Batra on 3/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#import "DWGUIManager.h"
#import "Constants.h"



@interface DWVideoViewController : MPMoviePlayerViewController {

}

- (id)initWithMediaURL:(NSString*)theURL;


@end
