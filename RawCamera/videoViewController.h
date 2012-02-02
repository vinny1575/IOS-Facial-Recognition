//
//  videoViewController.h
//  RawCamera
//
//  Created by Alan Gonzalez on 11/25/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>

@interface videoViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate>{
    UIView *vidUIView;
    UIView *faceView;   //for face rectangle
    UIView *mouth;  //for mouth box.
    UIImageView *imageView;
    CGRect viewRect;
    int proctr;
    BOOL deferImageProcessing;
    BOOL createdFaceBox;
    dispatch_queue_t queue;
    AVCaptureSession *session;
    CIImage *ciimage;
    CIDetector *detector;


}

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIView *vidUIView;

@end
