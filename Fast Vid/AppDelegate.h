//
//  AppDelegate.h
//  Fast Vid
//
//  Created by Andrew Schreiber on 3/8/14.
//  Copyright (c) 2014 Andrew Schreiber. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <QuartzCore/QuartzCore.h>
#import "CameraEngine.h"

@class MainViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic,strong)AVCaptureVideoDataOutput *videoOutput;
@property (nonatomic, strong)AVCaptureConnection *videoConnection;
@property (nonatomic,strong)    AVCaptureConnection* audioConnection;
@property (nonatomic,strong)AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic,strong)AVCaptureAudioDataOutput *audioOutput;
@property(nonatomic,strong) dispatch_queue_t captureQueue;


- (AVCaptureDevice *)rearCamera;
- (AVCaptureDevice *)audioDevice;



@end
