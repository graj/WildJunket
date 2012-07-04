//
//  RSSFeedWebViewControler.m
//  WildJunket
//
//  Created by David García Fernández on 04/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RSSFeedWebViewControler.h"
#import "RSSEntry.h"

@interface RSSFeedWebViewControler ()

@end

@implementation RSSFeedWebViewControler
@synthesize webView = _webView;
@synthesize entry = _entry;


- (void)viewWillAppear:(BOOL)animated {
    
    NSURL *url = [NSURL URLWithString:_entry.articleUrl];    
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
    
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)dealloc{
    [_entry release];
    _entry = nil;
    [_webView release];
    _webView = nil;
    [super dealloc];
}

@end
