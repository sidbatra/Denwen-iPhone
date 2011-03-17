//
//  DWVideoHelper.h
//  Denwen
//
//  Created by Siddharth Batra on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@interface DWVideoHelper : NSObject {

}

+ (NSString*)extractOrientationOfVideo:(NSURL*)videoURL;


@end
