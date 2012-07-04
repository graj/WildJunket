//
//  RSSFeedWebViewControler.h
//  WildJunket
//
//  Created by David García Fernández on 04/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RSSEntry;

@interface RSSFeedWebViewControler : UIViewController{
    UIWebView *_webView;
    RSSEntry *_entry;
}
@property (retain) IBOutlet UIWebView *webView;
@property (retain) RSSEntry *entry;

@end
