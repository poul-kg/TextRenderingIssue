package com.apps.neonmapbox;

import android.app.Activity;
import android.app.Fragment;
import android.app.FragmentManager;
import android.app.FragmentTransaction;
import android.content.Context;
import android.widget.FrameLayout;
import android.widget.LinearLayout;

/**
 * Created by dhvlsimac on 14/08/17.
 */

public class NeonMapView extends FrameLayout {


    public interface NeonMapCallback
    {
        void onReady();
        void mapRegionChangedCallback(double latitude, double longitude, double zoomLevel);
        void markerClicked(AnnotationObject annotationObject);
    }

    public NeonMapCallback _callback;
    Context context;
    MapboxFragment mapboxFragment;
    public static String TAG_MAP_FRAGMENT = "Map";

    public NeonMapView() {
        super(com.fuse.Activity.getRootActivity());
        context = com.fuse.Activity.getRootActivity();
        addMapboxView();
    }
    
    void addMapboxView() {
        
        LinearLayout layout = new LinearLayout(context);
        LinearLayout ll = new LinearLayout(context);
        ll.setOrientation(LinearLayout.HORIZONTAL);
        ll.setId(12345);
        FragmentManager manager = ((Activity) context).getFragmentManager();
        FragmentTransaction fragTransaction = manager.beginTransaction();
        mapboxFragment = new MapboxFragment();
        fragTransaction.add(ll.getId(), mapboxFragment, TAG_MAP_FRAGMENT).commit();
        layout.addView(ll);
        this.addView(layout);

        mapboxFragment._callback = new NeonMapCallback() {
            @Override
            public void onReady() {
                _callback.onReady();
            }

            @Override
            public void mapRegionChangedCallback(double latitude, double longitude, double zoomLevel) {
                _callback.mapRegionChangedCallback(latitude, longitude, zoomLevel);
            }

            @Override
            public void markerClicked(AnnotationObject annotationObject) {
                _callback.markerClicked(annotationObject);
            }
        };
    }

    public double getMapCenterLatitude() {
        return mapboxFragment.getMapCenterLatitude();
    }

    public double getMapCenterLongitude() {
        return mapboxFragment.getMapCenterLongitude();
    }

    public double getMapZoomLevel() {
        return mapboxFragment.getMapZoomLevel();
    }

    public void showMyLocation() {
        mapboxFragment.showMyLocation();
    }

    public void moveTo(double lat, double lng, double zoomlevel) {
        mapboxFragment.moveTo(lat, lng, zoomlevel);
    }

    public void addMarkerOnMap(final AnnotationObject annotationObject) {
        mapboxFragment.addMarkerOnMap(annotationObject);
    }

    public void removeAllMarkers() {
        mapboxFragment.removeAllMarkers();
    }

    public void removeMap() {
        mapboxFragment.removeMap();
        FragmentManager manager = ((Activity) context).getFragmentManager();
        Fragment fragment = manager.findFragmentByTag(TAG_MAP_FRAGMENT);
        if(fragment != null)
            manager.beginTransaction().remove(fragment).commit();
    }
}