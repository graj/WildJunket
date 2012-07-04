//
//  RSSTableViewController.h
//  WildJunket
//
//  Created by David García Fernández on 04/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RSSFeedWebViewControler;
@interface RSSTableViewController : UITableViewController{
    NSMutableArray *_allEntries;
    
    //Run operations in background
    NSOperationQueue *_queue;
    NSArray *_feeds;
    RSSFeedWebViewControler *_webViewController;
}

@property (retain) NSMutableArray *allEntries;
@property (retain) NSOperationQueue *queue;
@property (retain) NSArray *feeds;
@property (retain) RSSFeedWebViewControler *webViewController;


@end
