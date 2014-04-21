//
//  CameraEngine.m
//  Encoder Demo
//
//  Created by Geraint Davies on 19/02/2013.
//  Copyright (c) 2013 GDCL http://www.gdcl.co.uk/license.htm
//

#import "CameraEngine.h"
#import "VideoEncoder.h"
#import "AssetsLibrary/ALAssetsLibrary.h"

static CameraEngine* theEngine;

//@class AppDelegate;

@interface CameraEngine  () <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>
{
 
    BOOL _discont;
    int _currentFile;
    CMTime _timeOffset;
    CMTime _lastVideo;
    CMTime _lastAudio;
    
    int _cx;
    int _cy;
    int _channels;
    Float64 _samplerate;
}
@property (nonatomic,strong ) AVCaptureSession* session;
@property (nonatomic,strong )AVCaptureVideoPreviewLayer* preview;
@property (nonatomic,strong )dispatch_queue_t captureQueue;
@property (nonatomic,strong )AVCaptureConnection* audioConnection;
@property (nonatomic,strong )AVCaptureConnection* videoConnection;
@property (nonatomic,strong ) VideoEncoder* encoder;


@end

@implementation CameraEngine


@synthesize session= _session;
@synthesize isCapturing = _isCapturing;
@synthesize isPaused = _isPaused;
@synthesize preview = _preview;
@synthesize captureQueue = _captureQueue;
@synthesize audioConnection = _audioConnection;

@synthesize videoConnection = _videoConnection;
@synthesize encoder = _encoder;

+ (void) initialize
{
    NSLog(@"called Camera Engine init");
    // test recommended to avoid duplicate init via subclass
    if (self == [CameraEngine class])
    {
        theEngine = [[CameraEngine alloc] init];
        NSLog(@"alloc");
    }
}

+ (CameraEngine*) engine
{    NSLog(@"called engine");

    return theEngine;
}



- (void) startup
{
    NSLog(@"starting up");
    if (_session == nil)
    {
        NSLog(@"Session is nil, starting up server");
        
        self.isCapturing = NO;
        self.isPaused = NO;
        _currentFile = 0;
        _discont = NO;
        
        // create capture device with video input
        NSLog(@"1");
        _session = [[AVCaptureSession alloc] init];
        NSLog(@"session is %@",_session);
        
        AVCaptureDevice* backCamera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSLog(@"back camera is %@",backCamera);

        AVCaptureDeviceInput* input = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:nil];
        NSLog(@"input is %@",input);

        [_session addInput:input];
        NSLog(@"5");

        // audio input from default mic
        AVCaptureDevice* mic = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        NSLog(@"6");

        AVCaptureDeviceInput* micinput = [AVCaptureDeviceInput deviceInputWithDevice:mic error:nil];
        NSLog(@"7");

        [_session addInput:micinput];
        NSLog(@"8");

        
        // create an output for YUV output with self as delegate
        _captureQueue = dispatch_queue_create("uk.co.gdcl.cameraengine.capture", DISPATCH_QUEUE_SERIAL);
        AVCaptureVideoDataOutput* videoout = [[AVCaptureVideoDataOutput alloc] init];
        [videoout setSampleBufferDelegate:self queue:_captureQueue];
        NSDictionary* setcapSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange], kCVPixelBufferPixelFormatTypeKey,
                                        nil];
        videoout.videoSettings = setcapSettings;
        [_session addOutput:videoout];
        _videoConnection = [videoout connectionWithMediaType:AVMediaTypeVideo];
        AVCaptureVideoOrientation orientation = AVCaptureVideoOrientationPortrait;
        [_videoConnection setVideoOrientation:orientation];

        // find the actual dimensions used so we can set up the encoder to the same.
        NSDictionary* actual = videoout.videoSettings;
        _cy = [[actual objectForKey:@"Height"] integerValue];
        _cx = [[actual objectForKey:@"Width"] integerValue];
        
        
        AVCaptureAudioDataOutput* audioout = [[AVCaptureAudioDataOutput alloc] init];
        [audioout setSampleBufferDelegate:self queue:_captureQueue];
        
        [_session addOutput:audioout];
        
        _audioConnection = [audioout connectionWithMediaType:AVMediaTypeAudio];
        
        // for audio, we want the channels and sample rate, but we can't get those from audioout.audiosettings on ios, so
        // we need to wait for the first sample
        
        // start capture and a preview layer
        NSLog(@"pre running");
        [_session startRunning];
        [[CameraEngine engine] startCapture];

        NSLog(@"post running");
        
    }
    else
    {NSLog(@"Already running, starting capture");
        [[CameraEngine engine] startCapture];

    }
}



