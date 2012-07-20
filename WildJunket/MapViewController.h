//
//  MapViewController.h
//  WildJunket
//
//  Created by David García Fernández on 05/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKMapView+ZoomLevel.h"

@interface MapViewController : UIViewController <UIScrollViewDelegate>{
    MKMapView *_mapview;
    UILabel *_country;
    UILabel *_city;
    UILabel *_descripcion;
    
    
}

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property  IBOutlet MKMapView *mapView;
@property  IBOutlet UILabel *country;
@property  IBOutlet UILabel *city;
@property  IBOutlet UILabel *description;
@property  IBOutlet UIView *dataView;


@end
