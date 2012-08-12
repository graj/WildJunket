//
//  WhereViewController.m
//  WildJunket
//
//  Created by david on 12/08/12.
//
//
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define fsqAuth [NSURL URLWithString:@"https://api.foursquare.com/v2/users/self/checkins?oauth_token=KN4AYPARK5GJ4GRKE2F3GIQWPEKIDX3WJFAKW4TUOP2YU3CV&limit=10&v=20120608"]

#define ZOOM_LEVEL 10

#import "WhereViewController.h"
#import "SVProgressHUD.h"
#import "UIView+Screenshot.h"

@interface WhereViewController ()

@end

@implementation WhereViewController

- (void)initPaperFold
{
    _paperFoldView = [[PaperFoldView alloc] initWithFrame:CGRectMake(0,0,[self.view bounds].size.width,[self.view bounds].size.height)];
    [_paperFoldView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [self.view addSubview:_paperFoldView];
    
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0,0,240,[self.view bounds].size.height)];
    [_paperFoldView setRightFoldContentView:_mapView rightViewFoldCount:3 rightViewPullFactor:0.9];
    
    _centerTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,[self.view bounds].size.width,[self.view bounds].size.height)];
    [_centerTableView setRowHeight:120];
    [_paperFoldView setCenterContentView:_centerTableView];
    [_centerTableView setDelegate:self];
    [_centerTableView setDataSource:self];
    
    _leftTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,100,[self.view bounds].size.height)];
    [_leftTableView setRowHeight:100];
    [_leftTableView setDataSource:self];
    [_paperFoldView setLeftFoldContentView:_leftTableView];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(-1,0,1,[self.view bounds].size.height)];
    [_paperFoldView.contentView addSubview:line];
    [line setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1]];
    
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake([self.view bounds].size.width,0,1,[self.view bounds].size.height)];
    [_paperFoldView.contentView addSubview:line2];
    [line2 setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleHeight];
    [line2 setBackgroundColor:[UIColor colorWithWhite:0.8 alpha:1]];
    
    [_paperFoldView setDelegate:self];
    
    // you may want to disable dragging to preserve tableview swipe functionality
    
    // disable left fold
    //[_paperFoldView setEnableLeftFoldDragging:NO];
    
    // disable right fold
    //[_paperFoldView setEnableRightFoldDragging:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self initPaperFold];
  
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if (indexPath.row==0) [cell.textLabel setText:@"<-- unfold left view"];
    else if (indexPath.row==1)[cell.textLabel setText:@"unfold right view -->"];
    else if (indexPath.row==2)[cell.textLabel setText:@"--> restore <--"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0)
    {
        // unfold left view
        [self.paperFoldView setPaperFoldState:PaperFoldStateLeftUnfolded];
    }
    else if (indexPath.row==1)
    {
        // unfold right view
        [self.paperFoldView setPaperFoldState:PaperFoldStateRightUnfolded];
    }
    else if (indexPath.row==2)
    {
        // restore to center
        [self.paperFoldView setPaperFoldState:PaperFoldStateDefault];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark paper fold delegate

- (void)paperFoldView:(id)paperFoldView didFoldAutomatically:(BOOL)automated toState:(PaperFoldState)paperFoldState
{
    NSLog(@"did transition to state %i", paperFoldState);
}

@end
