//
//  MFViewController.m
//  vidwall
//
//  Created by Matthew Chung on 7/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MFViewController.h"

#define ARC4RANDOM_MAX 0x100000000
#define RECONNECT_TIME 0.5

@interface MFViewController ()

@end

@implementation MFViewController {
    MPMoviePlayerController *_videoPlayer;
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    BOOL reconnect;
    NSString *videoUrlFormat;
    NSMutableDictionary *dic;
}

@synthesize button00 = _button00;
@synthesize button01 = _button01;
@synthesize button02 = _button02;
@synthesize button03 = _button03;
@synthesize button04 = _button04;
@synthesize button05 = _button05;
@synthesize button06 = _button06;
@synthesize button10 = _button10;
@synthesize button11 = _button11;
@synthesize button12 = _button12;
@synthesize button13 = _button13;
@synthesize button14 = _button14;
@synthesize button15 = _button15;
@synthesize button16 = _button16;
@synthesize button20 = _button20;
@synthesize button21 = _button21;
@synthesize button22 = _button22;
@synthesize button23 = _button23;
@synthesize button24 = _button24;
@synthesize button25 = _button25;
@synthesize button26 = _button26;
@synthesize moviename = _moviename;
@synthesize ip = _ip;
@synthesize statusBox = _statusBox;

- (void)viewDidLoad
{
    reconnect = NO;
//    reconnectCount = 0;
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.ip.delegate = self;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if([userDefaults stringForKey:@"master"])       
        self.ip.text =  [userDefaults stringForKey:@"master"];
    
    NSString *vidoesBundlePath = [[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:@"videos.bundle"];
    NSBundle *videosBundle = [NSBundle bundleWithPath:vidoesBundlePath];
    videoUrlFormat = [[videosBundle bundlePath] stringByAppendingString:@"/%@-%@.mov"];
}

- (void)loadMovie:(NSString *)moviePrefix {
    
    CGRect frame = CGRectMake(0, 0, 768, 1024);
    
    // now we can kick off the loading of the
    NSString *path = [NSString stringWithFormat:videoUrlFormat, moviePrefix, self.moviename.text];
    
    if ([dic objectForKey:path]) {
        _ideoPlayer = [dic objectForKey:path];
        [_videoPlayer stop];
        NSLog(@"loading cached");
    }
    else {
        NSURL *url = [NSURL fileURLWithPath:path];
        if (url) {
            _videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
            // video player needs to use the screen's bounds
            _videoPlayer.view.frame = frame;
            _videoPlayer.controlStyle = MPMovieControlStyleNone;
            _videoPlayer.scalingMode = MPMovieScalingModeNone;
            _videoPlayer.allowsAirPlay = NO;
            _videoPlayer.shouldAutoplay = NO;
            [dic setObject:_videoPlayer forKey:path];
        }
    }
    
    [_videoPlayer prepareToPlay];
    
    // we haven't added the player to the window yet, if we do before the video has loaded
    // we'll get a really quick flash while it does. this will be called once the video loads
    // and it's safe to add the player to the window
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoLoadDidChange:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:_videoPlayer];
    
    // we need to know when the video has finished playing so that the app can continue to 
    // load/go in to it's main ui.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoDidFinished:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:_videoPlayer];    
}

- (void)videoLoadDidChange:(NSNotification *)notification
{
    // remove our notification, we won't need it again
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerLoadStateDidChangeNotification
                                                  object:_videoPlayer];
}



- (void)videoDidFinished:(NSNotification *)notification
{
    [self videoFinishCommon];
}

- (void)videoFinishCommon
{
    // remove our notifcation, won't need it again
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:_videoPlayer];
    // stop playing the movie
    // we're done playing, remove the player from the view heirarchy
    [UIView animateWithDuration:0.4
                     animations:^{
                         _videoPlayer.view.alpha = 0;
                     } 
                     completion:^(BOOL finished) {
                         [_videoPlayer.view removeFromSuperview];
                         // and get rid of it
                         _videoPlayer = nil;
                     }];
}

- (void)viewDidUnload
{
    [self setButton00:nil];
    [self setButton01:nil];
    [self setButton02:nil];
    [self setButton03:nil];
    [self setButton04:nil];
    [self setButton05:nil];
    [self setButton06:nil];
    [self setButton10:nil];
    [self setButton11:nil];
    [self setButton12:nil];
    [self setButton13:nil];
    [self setButton14:nil];
    [self setButton15:nil];
    [self setButton16:nil];
    [self setButton20:nil];
    [self setButton21:nil];
    [self setButton22:nil];
    [self setButton23:nil];
    [self setButton24:nil];
    [self setButton25:nil];
    [self setButton26:nil];
    [self setMoviename:nil];
    [self setIp:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation == UIDeviceOrientationPortrait) {
        return YES;
    }
    return NO;
}

