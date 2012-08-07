//
//  PhotosAllViewController.m
//  WildJunket
//
//  Created by david on 07/08/12.
//
//

#import "PhotosAllViewController.h"
#import "BDRowInfo.h"
#import "PhotosAllViewController+Private.h"

@interface PhotosAllViewController ()


@end

@implementation PhotosAllViewController
@synthesize album=_album;
@synthesize items=_items;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithAlbum:(Album*)album
{
    if ((self = [super init])) {
        self.album=album;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    self.delegate = self;
    
    self.onLongPress = ^(UIView* view, NSInteger viewIndex){
        NSLog(@"Long press on %@, at %d", view, viewIndex);
    };
    
    self.onDoubleTap = ^(UIView* view, NSInteger viewIndex){
        NSLog(@"Double tap on %@, at %d", view, viewIndex);
    };
    [self _demoAsyncDataLoading];
    [self buildBarButtons];

}

- (void)animateReload
{
    self.items = [NSMutableArray new];
    [self _demoAsyncDataLoading];
}

- (NSUInteger)numberOfViews
{
    return [self.items count];
}

-(NSUInteger)maximumViewsPerCell
{
    return 5;
}

- (UIView *)viewAtIndex:(NSUInteger)index rowInfo:(BDRowInfo *)rowInfo
{
    UIImageView * imageView = [self.items objectAtIndex:index];
    return imageView;
}

- (CGFloat)rowHeightForRowInfo:(BDRowInfo *)rowInfo
{
    //    if (rowInfo.viewsPerCell == 1) {
    //        return 125  + (arc4random() % 55);
    //    }else {
    //        return 100;
    //    }
    return 55 + (arc4random() % 125);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.album=nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
