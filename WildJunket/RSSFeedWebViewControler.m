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

@interface RSSFeedWebViewControler ()

@end

@implementation RSSFeedWebViewControler
@synthesize webView = _webView;
@synthesize entry = _entry;
@synthesize activityIndicator=_activityIndicator;

-(IBAction)shareButton:(id)sender{
    //Pulsado botón compartir, mostrar menu
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"Share with the world" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Twitter", @"Email", nil];
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [popupQuery showInView:self.view];
    [popupQuery release];

}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
        case 0:
            if ([TWTweetComposeViewController canSendTweet])
            {
                TWTweetComposeViewController *tweetSheet =
                [[TWTweetComposeViewController alloc] init];
                NSString *text=[self.entry.articleTitle stringByAppendingString:@" (WildJunket.com)"];
                [tweetSheet setInitialText:text];
                [tweetSheet addURL:[NSURL URLWithString:self.entry.articleUrl]];
                [self presentModalViewController:tweetSheet animated:YES];
            }
            else
            {
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
            //Email
            break;
        case 2:
            //Cancel
            break;
    }
}


- (void)viewWillAppear:(BOOL)animated {
    
    NSURL *url = [NSURL URLWithString:_entry.articleUrl];    
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
    self.activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	self.activityIndicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
	self.activityIndicator.center = self.view.center;
    [self.activityIndicator setColor:[UIColor brownColor]];
    [self.view addSubview: self.activityIndicator];
    
    
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

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	// starting the load, show the activity indicator in the status bar
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[self.activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	// finished loading, hide the activity indicator in the status bar
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self.activityIndicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	// load error, hide the activity indicator in the status bar
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
	// report the error inside the webview
	//NSString* errorString = [NSString stringWithFormat:@"<html><center><br /><br /><font size=+5 color='red'>Error<br /><br />Your request %@</font></center></html>", error.localizedDescription];
	//[self.webView loadHTMLString:errorString baseURL:nil];
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