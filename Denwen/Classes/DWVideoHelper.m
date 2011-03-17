//
//  DWVideoHelper.m
//  Denwen
//
//  Created by Siddharth Batra on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWVideoHelper.h"


@implementation DWVideoHelper


// Extracts the orientation of the video using AVFoundation
//
+ (NSString*)extractOrientationOfVideo:(NSURL*)videoURL {
	NSString *orientation = nil;
	AVURLAsset *avAsset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
	AVAssetTrack* videoTrack = [[avAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
	CGAffineTransform txf = [videoTrack preferredTransform];
	[avAsset release];
	
	if(txf.a == 0 && txf.b == 1 && txf.c == -1 && txf.d == 0)
		orientation = [NSString stringWithString:@"90"];
	else if(txf.a == -1 && txf.b == 0 && txf.c == 0 && txf.d == -1)
		orientation = [NSString stringWithString:@"180"];
	else if(txf.a == 0 && txf.b == -1 && txf.c == 1 && txf.d == 0)
		orientation = [NSString stringWithString:@"270"];
	else if(txf.a == 1 && txf.b == 0 && txf.c == 0 && txf.d == 1)
		orientation = [NSString stringWithString:@"0"];
	
	return orientation;
}

@end
