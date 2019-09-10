//
//  Utility_Objective_C.h
//  Check-Up
//
//  Created by Amisha on 29/08/17.
//  Copyright © 2017 Amisha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Utility_Objective_C : NSObject

+ (void) overlayWatermark:(UIImage*)image video:(NSURL*)videoURL videoName:(NSString*)videoName isWaterMark:(BOOL)isWaterMark isStoryFromGallary:(BOOL)isStoryFromGallary withCompletionHandler:(void (^)(NSString *))completionHandler errorHandler:(void (^)(NSString *))errorHandler;

@end