/*
 
- (void) startup
{



        _isCapturing = NO;
        _isPaused = NO;
        _currentFile = 0;
        _discont = NO;
    
    NSDictionary* actual = self.appDelegate.videoOutput.videoSettings;
    NSLog(@"actual is %@",actual);
    
    _cy = [[actual objectForKey:@"Height"] integerValue];
    NSLog(@"cy is %i",_cy);

    _cx = [[actual objectForKey:@"Width"] integerValue];
    NSLog(@"cx is %i",_cx);


    
    [self.appDelegate.videoOutput setSampleBufferDelegate:self queue:self.appDelegate.captureQueue];
    [self.appDelegate.audioOutput setSampleBufferDelegate:self queue:self.appDelegate.captureQueue];
    
    AVCaptureDeviceInput *videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.appDelegate.rearCamera error:nil];

    AVCaptureDeviceInput *audioInput = [[AVCaptureDeviceInput alloc]initWithDevice:self.appDelegate.audioDevice error:nil];
    
    
    
    [self.appDelegate.captureSession addInput:audioInput];

    
    [self.appDelegate.captureSession addInput:videoInput];
    [self.appDelegate.captureSession addOutput:self.appDelegate.movieFileOutput];


    [self.appDelegate.captureSession addOutput:self.appDelegate.videoOutput];

    [self.appDelegate.captureSession addOutput:self.appDelegate.audioOutput];

    [self.appDelegate.captureSession startRunning];
    NSLog(@"finished start running!!");
 
}
 
 
 
 
 
 
 
 
 */

- (void) startCapture
{
    
    NSLog(@"called startCapture");

    @synchronized(self)
    {
        if (!_isCapturing)
        {
            NSLog(@"starting capture");
            
            // create the encoder once we have the audio params
            _encoder = nil;
            _isPaused = NO;
            _discont = NO;
            _timeOffset = CMTimeMake(0, 0);
            _isCapturing = YES;
            
            NSLog(@"capturing is %i",_isCapturing);

        }
    }
}


- (void) stopCapture
{
    NSLog(@"stopping capture");
    @synchronized(self)
    {
        NSLog(@"capturing is %i",_isCapturing);
        if (_isCapturing)
        {
            NSString* filename = [NSString stringWithFormat:@"capture%d.mp4", _currentFile];
            NSString* path = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
            NSURL* url = [NSURL fileURLWithPath:path];
            _currentFile++;
            
            // serialize with audio and video capture
            
            _isCapturing = NO;
            NSLog(@"pre handler");
            dispatch_async(_captureQueue, ^{
                NSLog(@"in async");
                [_encoder finishWithCompletionHandler:^{
                    NSLog(@"in completetion handler");

                    _isCapturing = NO;
                    _encoder = nil;
                    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                    [library writeVideoAtPathToSavedPhotosAlbum:url completionBlock:^(NSURL *assetURL, NSError *error){
                        NSLog(@"save completed");
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"saveComplete" object:nil];

                        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                    }];
                }];
            });
        }
    }
}


- (void) pauseCapture
{
    NSLog(@"called pauseCapture");
    @synchronized(self)
    {
        if (_isCapturing)
        {
            NSLog(@"Pausing capture");
            _isPaused = YES;
            _discont = YES;
        
        }
    }
}

- (void) resumeCapture
{
    NSLog(@"called resumeCapture");
    @synchronized(self)
    {
        if (_isPaused)
        {
            NSLog(@"Resuming capture");
            _isPaused = NO;
        }
    }
}

