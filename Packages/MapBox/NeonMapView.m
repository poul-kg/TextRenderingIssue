//
//  FirstView.m
//  MapBoxTesting
//
//  Created by Dhvl's iMac on 11/08/17.
//  Copyright © 2017 Dhvl's iMac. All rights reserved.
//

#import "NeonMapView.h"
#import "CustomAnnotationView.h"

@implementation NeonMapView {
    NSMutableArray * annotationObjectArray;
}

- (id)initWithonAppeard:(Action)appearedHandler {
    self = [super init];
    self.onAppearedCallback = appearedHandler;
    return self;
}

- (id)initWithFrame:(CGRect)aRect
{
    if ((self = [super initWithFrame:aRect])) {
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)coder
{
    if ((self = [super initWithCoder:coder])) {
       
    }
    return self;
}

- (void)mapViewDidFinishLoadingMap:(MGLMapView *)mapView {
    if(self.onAppearedCallback!=nil)
        self.onAppearedCallback();
}
    
- (void)mapView:(MGLMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    NSLog(@"Map Region changed");
    NSLog(@"%f", self.mapView.centerCoordinate.latitude);
    NSLog(@"%f", self.mapView.centerCoordinate.longitude);
    NSLog(@"%f", self.mapView.zoomLevel);
    if (self.mapRegionChangedCallback != NULL) {
        self.mapRegionChangedCallback(self.mapView.centerCoordinate.latitude, self.mapView.centerCoordinate.longitude, mapView.zoomLevel);
    }
}

- (double)getMapCenterLatitude {
        return self.mapView.centerCoordinate.latitude;
}
    
- (double)getMapCenterLongitude {
    return self.mapView.centerCoordinate.longitude;
}
    
- (double)getMapZoomLevel {
    return self.mapView.zoomLevel;
}
    
- (void)initMapWithLatitude: (double) lat longitude: (double) lng andZoom: (int) zoom{
    annotationObjectArray = [[NSMutableArray alloc] init];
    self.mapView = [[MGLMapView alloc] init];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.styleURL = [MGLStyle outdoorsStyleURL];
    self.mapView.tintColor = [UIColor lightGrayColor];
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(lat, lng)];
    self.mapView.zoomLevel = zoom;
    self.mapView.delegate = self;
    [self addSubview:self.mapView];
}

-(void)moveTo:(double)lat longitude:(double)lng zoom:(double)zoom {
    if (lat != 0 && lng != 0) {
        CLLocationCoordinate2D newCenter = CLLocationCoordinate2DMake(lat, lng);
        [self.mapView setCenterCoordinate:newCenter];
    }
    if (zoom != 0) {
        zoom = MAX(2.0, MIN(zoom, 21));
        [self.mapView setZoomLevel:zoom];
    }
}

- (void)setMyLocation {
    self.mapView.showsUserLocation = YES;
}

- (void)addCustomAnnotation:(AnnotationObject *)annotationObject {
    [annotationObjectArray addObject:annotationObject];
    MGLPointAnnotation* point = [[MGLPointAnnotation alloc] init];
    point.coordinate = CLLocationCoordinate2DMake(annotationObject.latitude, annotationObject.longitude);
    point.title = annotationObject.name;
    [self.mapView addAnnotation:point];
}

- (void)removeMap {
    if (self.mapView != NULL) {
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self.mapView removeFromSuperview];
        self.mapView = NULL;
    }
    [annotationObjectArray removeAllObjects];
}
    
- (void)removeAllMarkers {
    NSArray * annotations = [NSArray arrayWithArray:self.mapView.annotations];
    if (annotations.count != 0) {
        for (int i = 0; i < [annotations count]; i++) {
            [self.mapView removeAnnotation:[annotations objectAtIndex:i]];
        }
    }
}

- (BOOL)mapView:(MGLMapView *)mapView annotationCanShowCallout:(id<MGLAnnotation>)annotation {
    return false;
}

- (MGLAnnotationView *)mapView:(MGLMapView *)mapView viewForAnnotation:(id<MGLAnnotation>)annotation {
    
    NSString * identifier = [annotation title];
    
    CustomAnnotationView * customAnnotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if (customAnnotationView == NULL) {
        customAnnotationView = [[CustomAnnotationView alloc] initWithReuseIdentifier:identifier];
        AnnotationObject* annotationObject;
        for(int i=0;i<[annotationObjectArray count];i++){
            AnnotationObject* tempAnnotationObject = [annotationObjectArray objectAtIndex:i];
            if (tempAnnotationObject.latitude == [annotation coordinate].latitude && tempAnnotationObject.longitude == [annotation coordinate].longitude) {
                annotationObject = tempAnnotationObject;
                break;
            }
        }
         
        if (annotationObject != NULL) {
            [customAnnotationView setParametersWithName:annotationObject.name 
                fontColor:annotationObject.fontColor andColor:annotationObject.bgColor];
        }
    }
    return customAnnotationView;
}

- (void)mapView:(MGLMapView *)mapView didSelectAnnotationView:(MGLAnnotationView *)annotationView {
    if ([annotationView isKindOfClass: [CustomAnnotationView class]]) {
        NSString* identifier = annotationView.reuseIdentifier;
        AnnotationObject* annotationObject;
        for(int i=0;i<[annotationObjectArray count];i++){
            AnnotationObject* tempAnnotationObject = [annotationObjectArray objectAtIndex:i];
            if (tempAnnotationObject.name == identifier) {
                annotationObject = tempAnnotationObject;
                break;
            }
        }
        
        if (annotationObject != NULL) {
            NSLog(@"%@", [NSString stringWithFormat:@"%@", annotationObject.name]);
            self.annotationClicked(annotationObject);
        }
        
        NSArray * selectedAnnotations = [NSArray arrayWithArray:self.mapView.selectedAnnotations];
        if (selectedAnnotations.count != 0) {
            for (int i = 0; i < [selectedAnnotations count]; i++) {
                [self.mapView deselectAnnotation:[selectedAnnotations objectAtIndex:i] animated:YES];
            }
        }
    }
}

- (void)method:(void (^)(NSString *))handler {
    
}

@end
