//
//  RSSTableViewController.m
//  WildJunket
//
//  Created by David García Fernández on 04/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RSSTableViewController.h"
#import "RSSEntry.h"
#import "ASIHTTPRequest.h"
#import "GDataXMLNode.h"
#import "GDataXMLElement-Extras.h"
#import "NSDate+InternetDateTime.h"
#import "NSArray+Extras.h"
#import "RSSFeedWebViewControler.h"
#import "RSSMoreFeedsViewController.h"
#import "TFHpple.h"
#import "RSSCell.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/CAGradientLayer.h>
#import <QuartzCore/QuartzCore.h>
#import "SVProgressHUD.h"
#import "ODRefreshControl.h"

@interface RSSTableViewController ()

@end

@implementation RSSTableViewController
@synthesize allEntries = _allEntries;
@synthesize feeds = _feeds;
@synthesize queue = _queue;
@synthesize webViewController = _webViewController;
@synthesize moreFeedsViewController=_moreFeedsViewController;

- (void)refresh {
    
    for (NSString *feed in _feeds) {
        NSURL *url = [NSURL URLWithString:feed];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        [request setDelegate:self];
        [_queue addOperation:request];
    }
    
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    
    [_queue addOperationWithBlock:^{
        
        NSError *error;
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:[request responseData] 
                                                               options:0 error:&error];
        if (doc == nil) { 
            NSLog(@"Failed to parse %@", request.url);
        } else {
            
            NSMutableArray *entries = [NSMutableArray array];
            [self parseFeed:doc.rootElement entries:entries];                
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                [_allEntries removeAllObjects];
                [self.tableView reloadData];
                
                for (RSSEntry *entry in entries) {
                    
                    int insertIdx = [_allEntries indexForInsertingObject:entry sortedUsingBlock:^(id a, id b) {
                        RSSEntry *entry1 = (RSSEntry *) a;
                        RSSEntry *entry2 = (RSSEntry *) b;
                        return [entry1.articleDate compare:entry2.articleDate];
                    }];                   
                    [_allEntries insertObject:entry atIndex:insertIdx];
                    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:insertIdx inSection:0]]
                                          withRowAnimation:UITableViewRowAnimationRight];
                    
                }                            
                
            }];
            
        }        
    }];
    [SVProgressHUD dismiss];
    
}

- (void)parseFeed:(GDataXMLElement *)rootElement entries:(NSMutableArray *)entries {    
    if ([rootElement.name compare:@"rss"] == NSOrderedSame) {
        [self parseRss:rootElement entries:entries];
    } else if ([rootElement.name compare:@"feed"] == NSOrderedSame) {                       
        [self parseAtom:rootElement entries:entries];
    } else {
        NSLog(@"Unsupported root element: %@", rootElement.name);
    }    
}

- (void)parseRss:(GDataXMLElement *)rootElement entries:(NSMutableArray *)entries {
    
    NSArray *channels = [rootElement elementsForName:@"channel"];
    for (GDataXMLElement *channel in channels) {            
        
        NSString *blogTitle = [channel valueForChild:@"title"];
        
        
        NSArray *items = [channel elementsForName:@"item"];
        for (GDataXMLElement *item in items) {
            
            NSString *articleTitle = [item valueForChild:@"title"];
            NSString *articleUrl = [item valueForChild:@"link"];            
            NSString *articleDateString = [item valueForChild:@"pubDate"];
            
            //Obtengo el contenido
            NSData*content=[[item valueForChild:@"content:encoded"] dataUsingEncoding:NSUTF8StringEncoding];
            //NSString*content=[item valueForChild:@"content:encoded"];
            
            //Parseo el html para obtener la url de la imagen
            TFHpple *htmlParser = [TFHpple hppleWithHTMLData:content];
            
            //Devuelve todos los elementos que contengan jpg o png y sean href o src
            NSString *xpathQuery = @"//*[contains(@href, 'jpg') or contains(@href, 'png') or contains(@src, 'jpg') or contains(@src, 'png')]";
            NSArray *nodes = [htmlParser searchWithXPathQuery:xpathQuery];
            
            //Obtengo la primera imagen                             
            //NSString * urlonclick=[[nodes objectAtIndex:0] objectForKey:@"src"];
               
            //NSArray *components = [urlonclick componentsSeparatedByString:@"media="];
            //NSString *afterOpenBracket = [components objectAtIndex:1];
            //components = [afterOpenBracket componentsSeparatedByString:@"&"];
            
            
            //URL de la primera foto limpia, parseada y lista para mostrar en pantalla
            NSString *photoURL = [[nodes objectAtIndex:0] objectForKey:@"src"];
            
            if(photoURL==nil){
                //Elegir otra opcion
                photoURL = [[nodes objectAtIndex:0] objectForKey:@"href"];
                
            }
            
                      
            
            NSDate *articleDate = [NSDate dateFromInternetDateTimeString:articleDateString formatHint:DateFormatHintRFC822];

            
            //URL buena para Readability
            NSArray *componentsURL = [[item valueForChild:@"content:encoded"] componentsSeparatedByString:@"The post <a href=\""];
            NSString *afterOpenBracketURL = [componentsURL objectAtIndex:1];
            componentsURL = [afterOpenBracketURL componentsSeparatedByString:@"\">"];
            
            articleUrl=[componentsURL objectAtIndex:0];
            
            RSSEntry *entry = [[[RSSEntry alloc] initWithBlogTitle:blogTitle 
                                                      articleTitle:articleTitle 
                                                        articleUrl:articleUrl 
                                                       articleDate:articleDate photoURL:photoURL] autorelease];
            [entries addObject:entry];
            
        }      
    }
    
}