- (CMSampleBufferRef) adjustTime:(CMSampleBufferRef) sample by:(CMTime) offset
{
    CMItemCount count;
    CMSampleBufferGetSampleTimingInfoArray(sample, 0, nil, &count);
    CMSampleTimingInfo* pInfo = malloc(sizeof(CMSampleTimingInfo) * count);
    CMSampleBufferGetSampleTimingInfoArray(sample, count, pInfo, &count);
    for (CMItemCount i = 0; i < count; i++)
    {
        pInfo[i].decodeTimeStamp = CMTimeSubtract(pInfo[i].decodeTimeStamp, offset);
        pInfo[i].presentationTimeStamp = CMTimeSubtract(pInfo[i].presentationTimeStamp, offset);
    }
    CMSampleBufferRef sout;
    CMSampleBufferCreateCopyWithNewTiming(nil, sample, count, pInfo, &sout);
    free(pInfo);
    return sout;
}

- (void) setAudioFormat:(CMFormatDescriptionRef) fmt
{
    const AudioStreamBasicDescription *asbd = CMAudioFormatDescriptionGetStreamBasicDescription(fmt);
    _samplerate = asbd->mSampleRate;
    _channels = asbd->mChannelsPerFrame;
    
}

- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
   // NSLog(@"captureOutput called. Buffer is :%@",sampleBuffer);
   // NSLog(@"capture output called");
    BOOL bVideo = YES;
    
    @synchronized(self)
    {
        if (!_isCapturing  || _isPaused)
        {
            return;
        }
        if (connection != _videoConnection)
        {
            bVideo = NO;
        }
        
        if ((_encoder == nil) && !bVideo)
        {
            CMFormatDescriptionRef fmt = CMSampleBufferGetFormatDescription(sampleBuffer);
            [self setAudioFormat:fmt];
            NSString* filename = [NSString stringWithFormat:@"capture%d.mp4", _currentFile];
            NSString* path = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
            _encoder = [VideoEncoder encoderForPath:path Height:_cy width:_cx channels:_channels samples:_samplerate];
        }
        if (_discont)
        {
            if (bVideo)
            {
                return;
            }
            _discont = NO;
            // calc adjustment
            CMTime pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            CMTime last = bVideo ? _lastVideo : _lastAudio;
            if (last.flags & kCMTimeFlags_Valid)
            {
                if (_timeOffset.flags & kCMTimeFlags_Valid)
                {
                    pts = CMTimeSubtract(pts, _timeOffset);
                }
                CMTime offset = CMTimeSubtract(pts, last);
                NSLog(@"Setting offset from %s", bVideo?"video": "audio");
                NSLog(@"Adding %f to %f (pts %f)", ((double)offset.value)/offset.timescale, ((double)_timeOffset.value)/_timeOffset.timescale, ((double)pts.value/pts.timescale));
                
                // this stops us having to set a scale for _timeOffset before we see the first video time
                if (_timeOffset.value == 0)
                {
                    _timeOffset = offset;
                }
                else
                {
                    _timeOffset = CMTimeAdd(_timeOffset, offset);
                }
            }
            _lastVideo.flags = 0;
            _lastAudio.flags = 0;
        }
        
        // retain so that we can release either this or modified one
        CFRetain(sampleBuffer);
        
        if (_timeOffset.value > 0)
        {
            CFRelease(sampleBuffer);
            sampleBuffer = [self adjustTime:sampleBuffer by:_timeOffset];
        }
        
        // record most recent time so we know the length of the pause
        CMTime pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        CMTime dur = CMSampleBufferGetDuration(sampleBuffer);
        if (dur.value > 0)
        {
            pts = CMTimeAdd(pts, dur);
        }
        if (bVideo)
        {
            _lastVideo = pts;
        }
        else
        {
            _lastAudio = pts;
        }
    }

    // pass frame to encoder
    [_encoder encodeFrame:sampleBuffer isVideo:bVideo];
    CFRelease(sampleBuffer);
}

- (void) shutdown
{
    NSLog(@"shutting down server");
    if (_session)
    {
        [_session stopRunning];
        _session = nil;

        
    }
    [_encoder finishWithCompletionHandler:^{
        _preview= nil;


        [[NSNotificationCenter defaultCenter] postNotificationName:@"shutDownComplete" object:nil];
       // _encoder=nil;
        //_captureQueue=nil;
        //_audioConnection=nil;
        //_videoConnection=nil;

    
    }];
}

- (AVCaptureVideoPreviewLayer*) getPreviewLayer
{
    _preview = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    NSLog(@"showing preview");
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;

    return _preview;
}



@end
