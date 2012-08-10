//
//  RSSMoreFeedsViewController.h
//  WildJunket
//
//  Created by david on 10/08/12.
//
//

#import <UIKit/UIKit.h>

@interface RSSMoreFeedsViewController : UIViewController{
    NSURL* _url;
}
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) NSURL *url;

@end
