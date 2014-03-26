//
//  AppDelegate.m
//  Fast Vid
//
//  Created by Andrew Schreiber on 3/8/14.
//  Copyright (c) 2014 Andrew Schreiber. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

// For use in the storyboards.
- (void) endBackgroundUpdateTask;

-(void)shutDown;

// Session management.

@property ( strong, nonatomic)MainViewController *controller;

// Utilities.
@property (nonatomic) UIBackgroundTaskIdentifier backgroundUpdateTask;

@end


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[CameraEngine engine] startup];


    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    self.controller = [[MainViewController alloc]init];
    
    self.window.rootViewController = self.controller;
    
    [self.window makeKeyAndVisible];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endBackgroundUpdateTask) name:@"shutDownComplete" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endBackgroundUpdateTask) name:@"saveComplete" object:nil];


    return YES;
}

/*
-(void)camera
{
    NSLog(@"Started camera");
    
    
    
    self.captureSession = [[AVCaptureSession alloc] init];
    
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    

    
    
    
    
    self.videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    

    self.captureQueue = dispatch_queue_create("uk.co.gdcl.cameraengine.capture", DISPATCH_QUEUE_SERIAL);
    

    
    
    
    
    //  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    
    
    
    self.movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    
    
    AVCaptureConnection *connection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    if ([connection isVideoStabilizationSupported])
        [connection setEnablesVideoStabilizationWhenAvailable:YES];
    
    
    
    // create an output for YUV output with self as delegate
    
    
    self.videoConnection = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
    
    // find the actual dimensions used so we can set up the encoder to the same.
    
    self.audioOutput = [[AVCaptureAudioDataOutput alloc] init];
    
    NSDictionary* setcapSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange], kCVPixelBufferPixelFormatTypeKey,
                                    nil];
    self.videoOutput.videoSettings = setcapSettings;
    
    
    self.audioConnection = [self.audioOutput connectionWithMediaType:AVMediaTypeAudio];
    
    
    
    [[CameraEngine engine] startup];
    NSLog(@"post startup");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"captureStarted" object:nil];


    

 
}*/







- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    
    
  //  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        [self beginBackgroundUpdateTask];
    
    CameraEngine *engine = [CameraEngine engine];
        
        
        [engine stopCapture];
        
    //});
    
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{

    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    
    
}

-(void)shutDown
{
    NSLog(@"called shut down in delegate");
    [[CameraEngine engine]shutdown];
    [self endBackgroundUpdateTask];

}

- (void) beginBackgroundUpdateTask
{
    self.backgroundUpdateTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundUpdateTask];
    }];
}

- (void) endBackgroundUpdateTask
{
    NSLog(@"End background update");
    [[UIApplication sharedApplication] endBackgroundTask: self.backgroundUpdateTask];
    self.backgroundUpdateTask = UIBackgroundTaskInvalid;
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[CameraEngine engine] startup];

}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
