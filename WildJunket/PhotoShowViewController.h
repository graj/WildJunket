//
//  PhotoShowViewController.h
//  WildJunket
//
//  Created by david on 07/08/12.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface PhotoShowViewController : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate,MFMailComposeViewControllerDelegate>{
    NSURL * _photoURL;
}

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) NSURL* photoURL;

- (id)initWithURL:(NSURL*)url;

@end
