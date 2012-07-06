//
//  MapViewController.h
//  WildJunket
//
//  Created by David García Fernández on 05/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKMapView+ZoomLevel.h"

@interface MapViewController : UIViewController{
    MKMapView *_mapview;
    UILabel *_country;
    UILabel *_city;
}
@property (retain) IBOutlet MKMapView *mapView;
@property (retain) IBOutlet UILabel *country;
@property (retain) IBOutlet UILabel *city;


@end
