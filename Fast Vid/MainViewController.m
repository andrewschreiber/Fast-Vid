//
//  MainViewController.m
//  Fast Vid
//
//  Created by Andrew Schreiber on 3/8/14.
//  Copyright (c) 2014 Andrew Schreiber. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@property (nonatomic,strong)AppDelegate *appDelegate;
@property(nonatomic,strong)AVCaptureVideoPreviewLayer *prevLayer;


@property (nonatomic,strong)UIButton *pauseButton;


@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.appDelegate = [[UIApplication sharedApplication] delegate];
    
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"MainViewController did load");
    
  //  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addSession) name:@"captureStarted" object:nil];
    
   // self.pauseButton.imageView.image = [UIImage imageNamed:@"pauseColorCircle.png"];

    [self.view addSubview:self.pauseButton];
    
    AVCaptureVideoPreviewLayer* preview = [[CameraEngine engine] getPreviewLayer];

        preview.frame = self.view.frame;
        preview.masksToBounds = YES;
    
    [self.view.layer insertSublayer:preview atIndex:0];

    
    
    NSLog(@"Finished MainViewController view did load");
    
    	// Do any additional setup after loading the view.
}
/*

-(void)addSession
{
    NSLog(@"Adding session");
    [self.prevLayer setSession:self.appDelegate.captureSession];
    NSLog(@"Session added");

        
    
 
    
    NSLog(@"Done addSession");
    
}
*/
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIButton *)pauseButton
{
    if(!_pauseButton)
    {
        UIImage *image = [UIImage imageNamed:@"pauseColorCircle"];
        NSLog(@"image exists? %@",image);
        _pauseButton = [[UIButton alloc]init];
        _pauseButton.frame=CGRectMake(130, 410, 60, 60);
        [_pauseButton setBackgroundImage:image forState:UIControlStateNormal];
        //_pauseButton.backgroundColor= [UIColor blackColor];
      //  _pauseButton.clipsToBounds=YES;
        
        [_pauseButton addTarget:self
                         action:@selector(pauseButtonPress:)
               forControlEvents:UIControlEventTouchUpInside];
        
        NSLog(@"finished making pauseButton");
    }
    return _pauseButton;
    
    
    
}

-(void)pauseButtonPress:(UIButton *)pauseButton
{
    if(![[CameraEngine engine] isPaused])
    {
        [[CameraEngine engine] pauseCapture];
        [_pauseButton setBackgroundImage: [UIImage imageNamed:@"playWhiteCircle"] forState:UIControlStateNormal];


    }
    else
    {
        [[CameraEngine engine] resumeCapture];
        [_pauseButton setBackgroundImage: [UIImage imageNamed:@"pauseColorCircle"] forState:UIControlStateNormal];

    }
    
    
    
}

@end
