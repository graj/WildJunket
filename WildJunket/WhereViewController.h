//
//  WhereViewController.h
//  WildJunket
//
//  Created by david on 12/08/12.
//
//

#import <UIKit/UIKit.h>
#import "PaperFoldView.h"
#import <CoreLocation/CoreLocation.h>
#import "MKMapView+ZoomLevel.h"

@interface WhereViewController : UIViewController <MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate, PaperFoldViewDelegate, UIScrollViewDelegate, CLLocationManagerDelegate>{
    
    NSMutableArray *_fsqEntries;
    
}

@property (nonatomic, strong) PaperFoldView *paperFoldView;
@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) NSMutableArray *fsqEntries;
@property (strong, nonatomic) UITableView *leftTableView, *centerTableView;
@property (strong, nonatomic) IBOutlet CLLocationManager *locationManager;


@end
