//
//  DWURLHelper.h
//  Denwen
//
//  Created by Siddharth Batra on 1/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSURL *launchURL;

@interface DWURLHelper : NSObject {

}

+ (NSString*)encodeString:(NSString*)parameter;

@end
