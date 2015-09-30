//
//  SettingsViewController.m
//  LiveStreaming2
//
//  Created by Dalton on 9/27/15.
//  Copyright © 2015 Dalton. All rights reserved.
//

#import "SettingsViewController.h"

#import <OpenEars/OELanguageModelGenerator.h>
#import <OpenEars/OEAcousticModel.h>

#import <OpenEars/OEPocketsphinxController.h>
#import <OpenEars/OEAcousticModel.h>

#import "ViewController.h"

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UITextField *alertWordTextField;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.alertWordTextField.delegate = self;
 
    OELanguageModelGenerator *lmGenerator = [[OELanguageModelGenerator alloc] init];
    
    NSArray *words = [NSArray arrayWithObjects:@"WORD", @"STATEMENT", @"OTHER WORD", @"A PHRASE", nil];
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
    
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    self.customAlertWord = [NSString stringWithFormat:@"%@", self.alertWordTextField.text];
    
    self.fliteController = [[OEFliteController alloc] init];
    self.slt = [[Slt alloc] init];
    
    [self.fliteController say:[NSString stringWithFormat:@"Your custom alert word or phrase is %@. You can now say help and %@ to start recording", self.customAlertWord, self.customAlertWord] withVoice:self.slt];
    
    [textField resignFirstResponder];
    
    return YES;
}




- (IBAction)doneButtonTapped:(id)sender {
    
//    [self dismissViewControllerAnimated:YES completion:nil];
[self performSegueWithIdentifier:@"unwindSegue" sender:self];
    
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



@end
