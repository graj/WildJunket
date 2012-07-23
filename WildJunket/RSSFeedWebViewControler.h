//
//  RSSFeedWebViewControler.h
//  WildJunket
//
//  Created by David García Fernández on 04/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class RSSEntry;

@interface RSSFeedWebViewControler : UIViewController <UIWebViewDelegate,UIActionSheetDelegate,MFMailComposeViewControllerDelegate>{
    UIWebView *_webView;
    RSSEntry *_entry;
    UIActivityIndicatorView *_activityIndicator;	
}
@property (retain) IBOutlet UIWebView *webView;
@property (retain) RSSEntry *entry;
@property (retain) UIActivityIndicatorView *activityIndicator;
-(IBAction)shareButton:(id)sender;

@end