- (void)parseAtom:(GDataXMLElement *)rootElement entries:(NSMutableArray *)entries {
    
    NSString *blogTitle = [rootElement valueForChild:@"title"];
        
    NSArray *items = [rootElement elementsForName:@"entry"];
    for (GDataXMLElement *item in items) {
        
        NSString *articleTitle = [item valueForChild:@"title"];
        NSString *articleUrl = nil;
        NSArray *links = [item elementsForName:@"link"];        
        for(GDataXMLElement *link in links) {
            NSString *rel = [[link attributeForName:@"rel"] stringValue];
            NSString *type = [[link attributeForName:@"type"] stringValue]; 
            if ([rel compare:@"alternate"] == NSOrderedSame && 
                [type compare:@"text/html"] == NSOrderedSame) {
                articleUrl = [[link attributeForName:@"href"] stringValue];
            }
        }
        
        NSString *articleDateString = [item valueForChild:@"updated"];        
        NSDate *articleDate = [NSDate dateFromInternetDateTimeString:articleDateString formatHint:DateFormatHintRFC3339];
        
        //Obtengo el contenido
        NSData*content=[[item valueForChild:@"content:encoded"] dataUsingEncoding:NSUTF8StringEncoding];
        //NSString*content=[item valueForChild:@"content:encoded"];
        
        //Parseo el html para obtener la url de la imagen
        TFHpple *htmlParser = [TFHpple hppleWithHTMLData:content];
        NSString *xpathQuery = @"//div[@class='xc_pinterest']/a";
        NSArray *nodes = [htmlParser searchWithXPathQuery:xpathQuery];
        
        //Obtengo la primera imagen                             
        NSString * urlonclick=[[nodes objectAtIndex:0] objectForKey:@"onclick"];
        
        NSArray *components = [urlonclick componentsSeparatedByString:@"media="];
        NSString *afterOpenBracket = [components objectAtIndex:1];
        components = [afterOpenBracket componentsSeparatedByString:@"&"];
        
        
        //URL de la primera foto limpia, parseada y lista para mostrar en pantalla
        NSString *photoURL = [components objectAtIndex:0];
        
        //URL buena para Readability
        NSArray *componentsURL = [[item valueForChild:@"content:encoded"] componentsSeparatedByString:@"The post <a href=\""];
        NSString *afterOpenBracketURL = [componentsURL objectAtIndex:1];
        componentsURL = [afterOpenBracketURL componentsSeparatedByString:@"\">"];
        
        articleUrl=[componentsURL objectAtIndex:0];
        
        
        RSSEntry *entry = [[[RSSEntry alloc] initWithBlogTitle:blogTitle 
                                                  articleTitle:articleTitle 
                                                    articleUrl:articleUrl 
                                                   articleDate:articleDate photoURL:photoURL] autorelease];
        
        [entries addObject:entry];
        
    }      
    
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    [SVProgressHUD dismiss];
    UIAlertView *alertView = [[UIAlertView alloc] 
                              initWithTitle:@"Sorry"                                                             
                              message:@"It was unable to load the data, please make sure you have internet connection."                                                          
                              delegate:self                                              
                              cancelButtonTitle:@"OK"                                                   
                              otherButtonTitles:nil];
    [alertView show];
    NSLog(@"Error: %@", error);
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)checkOrientation {
    //Title status bar
    
    CALayer *sublayer = [CALayer layer];
    sublayer.name=@"title";
    
    if(self.interfaceOrientation==UIInterfaceOrientationPortrait || self.interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown){
        sublayer.contents = (id) [UIImage imageNamed:@"wj_title.png"].CGImage;
        sublayer.frame = CGRectMake(0, 0, 320, 44);
    }else {
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad && IS_IPHONE_5){
            sublayer.contents = (id) [UIImage imageNamed:@"wj_title_landscape-568h.png"].CGImage;
            sublayer.frame = CGRectMake(0, 0, 568, 32);
        }
        else{
            sublayer.contents = (id) [UIImage imageNamed:@"wj_title_landscape.png"].CGImage;
            sublayer.frame = CGRectMake(0, 0, 480, 32);
        }
    }
    
    for (CALayer *layer in self.navigationController.navigationBar.layer.sublayers) {
        if ([layer.name isEqualToString:@"title"]) {
            [layer removeFromSuperlayer];
            break;
        }
    }
    
    [self.navigationController.navigationBar.layer addSublayer:sublayer];
}

