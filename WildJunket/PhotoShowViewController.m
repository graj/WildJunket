//
//  PhotoShowViewController.m
//  WildJunket
//
//  Created by david on 07/08/12.
//
//

#import "PhotoShowViewController.h"
#import "SVProgressHUD.h"
#import <Twitter/Twitter.h>
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface PhotoShowViewController ()
@property (nonatomic, strong) UIImageView *imageView;

- (void)centerScrollViewContents;
//- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer;
- (void)scrollViewSingleTapped:(UITapGestureRecognizer*)recognizer;
- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer;

@end

@implementation PhotoShowViewController
@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;
@synthesize photoURL=_photoURL;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithURL:(NSURL*)url
{
    if ((self = [super init])) {
        self.photoURL=url;
        
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden: YES animated:YES];
    [self setBoton];
}

-(void) setBoton{
    
    UIBarButtonItem * reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share)];
        
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: reloadButton, nil];
}

-(void) share{
    //Pulsado botón compartir, mostrar menu
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"Share with the world" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Twitter", @"Email", @"Copy link", nil];
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [popupQuery showInView:self.view];
    
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
                NSString *text=@"Amazing photo from WildJunket.com";
                [tweetSheet setInitialText:text];
                [tweetSheet addURL:self.photoURL];
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
                
                [mailer setSubject:@"WildJunket cool photo"];
                
                NSString *emailBody = [@"Woow check out this phto from WildJunket.com:\n" stringByAppendingString:[self.photoURL absoluteString]];
                
                [mailer setMessageBody:emailBody isHTML:YES];
                
                [self presentModalViewController:mailer animated:YES];
                
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
        case 2:
        {
            //Copy link
            UIPasteboard *pb = [UIPasteboard generalPasteboard];
            [pb setString:[self.photoURL absoluteString]];
        }
            break;
        case 3:
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

-(void)viewDidAppear:(BOOL)animated{
    //Aquí va a cargar la foto
    
    [SVProgressHUD show];
    
    dispatch_async(kBgQueue, ^{
        // 1
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.photoURL]];
        [self performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:YES];

                
    });

    
}

-(void)setImage:(UIImage*)image{
    
    self.imageView = [[UIImageView alloc] initWithImage:image];
    self.imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=image.size};
    [self.scrollView addSubview:self.imageView];
    
    // 2
    self.scrollView.contentSize = image.size;
    
    
    UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
    twoFingerTapRecognizer.numberOfTapsRequired = 1;
    twoFingerTapRecognizer.numberOfTouchesRequired = 2;
    [self.scrollView addGestureRecognizer:twoFingerTapRecognizer];
    
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewSingleTapped:)];
    singleTapRecognizer.numberOfTapsRequired = 1;
    singleTapRecognizer.numberOfTouchesRequired = 1;
    [self.scrollView addGestureRecognizer:singleTapRecognizer];
    
    
    // 4
    CGRect scrollViewFrame = self.scrollView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    self.scrollView.minimumZoomScale = minScale;
    
    // 5
    self.scrollView.maximumZoomScale = 1.0f;
    self.scrollView.zoomScale = minScale;
    
    // 6
    [self centerScrollViewContents];
    
    [SVProgressHUD dismiss];

}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden: YES animated:YES];
    
    
}

- (void)centerScrollViewContents {
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.imageView.frame = contentsFrame;
}

/*- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer {
    // 1
    CGPoint pointInView = [recognizer locationInView:self.imageView];
    
    // 2
    CGFloat newZoomScale = self.scrollView.zoomScale * 1.5f;
    newZoomScale = MIN(newZoomScale, self.scrollView.maximumZoomScale);
    
    // 3
    CGSize scrollViewSize = self.scrollView.bounds.size;
    
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 2.0f);
    CGFloat y = pointInView.y - (h / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    
    // 4
    [self.scrollView zoomToRect:rectToZoomTo animated:YES];
}*/

- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer {
    // Zoom out slightly, capping at the minimum zoom scale specified by the scroll view
    CGFloat newZoomScale = self.scrollView.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, self.scrollView.minimumZoomScale);
    [self.scrollView setZoomScale:newZoomScale animated:YES];
}

- (void)scrollViewSingleTapped:(UITapGestureRecognizer*)recognizer {
    
    //Hides and show navigation bar
    if(self.navigationController.navigationBarHidden)
        [self.navigationController setNavigationBarHidden: NO animated:YES];
    else
        [self.navigationController setNavigationBarHidden: YES animated:YES];
  

}


- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    // Return the view that you want to zoom
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so you need to re-center the contents
    [self centerScrollViewContents];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    self.imageView.center = self.scrollView.center;
    
  }

- (void)viewDidUnload
{
    self.photoURL=nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
