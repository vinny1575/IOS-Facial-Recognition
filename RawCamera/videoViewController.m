//
//  videoViewController.m
//  RawCamera
//
//  Created by Alan Gonzalez on 11/25/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "videoViewController.h"

@implementation videoViewController
@synthesize imageView;
@synthesize vidUIView;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    //used in the captureoutput method below.
    detector = [CIDetector detectorOfType:CIDetectorTypeFace 
                                  context:nil options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyLow forKey:CIDetectorAccuracy]];
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    self.vidUIView = nil;
    [self setImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    //AVCapture instance wraps the AVCcaptureDevice and AVCaptureDeviceInput and AVCaptureOutput into a viewing session.
    session = [[AVCaptureSession alloc] init];
    //Chosing the Mediatype to Accept (Change The last parameter to get audio.
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *captureDevice = nil;
    for (AVCaptureDevice *device in videoDevices)
    {
        //when it iterates to the dront camera set capturedevice to the front camera
        if (device.position == AVCaptureDevicePositionFront)
        {
            captureDevice = device;
            break;
        }
    }
    
    NSLog(@"%@", captureDevice);
    
    NSError *error = nil;
    
    //Takes the AVCaptureDevice as a parameter to create an input.
    AVCaptureDeviceInput *vidInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    
    AVCaptureVideoDataOutput * vidOutput = [[AVCaptureVideoDataOutput alloc] init];
    [vidOutput setAlwaysDiscardsLateVideoFrames:YES];
    [vidOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]]; 	
    
    [vidOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];

    
    //Preview layer is kind of an output, but not really. The output is generally a file of some sort (movie, recording, etc)
    AVCaptureVideoPreviewLayer *vidLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    
    //Making the Frame
    viewRect = CGRectMake(0, 0, 320, 480);
    vidLayer.frame = viewRect;
    [vidUIView.layer addSublayer:vidLayer];
    
    //video session add imput, output and start it
    if(vidInput){
        [session addInput:vidInput];
        [session addOutput:vidOutput];
        [session startRunning];
            NSLog(@"running");
        //  [session addOutput:vidOut];
    }else{
        NSLog(@"Error");
    }
	
    //temporary.
                     
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{

    
    //create a pixelbuffer from the sample buffer
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    //Create a ciimage from the pixelbuffer
    ciimage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    
    

    //scales the image that is seen by the cidetector down
    CIImage *myCiImage = [ciimage imageByApplyingTransform:CGAffineTransformMakeScale(.73, -.68)];
    //because the scaling for y is negative it mirrors on the left side. I then have to translate (move) the image
    //over by its width.
    CIImage *transImage = [myCiImage imageByApplyingTransform:CGAffineTransformMakeTranslation(0, 320)];

    
    //options for features array below. It changes the orientation of the image 90 degrees(option 6)
    NSDictionary *imageOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:6]
                                               forKey:CIDetectorImageOrientation];
    //grabs features from detectore wich is implemented in viewdidload above. uses he options above
    NSArray *features = [detector featuresInImage:transImage options:imageOptions];
    for(CIFaceFeature *ff in features){
        //remove face rectangle from view before adding another one.
        //[faceView removeFromSuperview];
        [mouth removeFromSuperview];
        //flip X and Y for the face box
        CGFloat faceY = ff.bounds.origin.x;
        CGFloat faceX = ff.bounds.origin.y;
        CGFloat faceHeight = ff.bounds.size.height;
        CGFloat faceWidth = ff.bounds.size.width;
        //make rectangle for face based on face bounds and position from cidetector
        CGRect features = CGRectMake(faceX ,faceY , faceWidth, faceHeight);

        NSLog(@"feature x %f, y %f", faceX, faceY);
        
        //Using if with BOOL to create the red face box once then move it around afterwards.
        if(createdFaceBox == NO){
            //Create face Box.
            faceView = [[UIView alloc] initWithFrame:features];
            // add a border around the newly created UIView
            faceView.layer.borderWidth = 10;
            faceView.layer.borderColor = [[UIColor redColor] CGColor];
            //add facerect to uiview
            [vidUIView addSubview:faceView];
            createdFaceBox = YES;
        }else{
            [faceView setFrame:features];
        }
        if(ff.hasMouthPosition)
        {
            // create a UIView with a size based on the width of the face
           mouth = [[UIView alloc] initWithFrame:CGRectMake(ff.mouthPosition.y, ff.mouthPosition.x, faceWidth*0.4, faceWidth*0.1)];
            // change the background color for the mouth to green
            mouth.backgroundColor = [UIColor greenColor];
            // create a cgpoint with the x set to the y axis and visa versa.
            CGPoint mouthPos = CGPointMake(ff.mouthPosition.y, ff.mouthPosition.x);
            // set the position of the mouthView based on the face
            [mouth setCenter:mouthPos];
            // round the corners
            mouth.layer.cornerRadius = faceWidth*0.2;
            // add the new view to the window
            [vidUIView addSubview:mouth];
        }    
        
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


@end
