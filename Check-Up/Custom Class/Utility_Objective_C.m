//
//  Utility_Objective_C.m
//  Check-Up
//
//  Created by Amisha on 29/08/17.
//  Copyright © 2017 Amisha. All rights reserved.
//

#import "Utility_Objective_C.h"
#import "UIImage+ProportionalFill.h"
#import "TwitterVideoUpload.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

@implementation Utility_Objective_C




+ (void) overlayWatermark:(UIImage*)image video:(NSURL*)videoURL videoName:(NSString*)videoName isWaterMark:(BOOL)isWaterMark isStoryFromGallary:(BOOL)isStoryFromGallary withCompletionHandler:(void (^)(NSString *))completionHandler errorHandler:(void (^)(NSString *))errorHandler
{
    if (videoURL == nil)
        return;
    
    // 1 - Early exit if there's no video file selected
    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:videoURL.absoluteString] options:nil];
    if (!videoAsset) {
        errorHandler(@"Video internal error, please select another one.");
        return;
    }
    
    // 2 - Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    // 3 - Video track
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    
    //add Video
    if ([[videoAsset tracksWithMediaType:AVMediaTypeVideo] count] > 0) {
        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                            ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                             atTime:kCMTimeZero error:nil];
    }
    else
    {
        errorHandler(@"Video internal error, please select another one.");
        return;
    }
    //add audio
    if ([[videoAsset tracksWithMediaType:AVMediaTypeAudio] count] > 0)
    {
        AVAssetTrack *clipAudioTrack = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:clipAudioTrack atTime:kCMTimeZero error:nil];
    }
//    else
//    {
//        errorHandler(@"Video error, please select another one.");
//        return;
//    }
    // 3.1 - Create AVMutableVideoCompositionInstruction
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    
    // 3.2 - Create an AVMutableVideoCompositionLayerInstruction for the video track and fix the orientation.
    AVMutableVideoCompositionLayerInstruction *videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    UIImageOrientation videoAssetOrientation_  = UIImageOrientationUp;
    BOOL isVideoAssetPortrait_  = NO;
    CGAffineTransform videoTransform = videoAssetTrack.preferredTransform;
    if(isStoryFromGallary == false){
    if(videoTransform.ty < 0){
        videoTransform = CGAffineTransformMake(0, 1, -1, 0, videoAssetTrack.naturalSize.height, 0);
    }
    if(videoTransform.ty > 0){
        videoTransform = CGAffineTransformMake(1, 0, 0, -1, 0, videoAssetTrack.naturalSize.height);
    }
    }

    if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
        videoAssetOrientation_ = UIImageOrientationRight;
        isVideoAssetPortrait_ = YES;
    }
    
    if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
        videoAssetOrientation_ =  UIImageOrientationLeft;
        isVideoAssetPortrait_ = YES;
    }
    if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
        videoAssetOrientation_ =  UIImageOrientationUp;
    }
    if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
        videoAssetOrientation_ = UIImageOrientationDown;
    }
    [videolayerInstruction setTransform:videoTransform atTime:kCMTimeZero];
    [videolayerInstruction setOpacity:0.0 atTime:videoAsset.duration];
    
    // 3.3 - Add instructions
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:videolayerInstruction,nil];
    
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    
    CGSize naturalSize;
    if(isVideoAssetPortrait_){
        naturalSize = CGSizeMake(videoAssetTrack.naturalSize.height, videoAssetTrack.naturalSize.width);
    } else {
        naturalSize = videoAssetTrack.naturalSize;
    }
    
    float renderWidth, renderHeight;
    renderWidth = naturalSize.width;
    renderHeight = naturalSize.height;
    mainCompositionInst.renderSize = CGSizeMake(renderWidth, renderHeight);
    mainCompositionInst.instructions = [NSArray arrayWithObject:mainInstruction];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
    
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, renderWidth, renderHeight);
    videoLayer.frame = CGRectMake(0, 0, renderWidth, renderHeight);
    [parentLayer addSublayer:videoLayer];
    
    //  create the layer with the watermark image
    
    
    float aspect = image.size.width/image.size.height;
    UIImage *newImage = [self imageWithImage:image scaledToSize:CGSizeMake(image.size.width*aspect*2, image.size.height*aspect*2)];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, renderWidth, renderHeight)];
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.image = newImage;
    
    CALayer* aLayer = [CALayer layer];
    aLayer.contents = (id)newImage.CGImage;
    aLayer.contentsGravity = kCAGravityResizeAspectFill;
    aLayer.frame = imgView.frame;
    //    aLayer.opacity = 0.9;
    [parentLayer addSublayer:aLayer];
    
    if (isWaterMark) {
        //watermark image logo
        
        
        float tempWd = image.size.width * 0.60;
        float wd = (imgView.frame.size.width * tempWd) / image.size.width;
        float ht =  ( wd * 198 ) / 696;
        
        UIImage *logoImg1 = [UIImage imageNamed:@"watermark_logo"];
        UIGraphicsBeginImageContext(CGSizeMake(wd, ht));
        [logoImg1 drawInRect:CGRectMake(0, 0, wd, ht)];
        UIImage *logoImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        aLayer = [CALayer layer];
        aLayer.contents = (id)logoImg.CGImage;
        aLayer.contentsGravity = kCAGravityTop;
        aLayer.frame = CGRectMake(0, 0, imgView.frame.size.width, imgView.frame.size.height);
        aLayer.opacity = 0.5;
        //aLayer.frame = CGRectMake((imgView.frame.size.width - logoImg.size.width)/2, 0, logoImg.size.width, logoImg.size.height);
        [parentLayer addSublayer:aLayer];
    }
    
    mainCompositionInst.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
    
    // 4 - Get path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:
                             [NSString stringWithFormat:@"%@.mp4",videoName]];
    NSURL *exportUrl = [NSURL fileURLWithPath:myPathDocs];
    
    // 5 - Create exporter
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                      presetName:(isStoryFromGallary ? AVAssetExportPresetHighestQuality : AVAssetExportPresetHighestQuality)];
    exporter.outputURL=exportUrl;
    
    //exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.videoComposition = mainCompositionInst;
    
    
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        switch (exporter.status)
        {
            case AVAssetExportSessionStatusUnknown:
                NSLog(@"Unknown");
                break;
            case AVAssetExportSessionStatusWaiting:
                NSLog(@"Waiting");
                break;
            case AVAssetExportSessionStatusExporting:
                NSLog(@"Exporting");
                break;
            case AVAssetExportSessionStatusCompleted:
                NSLog(@"Created new water mark image : %@", exporter.outputURL.absoluteString);
                if (isWaterMark) {
                    [self exportDidFinish:exporter];
                }
                completionHandler(exporter.outputURL.absoluteString);
                break;
            case AVAssetExportSessionStatusFailed:
                NSLog(@"Failed- %@", exporter.error);
                errorHandler(@"Video internal error, please select another one.");
                break;
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"Cancelled");
                break;
        }
    }];
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (void)exportDidFinish:(AVAssetExportSession*)session {
    if (session.status == AVAssetExportSessionStatusCompleted) {
        NSURL *outputURL = session.outputURL;
        NSLog(@"Url : %@",outputURL.absoluteString);
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL]) {
            [library writeVideoAtPathToSavedPhotosAlbum:outputURL completionBlock:^(NSURL *assetURL, NSError *error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error) {
                        NSLog(@"Error : %@", error.localizedDescription);
                    } else {
                        NSLog(@"Story Save Successfully.");
                    }
                });
            }];
        }
    }
}

@end