- (void)viewDidLoad {
    
    //Shows status bar
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    
    [super viewDidLoad];    
   
    [self checkOrientation];
    
    self.allEntries = [NSMutableArray array];
    self.queue = [[[NSOperationQueue alloc] init] autorelease];
    
    ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];

    
    [SVProgressHUD showWithStatus:@"Loading..."];
    self.feeds = [NSArray arrayWithObjects:@"http://feeds.feedburner.com/wildjunket",nil];    
    [self refresh];
}

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    [self refresh];
    [refreshControl endRefreshing];
    
}

-(void)willRotateToInterfaceOrientation: (UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
    
    CALayer *sublayer = [CALayer layer];
    sublayer.name=@"title";
    if ((orientation == UIInterfaceOrientationLandscapeLeft) || (orientation == UIInterfaceOrientationLandscapeRight)) {
        
        //Cambia layer de título
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad && IS_IPHONE_5){
            sublayer.contents = (id) [UIImage imageNamed:@"wj_title_landscape-568h.png"].CGImage;
            sublayer.frame = CGRectMake(0, 0, 568, 32);
        }
        else{
            sublayer.contents = (id) [UIImage imageNamed:@"wj_title_landscape.png"].CGImage;
            sublayer.frame = CGRectMake(0, 0, 480, 32);
        }
    }
    else{
        sublayer.contents = (id) [UIImage imageNamed:@"wj_title.png"].CGImage;
        sublayer.frame = CGRectMake(0, 0, 320, 44);
    }
    
    for (CALayer *layer in self.navigationController.navigationBar.layer.sublayers) {
        if ([layer.name isEqualToString:@"title"]) {
            [layer removeFromSuperlayer];
            break;
        }
    }
    [self.navigationController.navigationBar.layer addSublayer:sublayer];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    
    //Shows status bar
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];

    [self checkOrientation];
    
	[super viewWillAppear:animated];
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait ||
            interfaceOrientation == UIInterfaceOrientationLandscapeLeft || 
            interfaceOrientation == UIInterfaceOrientationLandscapeRight ||
            interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown );
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Just one section, feeds will go together
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_allEntries count]+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"rssCell";
    static NSString *CellIdentifierMoreFeeds = @"moreFeeds";
   
    
    
    if(indexPath.row==[_allEntries count]){
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifierMoreFeeds];
      
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = cell.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:169.0/255.0 green:180.0/255.0 blue:171.0/255.0 alpha:1.0]CGColor], (id)[[UIColor whiteColor]CGColor], nil];
        
        [cell.layer insertSublayer:gradient atIndex:0];
        
        return cell;
    }
    else{
        
        RSSCell *cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    RSSEntry *entry = [_allEntries objectAtIndex:indexPath.row];
    
    NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSString *articleDateString = [dateFormatter stringFromDate:entry.articleDate];
    
    cell.lblTitulo.text=entry.articleTitle;
    cell.lblDatos.text=[NSString stringWithFormat:@"%@", articleDateString];
    cell.lblTitulo.autoresizingMask   = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = cell.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:209.0/255.0 green:210.0/255.0 blue:211.0/255.0 alpha:1.0]CGColor], (id)[[UIColor whiteColor]CGColor], nil];
    
    
    [cell.layer insertSublayer:gradient atIndex:0];
    
    
    //Imagen CACHE
    [cell.imageView setImageWithURL:[NSURL URLWithString:entry.photoURL] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        return cell;


    }
}

/*- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

    //Pone el color alternando filas
    if(indexPath.row%2==0){
        cell.backgroundColor = [UIColor colorWithRed:183.0/255.0 green:172.0/255.0 blue:50.0/255.0 alpha:1.0];
    }
    
    else {
        cell.backgroundColor = [UIColor colorWithRed:209.0/255.0 green:210.0/255.0 blue:211.0/255.0 alpha:1.0];
    }
}*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //Solo tengo que hacer eso si llamo al segue manualmente, sin haberlo puesto en storyboard
    //[self performSegueWithIdentifier:@"rssdetail" sender:indexPath];

    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    if([[segue identifier] isEqualToString:@"rssdetail"]){
        NSIndexPath *indexPath=[self.tableView indexPathForSelectedRow];
        RSSEntry *entry = [_allEntries objectAtIndex:indexPath.row];
        self.webViewController=[segue destinationViewController];
        self.webViewController.entry=entry;
    }
    if([[segue identifier] isEqualToString:@"moreFeedsSeg"]){
        self.moreFeedsViewController=[segue destinationViewController];
        self.moreFeedsViewController.url=[NSURL URLWithString:@"http://www.wildjunket.com/page/2/"];
    }
}

-(void)didReceiveMemoryWarning{
    self.webViewController = nil;
    self.moreFeedsViewController=nil;
    [super didReceiveMemoryWarning];
}

-(void)dealloc{
    [_allEntries release];
    _allEntries = nil;
    [_queue release];
    _queue = nil;
    [_feeds release];
    _feeds = nil;
    [_webViewController release];
    _webViewController = nil;
    [_moreFeedsViewController release];
    _webViewController=nil;
    [super dealloc];
}

@end
