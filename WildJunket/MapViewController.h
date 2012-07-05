//
//  MapViewController.h
//  WildJunket
//
//  Created by David García Fernández on 05/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController{
    MKMapView *_mapview;
}
@property (retain) IBOutlet MKMapView *mapView;

@end
