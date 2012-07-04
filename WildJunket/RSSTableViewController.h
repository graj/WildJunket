//
//  RSSTableViewController.h
//  WildJunket
//
//  Created by David García Fernández on 04/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RSSTableViewController : UITableViewController{
    NSMutableArray *_allEntries;
    
    //Run operations in background
    NSOperationQueue *_queue;
    NSArray *_feeds;
}

@property (retain) NSMutableArray *allEntries;
@property (retain) NSOperationQueue *queue;
@property (retain) NSArray *feeds;

@end