- (void)changeButton:(id)sender
{
    if (self.ip) {
        [self.ip resignFirstResponder];
    }
    UIButton *s = (UIButton *)sender;
    for (UIView *v in self.view.subviews) {
        if ([v isKindOfClass:[UIButton class]]) {
            UIButton *vn = (UIButton *)v;
            if ([vn isEqual:s]) {
                [s setTitle:@"ON" forState:UIControlStateNormal];
                s.enabled = NO;
            } else {
                if ([vn.titleLabel.text isEqual:@"ON"]) {
                    [vn setTitle:nil forState:UIControlStateNormal];
                    vn.enabled = YES;
                }
            }
        }
    }
}
- (IBAction)pressed00:(id)sender {
    [self changeButton:sender];
    self.moviename.text = @"00";    
}
- (IBAction)pressed01:(id)sender {
    [self changeButton:sender];
    self.moviename.text = @"01";    
}
- (IBAction)pressed02:(id)sender {
    [self changeButton:sender];
    self.moviename.text = @"02";        
}
- (IBAction)pressed03:(id)sender {
    [self changeButton:sender];
    self.moviename.text = @"03";        
}
- (IBAction)pressed04:(id)sender {
    [self changeButton:sender];
    self.moviename.text = @"04";        
}
- (IBAction)pressed05:(id)sender {
    [self changeButton:sender];
    self.moviename.text = @"05";        
}
- (IBAction)pressed06:(id)sender {
    [self changeButton:sender];
    self.moviename.text = @"06";        
}
- (IBAction)pressed10:(id)sender {
    [self changeButton:sender];
    self.moviename.text = @"10";    
}
- (IBAction)pressed11:(id)sender {
    [self changeButton:sender];
    self.moviename.text = @"11";        
}
- (IBAction)pressed12:(id)sender {
    [self changeButton:sender];
    self.moviename.text = @"12";    
}
- (IBAction)pressed13:(id)sender {
    [self changeButton:sender];
    self.moviename.text = @"13";        
}
- (IBAction)pressed14:(id)sender {
    [self changeButton:sender];
    self.moviename.text = @"14";    
}
- (IBAction)pressed15:(id)sender {
    [self changeButton:sender];
    self.moviename.text = @"15";    
}
- (IBAction)pressed16:(id)sender {
    [self changeButton:sender];
    self.moviename.text = @"16";    
}
- (IBAction)pressed20:(id)sender {
    [self changeButton:sender];
    self.moviename.text = @"20";    
}
- (IBAction)pressed21:(id)sender {
    [self changeButton:sender];
    self.moviename.text = @"21";    
}
- (IBAction)pressed22:(id)sender {
    [self changeButton:sender];
    self.moviename.text = @"22";    
}
- (IBAction)pressed23:(id)sender {
    [self changeButton:sender];
    self.moviename.text = @"23";    
}
- (IBAction)pressed24:(id)sender {
    [self changeButton:sender];
    self.moviename.text = @"24";    
}
- (IBAction)pressed25:(id)sender {
    [self changeButton:sender];
    self.moviename.text = @"25";    
}
- (IBAction)pressed26:(id)sender {
    [self changeButton:sender];
    self.moviename.text = @"26";    
}

- (IBAction)load:(id)sender {
    if (!self.moviename.text || self.moviename.text.length == 0) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"select a button from the grid above"
                                                          message:@"select a button from the grid above to select a movie"
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        
        [message show];
    }
}

- (IBAction)play:(id)sender {
    if (_videoPlayer) {
        _videoPlayer.view.alpha = 0;
        if (!_videoPlayer.view.superview) {
            [self.view addSubview:_videoPlayer.view];
            [self.view bringSubviewToFront:_videoPlayer.view];
        }
        [UIView animateWithDuration:0.4
                         animations:^{
                             _videoPlayer.view.alpha = 1;
                         } 
                         completion:^(BOOL finished) {
                             [_videoPlayer play];
                         }];
    }
}

