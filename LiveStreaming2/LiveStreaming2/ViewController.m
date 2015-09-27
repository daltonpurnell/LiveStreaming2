//
//  ViewController.m
//  LiveStreaming2
//
//  Created by Dalton on 9/27/15.
//  Copyright © 2015 Dalton. All rights reserved.
//

#import "ViewController.h"
#import <OpenEars/OELanguageModelGenerator.h>
#import <OpenEars/OEAcousticModel.h>

#import <OpenEars/OEPocketsphinxController.h>
#import <OpenEars/OEAcousticModel.h>




@interface ViewController ()

@end

@implementation ViewController
@synthesize PreviewLayer;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    self.recordingLabel.hidden = YES;
    
    
    // set up openears language model
    OELanguageModelGenerator *lmGenerator = [[OELanguageModelGenerator alloc] init];
    
    
    NSArray *words = [NSArray arrayWithObjects:@"Help", nil];
    NSString *name = @"NameIWantForMyLanguageModelFiles";
    NSError *err = [lmGenerator generateLanguageModelFromArray:words withFilesNamed:name forAcousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]]; // Change "AcousticModelEnglish" to "AcousticModelSpanish" to create a Spanish language model instead of an English one.
    
    NSString *lmPath = [NSString stringWithFormat:@"%@/NameIWantForMyLanguageModelFiles.%@",[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0],@"DMP"];
    
    NSString *dicPath = [NSString stringWithFormat:@"%@/NameIWantForMyLanguageModelFiles.%@",[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0],@"DMP"];
    
    if(err == nil) {
        
        lmPath = [lmGenerator pathToSuccessfullyGeneratedLanguageModelWithRequestedName:@"NameIWantForMyLanguageModelFiles"];
        dicPath = [lmGenerator pathToSuccessfullyGeneratedDictionaryWithRequestedName:@"NameIWantForMyLanguageModelFiles"];
        
    } else {
        NSLog(@"Error: %@",[err localizedDescription]);
    }
    
    //  initiate the event observer
    
    self.openEarsEventsObserver = [[OEEventsObserver alloc] init];
    [self.openEarsEventsObserver setDelegate:self];
    
    
    [[OEPocketsphinxController sharedInstance] setActive:TRUE error:nil];
    [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:lmPath dictionaryAtPath:dicPath acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:NO]; // Change "AcousticModelEnglish" to "AcousticModelSpanish" to perform Spanish recognition instead of English.
    
    
    //---------------------------------
    //----- SETUP CAPTURE SESSION -----
    //---------------------------------
    NSLog(@"Setting up capture session");
    CaptureSession = [[AVCaptureSession alloc] init];
    
    //----- ADD INPUTS -----
    NSLog(@"Adding video input");
    
    //ADD VIDEO INPUT
    AVCaptureDevice *VideoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (VideoDevice)
    {
        NSError *error;
        VideoInputDevice = [AVCaptureDeviceInput deviceInputWithDevice:VideoDevice error:&error];
        if (!error)
        {
            if ([CaptureSession canAddInput:VideoInputDevice])
                [CaptureSession addInput:VideoInputDevice];
            else
                NSLog(@"Couldn't add video input");
        }
        else
        {
            NSLog(@"Couldn't create video input");
        }
    }
    else
    {
        NSLog(@"Couldn't create video capture device");
    }
    
    //ADD AUDIO INPUT
    NSLog(@"Adding audio input");
    AVCaptureDevice *audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    NSError *error = nil;
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioCaptureDevice error:&error];
    if (audioInput)
    {
        [CaptureSession addInput:audioInput];
    }
    
    
    //----- ADD OUTPUTS -----
    
    //ADD VIDEO PREVIEW LAYER
    NSLog(@"Adding video preview layer");
    [self setPreviewLayer:[[AVCaptureVideoPreviewLayer alloc] initWithSession:CaptureSession]];
    
    PreviewLayer.orientation = AVCaptureVideoOrientationPortrait;
    //<<SET ORIENTATION.  You can deliberatly set this wrong to flip the image and may actually need to set it wrong to get the right image
    
    [[self PreviewLayer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    
    //ADD MOVIE FILE OUTPUT
    NSLog(@"Adding movie file output");
    MovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    
    Float64 TotalSeconds = 60;			//Total seconds
    int32_t preferredTimeScale = 30;	//Frames per second
    CMTime maxDuration = CMTimeMakeWithSeconds(TotalSeconds, preferredTimeScale);	//<<SET MAX DURATION
    MovieFileOutput.maxRecordedDuration = maxDuration;
    
    MovieFileOutput.minFreeDiskSpaceLimit = 1024 * 1024;						//<<SET MIN FREE SPACE IN BYTES FOR RECORDING TO CONTINUE ON A VOLUME
    
    if ([CaptureSession canAddOutput:MovieFileOutput])
        [CaptureSession addOutput:MovieFileOutput];
    
    //SET THE CONNECTION PROPERTIES (output properties)
    [self CameraSetOutputProperties];			//(We call a method as it also has to be done after changing camera)
    
    
    
    //----- SET THE IMAGE QUALITY / RESOLUTION -----
    //Options:
    //	AVCaptureSessionPresetHigh - Highest recording quality (varies per device)
    //	AVCaptureSessionPresetMedium - Suitable for WiFi sharing (actual values may change)
    //	AVCaptureSessionPresetLow - Suitable for 3G sharing (actual values may change)
    //	AVCaptureSessionPreset640x480 - 640x480 VGA (check its supported before setting it)
    //	AVCaptureSessionPreset1280x720 - 1280x720 720p HD (check its supported before setting it)
    //	AVCaptureSessionPresetPhoto - Full photo resolution (not supported for video output)
    NSLog(@"Setting image quality");
    [CaptureSession setSessionPreset:AVCaptureSessionPresetMedium];
    if ([CaptureSession canSetSessionPreset:AVCaptureSessionPreset640x480])		//Check size based configs are supported before setting them
        [CaptureSession setSessionPreset:AVCaptureSessionPreset640x480];
    
    
    
    //----- DISPLAY THE PREVIEW LAYER -----
    //Display it full screen under out view controller existing controls
    NSLog(@"Display the preview layer");
    CGRect layerRect = [[[self view] layer] bounds];
    [PreviewLayer setBounds:layerRect];
    [PreviewLayer setPosition:CGPointMake(CGRectGetMidX(layerRect),
                                          CGRectGetMidY(layerRect))];
    //[[[self view] layer] addSublayer:[[self CaptureManager] previewLayer]];
    //We use this instead so it goes on a layer behind our UI controls (avoids us having to manually bring each control to the front):
    UIView *CameraView = [UIView new];
    [[self view] addSubview:CameraView];
    [self.view sendSubviewToBack:CameraView];
    
    [[CameraView layer] addSublayer:PreviewLayer];
    
    
    //----- START THE CAPTURE SESSION RUNNING -----
    [CaptureSession startRunning];
    
    
}


//********** VIEW WILL APPEAR **********
//View about to be added to the window (called each time it appears)
//Occurs after other view's viewWillDisappear
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    WeAreRecording = NO;
}



