//
//  RSSFeedWebViewControler.m
//  WildJunket
//
//  Created by David García Fernández on 04/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RSSFeedWebViewControler.h"
#import "RSSEntry.h"
#import <Twitter/Twitter.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "SVProgressHUD.h"
#import <QuartzCore/QuartzCore.h>

@interface RSSFeedWebViewControler ()

@end

@implementation RSSFeedWebViewControler
@synthesize webView = _webView;
@synthesize entry = _entry;
@synthesize activityIndicator=_activityIndicator;

-(IBAction)shareButton:(id)sender{
    //Pulsado botón compartir, mostrar menu
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"Share with the world" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Twitter",@"Facebook",@"Email", @"Copy link", nil];
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [popupQuery showInView:self.view];
    [popupQuery release];

}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
        case 0:
            if ([TWTweetComposeViewController canSendTweet])
            {
                #ifdef CONFIGURATION_Beta
                [TestFlight passCheckpoint:@"pulsadoTwitter"];
                #endif
                TWTweetComposeViewController *tweetSheet =
                [[TWTweetComposeViewController alloc] init];
                NSString *text=[self.entry.articleTitle stringByAppendingString:@" (WildJunket.com)"];
                [tweetSheet setInitialText:text];
                [tweetSheet addURL:[NSURL URLWithString:self.entry.articleUrl]];
                [self presentModalViewController:tweetSheet animated:YES];
            }
            else
            {
                #ifdef CONFIGURATION_Beta
                [TestFlight passCheckpoint:@"errorTwitter"];
                #endif
                UIAlertView *alertView = [[UIAlertView alloc]
                                          initWithTitle:@"Sorry"
                                          message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup"
                                          delegate:self
                                          cancelButtonTitle:@"OK"                                                   
                                          otherButtonTitles:nil];
                [alertView show];
            }
            break;
            
        case 1:
            
            //Comprobar que en esta version se puede usar esa clase
            if(NSClassFromString(@"SLComposeViewController")) {
                // Do something
                int c=0;
            }
            
            if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
            {
#ifdef CONFIGURATION_Beta
                [TestFlight passCheckpoint:@"pulsadoFacebook"];
#endif
                SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                
                SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
                    if (result == SLComposeViewControllerResultCancelled) {
                        
                        NSLog(@"Cancelled");
                        
                    } else
                        
                    {
                        NSLog(@"Done");
                    }
                    
                    [controller dismissViewControllerAnimated:YES completion:Nil];
                };
                controller.completionHandler =myBlock;
                NSString *text=[self.entry.articleTitle stringByAppendingString:@" (WildJunket.com)"];
                [controller setInitialText:text];
                [controller addURL:[NSURL URLWithString:self.entry.articleUrl]];
                [self presentModalViewController:controller animated:YES];
            }
            else
            {
#ifdef CONFIGURATION_Beta
                [TestFlight passCheckpoint:@"errorFacebook"];
#endif
                UIAlertView *alertView = [[UIAlertView alloc]
                                          initWithTitle:@"Sorry"
                                          message:@"You can't post to Facebook right now, make sure your device has an internet connection and you have at least one Facebook account setup"
                                          delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
                [alertView show];
            }
            break;
            
        case 2:
            //Email
            if ([MFMailComposeViewController canSendMail])
            {
                #ifdef CONFIGURATION_Beta
                [TestFlight passCheckpoint:@"canSendEmail"];
                #endif
                MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
                
                mailer.mailComposeDelegate = self;
                mailer.navigationBar.tintColor = [UIColor colorWithRed:140.0/255.0 green:98.0/255.0 blue:57.0/255.0 alpha:1.0];
                [mailer.navigationBar setClearsContextBeforeDrawing:YES];
                
                [mailer setSubject:@"WildJunket cool article"];
                
                NSString *emailBody = [[[[[@"Woow check out this article from WildJunket.com:\n" stringByAppendingString:@"<a href=\""] stringByAppendingString:self.entry.articleUrl] stringByAppendingString:@"\">"] stringByAppendingString:self.entry.articleTitle] stringByAppendingString:@"</a>"];
                
                [mailer setMessageBody:emailBody isHTML:YES];
                
                [self presentModalViewController:mailer animated:YES];
                
                [mailer release];
            }
            else
            {
                #ifdef CONFIGURATION_Beta
                [TestFlight passCheckpoint:@"errorEmail"];
                #endif
                UIAlertView *alertView = [[UIAlertView alloc]
                                          initWithTitle:@"Sorry"
                                          message:@"You can't send a email right now, make sure your device has an internet connection and you have at least one email account setup"
                                          delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
                [alertView show];
                
            }
            break;
        case 3:
            {
                //Copy link
                UIPasteboard *pb = [UIPasteboard generalPasteboard];
                [pb setString:self.entry.articleUrl];
            }
            break;
        case 4:
            //Cancel
            break;
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    
    // Remove the mail view
    [self dismissModalViewControllerAnimated:YES];
}


- (void)viewWillAppear:(BOOL)animated {
    
    //Shows status bar
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    
    //Readability
    //NSURL *url = [NSURL URLWithString:[@"http://www.readability.com/m?url=" stringByAppendingString:_entry.articleUrl]];
    
    //Non-readability
    NSURL *url = [NSURL URLWithString:_entry.articleUrl];
    
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    //self.activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	//self.activityIndicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
	//self.activityIndicator.center = self.view.center;
    //[self.activityIndicator setColor:[UIColor brownColor]];
    //[self.view addSubview: self.activityIndicator];
    
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    //Shows status bar
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait ||
            interfaceOrientation == UIInterfaceOrientationLandscapeLeft || 
            interfaceOrientation == UIInterfaceOrientationLandscapeRight ||
            interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown );
}

-(void)willRotateToInterfaceOrientation: (UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
    
    CALayer *sublayer = [CALayer layer];
    sublayer.name=@"title";
    if ((orientation == UIInterfaceOrientationLandscapeLeft) || (orientation == UIInterfaceOrientationLandscapeRight)) {
        
        //Cambia layer de título
        
        
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad && IS_IPHONE_5){
            sublayer.contents = (id) [UIImage imageNamed:@"wj_title_landscape-568h.png"].CGImage;
            sublayer.frame = CGRectMake(0, 0, 568, 32);
        }
        else{
            sublayer.contents = (id) [UIImage imageNamed:@"wj_title_landscape.png"].CGImage;
            sublayer.frame = CGRectMake(0, 0, 480, 32);   
        }
        
        
        
    }
    else{
        sublayer.contents = (id) [UIImage imageNamed:@"wj_title.png"].CGImage;
        sublayer.frame = CGRectMake(0, 0, 320, 44);
    }
    
    for (CALayer *layer in self.navigationController.navigationBar.layer.sublayers) {
        if ([layer.name isEqualToString:@"title"]) {
            [layer removeFromSuperlayer];
            break;
        }
    }
    [self.navigationController.navigationBar.layer addSublayer:sublayer];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	// starting the load, show the activity indicator in the status bar
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	//[self.activityIndicator startAnimating];
    [SVProgressHUD showWithStatus:@"Loading article..."];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	// finished loading, hide the activity indicator in the status bar
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	//[self.activityIndicator stopAnimating];
    [SVProgressHUD dismiss];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	// load error, hide the activity indicator in the status bar
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [SVProgressHUD dismiss];
    
		
}


-(void)dealloc{
    [_entry release];
    _entry = nil;
    [_webView release];
    _webView = nil;
    [_activityIndicator release];
    _activityIndicator = nil;
    [super dealloc];
}

@end