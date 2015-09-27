//
//  ViewController.h
//  LiveStreaming2
//
//  Created by Dalton on 9/27/15.
//  Copyright © 2015 Dalton. All rights reserved.
//

#import <UIKit/UIKit.h>


#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import <Slt/Slt.h>
#import <OpenEars/OEFliteController.h>

#import <OpenEars/OEEventsObserver.h>


#define CAPTURE_FRAMES_PER_SECOND		20

@interface ViewController : UIViewController <OEEventsObserverDelegate, AVCaptureFileOutputRecordingDelegate>

{
    BOOL WeAreRecording;
    
    AVCaptureSession *CaptureSession;
    AVCaptureMovieFileOutput *MovieFileOutput;
    AVCaptureDeviceInput *VideoInputDevice;
}

@property (strong, nonatomic) OEEventsObserver *openEarsEventsObserver;
@property (strong, nonatomic) OEFliteController *fliteController;
@property (weak, nonatomic) IBOutlet UILabel *recordingLabel;

@property (retain) AVCaptureVideoPreviewLayer *PreviewLayer;

- (void) CameraSetOutputProperties;
- (AVCaptureDevice *) CameraWithPosition:(AVCaptureDevicePosition) Position;

// this is a flite voice
@property (strong, nonatomic) Slt *slt;

@end