//********** CAMERA SET OUTPUT PROPERTIES **********
- (void) CameraSetOutputProperties
{
    //SET THE CONNECTION PROPERTIES (output properties)
    AVCaptureConnection *CaptureConnection = [MovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    
    //Set landscape (if required)
    if ([CaptureConnection isVideoOrientationSupported])
    {
        AVCaptureVideoOrientation orientation = AVCaptureVideoOrientationLandscapeRight;		//<<<<<SET VIDEO ORIENTATION IF LANDSCAPE
        [CaptureConnection setVideoOrientation:orientation];
    }
    
    //Set frame rate (if requried)
    CMTimeShow(CaptureConnection.videoMinFrameDuration);
    CMTimeShow(CaptureConnection.videoMaxFrameDuration);
    
    if (CaptureConnection.supportsVideoMinFrameDuration)
        CaptureConnection.videoMinFrameDuration = CMTimeMake(1, CAPTURE_FRAMES_PER_SECOND);
    if (CaptureConnection.supportsVideoMaxFrameDuration)
        CaptureConnection.videoMaxFrameDuration = CMTimeMake(1, CAPTURE_FRAMES_PER_SECOND);
    
    CMTimeShow(CaptureConnection.videoMinFrameDuration);
    CMTimeShow(CaptureConnection.videoMaxFrameDuration);
}

//********** GET CAMERA IN SPECIFIED POSITION IF IT EXISTS **********
- (AVCaptureDevice *) CameraWithPosition:(AVCaptureDevicePosition) Position
{
    NSArray *Devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *Device in Devices)
    {
        if ([Device position] == Position)
        {
            return Device;
        }
    }
    return nil;
}





- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIDeviceOrientationLandscapeLeft);
}




#pragma mark - oeeventsobserver delegate methods


