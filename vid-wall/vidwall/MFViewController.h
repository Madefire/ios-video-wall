//
//  MFViewController.h
//  vidwall
//
//  Created by Matthew Chung on 7/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>  

@interface MFViewController : UIViewController <NSStreamDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIButton *button00;
@property (strong, nonatomic) IBOutlet UIButton *button01;
@property (strong, nonatomic) IBOutlet UIButton *button02;
@property (strong, nonatomic) IBOutlet UIButton *button03;
@property (strong, nonatomic) IBOutlet UIButton *button04;
@property (strong, nonatomic) IBOutlet UIButton *button05;
@property (strong, nonatomic) IBOutlet UIButton *button06;
@property (strong, nonatomic) IBOutlet UIButton *button10;
@property (strong, nonatomic) IBOutlet UIButton *button11;
@property (strong, nonatomic) IBOutlet UIButton *button12;
@property (strong, nonatomic) IBOutlet UIButton *button13;
@property (strong, nonatomic) IBOutlet UIButton *button14;
@property (strong, nonatomic) IBOutlet UIButton *button15;
@property (strong, nonatomic) IBOutlet UIButton *button16;
@property (strong, nonatomic) IBOutlet UIButton *button20;
@property (strong, nonatomic) IBOutlet UIButton *button21;
@property (strong, nonatomic) IBOutlet UIButton *button22;
@property (strong, nonatomic) IBOutlet UIButton *button23;
@property (strong, nonatomic) IBOutlet UIButton *button24;
@property (strong, nonatomic) IBOutlet UIButton *button25;
@property (strong, nonatomic) IBOutlet UIButton *button26;
@property (strong, nonatomic) IBOutlet UILabel *moviename;
@property (strong, nonatomic) IBOutlet UITextField *ip;
@property (strong, nonatomic) IBOutlet UIView *statusBox;

- (IBAction)pressed00:(id)sender;
- (IBAction)pressed01:(id)sender;
- (IBAction)pressed02:(id)sender;
- (IBAction)pressed03:(id)sender;
- (IBAction)pressed04:(id)sender;
- (IBAction)pressed05:(id)sender;
- (IBAction)pressed06:(id)sender;
- (IBAction)pressed10:(id)sender;
- (IBAction)pressed11:(id)sender;
- (IBAction)pressed12:(id)sender;
- (IBAction)pressed13:(id)sender;
- (IBAction)pressed14:(id)sender;
- (IBAction)pressed15:(id)sender;
- (IBAction)pressed16:(id)sender;
- (IBAction)pressed20:(id)sender;
- (IBAction)pressed21:(id)sender;
- (IBAction)pressed22:(id)sender;
- (IBAction)pressed23:(id)sender;
- (IBAction)pressed24:(id)sender;
- (IBAction)pressed25:(id)sender;
- (IBAction)pressed26:(id)sender;
- (IBAction)load:(id)sender;
- (IBAction)play:(id)sender;
- (IBAction)connect:(id)sender;

@end
