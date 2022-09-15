//
//  face_sdk_wrapper.h
//  Face Detect
//
//  Created by Admin on 2/8/21.
//  Copyright © 2021 Sunyard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTVIDCardEngine : NSObject

+(TTVIDCardEngine*) getInstance;

-(int) createSDK;
-(int) releaseSDK;
-(NSMutableDictionary*) recognition:(UIImage*) image;

@end

NS_ASSUME_NONNULL_END
