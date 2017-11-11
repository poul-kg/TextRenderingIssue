//
//  FirstView.h
//  MapBoxTesting
//
//  Created by Dhvl's iMac on 11/08/17.
//  Copyright © 2017 Dhvl's iMac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Mapbox/Mapbox.h>
#import <MapKit/MapKit.h>
#import "AnnotationObject.h"


typedef void (^AnnotationClickedCallback)(AnnotationObject* annotation);
typedef void (^MapRegionChangedCallback)(double latitude, double longitude, double zoomLevel);

typedef void (^Action)(void);

@interface NeonMapView : UIView <MGLMapViewDelegate>

@property(copy) Action onAppearedCallback;
@property (strong) MGLMapView* mapView;
@property (nonatomic, copy) AnnotationClickedCallback annotationClicked;
@property (nonatomic, copy) MapRegionChangedCallback mapRegionChangedCallback;

- (id)initWithonAppeard:(Action)appearedHandler ;
- (void)moveTo:(double)lat longitude:(double)lng zoom:(double)zoom;
- (void)setMyLocation;
- (void)initMapWithLatitude: (double) lat longitude: (double) lng andZoom: (int) zoom;
- (double)getMapCenterLatitude;
- (double)getMapCenterLongitude;
- (double)getMapZoomLevel;
- (void)addCustomAnnotation:(AnnotationObject *)annotationObject;
- (void)removeAllMarkers;
- (void)removeMap;

@end