- (IBAction)connect:(id)sender
{
    if (self.ip) {
        [self.ip resignFirstResponder];
    }
    if (!self.moviename.text || self.moviename.text.length == 0) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"select a button from the grid above"
                                                          message:@"select a button from the grid above to select a movie"
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        
        [message show];
        return;
    }
    
    if (!self.ip.text || self.ip.text.length == 0) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"enter a host"
                                                          message:@"enter a host to connect"
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];        
        [message show];
    }
    else {
        [self connectToServer];
    }
}    

- (void)connectToServer
{
    //  in retry case, this makes sure this call is not overcalled
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self connectionCleanup];
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)self.ip.text, 3333, &readStream, &writeStream);
    
    inputStream = (__bridge_transfer NSInputStream *)readStream;
    outputStream = (__bridge_transfer NSOutputStream *)writeStream;
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
    [outputStream open];
    NSLog(@"end of connectToServer. reconnect: %@", reconnect ? @"YES" : @"NO");
}

-(void)connectionCleanup {
    [inputStream close];
    [outputStream close];
    
    [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    outputStream.delegate = nil;
    inputStream.delegate = nil;
}

- (double)randomReconnectTime {
    return RECONNECT_TIME+(double)arc4random()/ARC4RANDOM_MAX;
}

- (void)processInputStreamMsg:(NSString*)steamMsg {
    steamMsg = [steamMsg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSLog(@"steamMsg: %@", steamMsg);
    if ([steamMsg hasPrefix:@"prepare"]) {
        NSArray *commandParts = [steamMsg componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSLog(@"command parts: %@", commandParts);
        if (commandParts.count >= 2) {
            [self loadMovie:[commandParts objectAtIndex:1]];
        }
    }
    else if ([steamMsg isEqualToString:@"play"]) {
        [self play:nil];
    }
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    if (theStream == inputStream) {
        if (streamEvent == NSStreamEventOpenCompleted) {            
        }
        else if(streamEvent == NSStreamEventHasBytesAvailable) {
            NSLog(@"input got NSStreamEventHasBytesAvailable");
            NSInteger       bytesRead;
            uint8_t         buffer[32768];
            
            // Pull some data off the network.            
            bytesRead = [(NSInputStream*)theStream read:buffer maxLength:sizeof(buffer)];
            if (bytesRead == -1) {
            } else if (bytesRead == 0) {
                NSLog(@"no bytes available");
                reconnect = YES;
                double reconnectTime = [self randomReconnectTime];
                [self performSelector:@selector(connectToServer) withObject:nil afterDelay:reconnectTime];
                NSLog(@"reconnecting in %f", reconnectTime);
            } else {
                buffer[bytesRead] = '\0';
                NSString *str = [NSString stringWithCString:(const char *)buffer encoding:NSUTF8StringEncoding];
                NSLog(@"%@", str);
                [self processInputStreamMsg:str];
            }
        }
        else if(streamEvent == NSStreamEventErrorOccurred) {
            if (reconnect == NO) {
                [self.statusBox setBackgroundColor:[UIColor redColor]];
            } else {
                reconnect = YES;
                double reconnectTime = [self randomReconnectTime];
                [self performSelector:@selector(connectToServer) withObject:nil afterDelay:reconnectTime];
                NSLog(@"reconnecting in %f", reconnectTime);
            }   
        }
    }
    else {
        if (streamEvent == NSStreamEventOpenCompleted) {            
            if (reconnect) {
                reconnect = NO;
            }
            [self.statusBox setBackgroundColor:[UIColor greenColor]];
            NSString *placeholderName = [NSString stringWithFormat:@"logo-%@", self.moviename.text];
            UIImageView *placeholder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:placeholderName]];
            [self.view addSubview:placeholder];
            [self.view bringSubviewToFront:placeholder];
        }
        else if(streamEvent == NSStreamEventHasBytesAvailable) {
            NSLog(@"output got NSStreamEventHasBytesAvailable");
        }
        
        else if(streamEvent == NSStreamEventErrorOccurred) {
            [self.statusBox setBackgroundColor:[UIColor redColor]];
            
            reconnect = YES;
            double reconnectTime = [self randomReconnectTime];
            [self performSelector:@selector(connectToServer) withObject:nil afterDelay:reconnectTime];
            NSLog(@"reconnecting in %f", reconnectTime);
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:textField.text forKey:@"master"];
    [userDefaults synchronize];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textfield{
    if([textfield isEqual:self.ip]){
        [textfield resignFirstResponder];
    }
    return YES;
}
@end
