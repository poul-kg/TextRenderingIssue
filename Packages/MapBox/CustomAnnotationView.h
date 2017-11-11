//
//  CustomAnnotationView.h
//  MapTextingObjectiveC
//
//  Created by Dhvl's iMac on 23/08/17.
//  Copyright © 2017 Dhvl's iMac. All rights reserved.
//

#import <Mapbox/Mapbox.h>

@interface CustomAnnotationView : MGLAnnotationView

- (void)setParametersWithName:(NSString *)name fontColor:(NSString *)fontColor andColor:(NSString *)colorCode;

@end
