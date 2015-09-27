//
//  SettingsViewController.h
//  LiveStreaming2
//
//  Created by Dalton on 9/27/15.
//  Copyright © 2015 Dalton. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Slt/Slt.h>
#import <OpenEars/OEFliteController.h>

@interface SettingsViewController : UIViewController <UITextFieldDelegate>
@property (strong, nonatomic) NSString *customAlertWord;
@property (strong, nonatomic) OEFliteController *fliteController;
@property (strong, nonatomic) Slt *slt;

@end