// if the word spoken is "help" then start recording. otherwise, do nothing.
- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
    NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
    
    if ([hypothesis  isEqual: @"Help"]) {
        
        if ([[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] > 1)		//Only do if device has multiple cameras
        {
            NSLog(@"Toggle camera");
            NSError *error;
            //AVCaptureDeviceInput *videoInput = [self videoInput];
            AVCaptureDeviceInput *NewVideoInput;
            AVCaptureDevicePosition position = [[VideoInputDevice device] position];
            if (position == AVCaptureDevicePositionBack)
            {
                NewVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self CameraWithPosition:AVCaptureDevicePositionBack] error:&error];
            }
            
            if (NewVideoInput != nil)
            {
                [CaptureSession beginConfiguration];		//We can now change the inputs and output configuration.  Use commitConfiguration to end
                [CaptureSession removeInput:VideoInputDevice];
                if ([CaptureSession canAddInput:NewVideoInput])
                {
                    [CaptureSession addInput:NewVideoInput];
                    VideoInputDevice = NewVideoInput;
                }
                else
                {
                    [CaptureSession addInput:VideoInputDevice];
                }
                
                //Set the connection properties again
                [self CameraSetOutputProperties];
                
                
                [CaptureSession commitConfiguration];
            }
            
            if (!WeAreRecording)
            {
                //----- START RECORDING -----
                NSLog(@"START RECORDING");
                WeAreRecording = YES;
                
                self.recordingLabel.hidden = NO;
                
                //Create temporary URL to record to
                NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), @"output.mov"];
                NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                if ([fileManager fileExistsAtPath:outputPath])
                {
                    NSError *error;
                    if ([fileManager removeItemAtPath:outputPath error:&error] == NO)
                    {
                        //Error - handle if requried
                    }
                }
                
                //Start recording
                [MovieFileOutput startRecordingToOutputFileURL:outputURL recordingDelegate:self];
                
            }
            else
            {
                //----- STOP RECORDING -----
                NSLog(@"STOP RECORDING");
                WeAreRecording = NO;
                
                [MovieFileOutput stopRecording];
            }
        }
    } else {
        
        NSLog(@"Hypothesis did not equal: Help");
    }
}

- (void) pocketsphinxDidStartListening {
    NSLog(@"Pocketsphinx is now listening.");
}

- (void) pocketsphinxDidDetectSpeech {
    NSLog(@"Pocketsphinx has detected speech.");
    
}


- (void) pocketsphinxDidDetectFinishedSpeech {
    NSLog(@"Pocketsphinx has detected a period of silence, concluding an utterance.");
    
}


//********** DID FINISH RECORDING TO OUTPUT FILE AT URL **********
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput
didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
      fromConnections:(NSArray *)connections
                error:(NSError *)error
{
    
    NSLog(@"didFinishRecordingToOutputFileAtURL - enter");
    
    BOOL RecordedSuccessfully = YES;
    if ([error code] != noErr)
    {
        // A problem occurred: Find out if the recording was successful.
        id value = [[error userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey];
        if (value)
        {
            RecordedSuccessfully = [value boolValue];
        }
    }
    if (RecordedSuccessfully)
    {
        //----- RECORDED SUCESSFULLY -----
        NSLog(@"didFinishRecordingToOutputFileAtURL - success");
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputFileURL])
        {
            [library writeVideoAtPathToSavedPhotosAlbum:outputFileURL
                                        completionBlock:^(NSURL *assetURL, NSError *error)
             {
                 if (error)
                 {
                     
                 }
             }];
        }
    }
}




- (void) pocketsphinxDidStopListening {
    NSLog(@"Pocketsphinx has stopped listening.");
}

- (void) pocketsphinxDidSuspendRecognition {
    NSLog(@"Pocketsphinx has suspended recognition.");
}

- (void) pocketsphinxDidResumeRecognition {
    NSLog(@"Pocketsphinx has resumed recognition.");
}

- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
    NSLog(@"Pocketsphinx is now using the following language model: \n%@ and the following dictionary: %@",newLanguageModelPathAsString,newDictionaryPathAsString);
}

- (void) pocketSphinxContinuousSetupDidFailWithReason:(NSString *)reasonForFailure {
    NSLog(@"Listening setup wasn't successful and returned the failure reason: %@", reasonForFailure);
}

- (void) pocketSphinxContinuousTeardownDidFailWithReason:(NSString *)reasonForFailure {
    NSLog(@"Listening teardown wasn't successful and returned the failure reason: %@", reasonForFailure);
}

- (void) testRecognitionCompleted {
    NSLog(@"A test file that was submitted for recognition is now complete.");
}


@end