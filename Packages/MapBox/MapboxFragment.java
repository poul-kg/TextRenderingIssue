package com.apps.neonmapbox;

import android.Manifest;
import android.app.Activity;
import android.app.Fragment;
import android.content.Context;
import android.content.Intent;
import android.content.IntentSender;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapShader;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Rect;
import android.graphics.Shader;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.ActivityCompat;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;


import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.common.api.PendingResult;
import com.google.android.gms.common.api.ResolvableApiException;
import com.google.android.gms.common.api.ResultCallback;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.location.FusedLocationProviderApi;
import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.location.LocationSettingsRequest;
import com.google.android.gms.location.LocationSettingsResult;
import com.google.android.gms.location.LocationSettingsStatusCodes;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.GoogleMapOptions;
import com.google.android.gms.maps.MapView;
import com.google.android.gms.maps.MapsInitializer;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;
import com.google.android.gms.maps.model.Polyline;
import com.google.android.gms.maps.model.PolylineOptions;
import com.google.android.gms.tasks.OnSuccessListener;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Executor;

/**
 * Created by dhvlsimac on 22/09/17.
 */

public class MapboxFragment extends Fragment {

    public NeonMapView.NeonMapCallback _callback;
    private MapView _mapView;
    private GoogleMap _googleMap;
    ArrayList<AnnotationObject> annotationArray = new ArrayList<AnnotationObject>();
    ArrayList<Marker> markersArray = new ArrayList<Marker>();
    String fileName = "";
    Context context;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        context = com.fuse.Activity.getRootActivity();

        LinearLayout layout = new LinearLayout(getActivity());

        MapsInitializer.initialize(context);
        GoogleMapOptions options = new GoogleMapOptions();
        options.camera(new CameraPosition(new LatLng(39.7637, -104.9401), 16, 0, 0));
        _mapView = new MapView(context, options);
        layout.addView(_mapView);
        _mapView.onCreate(new Bundle());
        _mapView.getMapAsync(new OnMapReadyCallback() {
            @Override
            public void onMapReady(GoogleMap googleMap) {
                Log.e("Map is ready", "");

                configure(googleMap);
            }
        });
        return layout;
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
    }

    @Override
    public void onStart() {
        super.onStart();
        if (_mapView != null)
        _mapView.onStart();
    }

    @Override
    public void onPause() {
        super.onPause();
        if (_mapView != null)
        _mapView.onPause();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (_mapView != null)
        _mapView.onDestroy();
    }

    @Override
    public void onResume() {
        super.onResume();
        if (_mapView != null)
        _mapView.onResume();
    }

    @Override
    public void onStop() {
        super.onStop();
        if (_mapView != null)
        _mapView.onStop();
    }

    @Override
    public void onLowMemory() {
        super.onLowMemory();
        if (_mapView != null)
        _mapView.onLowMemory();
    }

    @Override
    public void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        _mapView.onSaveInstanceState(outState);
    }

    private void configure(GoogleMap map)
    {
        _googleMap = map;

        if(_callback!=null)
            _callback.onReady();

        _googleMap.setOnMarkerClickListener(new GoogleMap.OnMarkerClickListener() {
            @Override
            public boolean onMarkerClick(Marker marker) {
                int tag = (int)marker.getTag();
                Log.e("Marker Tap", " " + tag);
                AnnotationObject annotationObject;

                for (AnnotationObject object : annotationArray) {
                    if (object.getIdentifier() == tag) {
                        annotationObject = object;
                        _callback.markerClicked(annotationObject);
                        return true;
                    }
                }
                return true;
            }
        });

        _googleMap.setOnCameraMoveListener(new GoogleMap.OnCameraMoveListener() {
            @Override
            public void onCameraMove() {
                if (_callback == null) return;
                CameraPosition position = _googleMap.getCameraPosition();
                _callback.mapRegionChangedCallback(position.target.latitude, position.target.longitude, position.zoom);
            }
        });
    }

    public double getMapCenterLatitude() {
        return _googleMap.getCameraPosition().target.latitude;
    }

    public double getMapCenterLongitude() {
        return _googleMap.getCameraPosition().target.longitude;
    }

    public double getMapZoomLevel() {
        return _googleMap.getCameraPosition().zoom;
    }

    public void showMyLocation() {
        _googleMap.setMyLocationEnabled(true);
    }

    public void moveTo(double lat, double lng, double zoomlevel) {
        CameraPosition position = new CameraPosition.Builder()
                .target(new LatLng(lat,  lng))
                .zoom((float)zoomlevel)
                .build(); // Builds the CameraPosition object from the builder
        _googleMap.animateCamera(CameraUpdateFactory.newCameraPosition(position));
    }

    public void addMarkerOnMap(final AnnotationObject annotationObject) {
        annotationArray.add(annotationObject);

        GradientDrawable shape =  new GradientDrawable();
        shape.setShape(GradientDrawable.RECTANGLE);
//        float[] radis = {15.0f, 15.0f, 15.0f, 15.0f, 15.0f, 15.0f, 0.0f, 0.0f};
//         shape.setCornerRadii(radis);
        if (annotationObject.bgColor != null) {
            shape.setColor(Color.parseColor(annotationObject.bgColor));
        }
        else {
            shape.setColor(Color.parseColor("#FF6266"));
        }

        final RelativeLayout relative = new RelativeLayout(com.fuse.Activity.getRootActivity());
        relative.setLayoutParams(new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT));

        LinearLayout relativeSecond = new LinearLayout(com.fuse.Activity.getRootActivity());
        relativeSecond.setOrientation(LinearLayout.HORIZONTAL);
        relativeSecond.setBackground(shape);
        relativeSecond.setLayoutParams(new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT));

        int marginForTextView = 35;
        TextView text = new TextView(com.fuse.Activity.getRootActivity());
        text.setPadding(marginForTextView,marginForTextView,marginForTextView,marginForTextView);
        FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.WRAP_CONTENT,
                FrameLayout.LayoutParams.WRAP_CONTENT
        );
        params.setMargins(20, 20, 20, 20);
        text.setLayoutParams(params);
        String iconHeart = annotationObject.getName();
        long valLong = Long.parseLong(iconHeart,16);

        Typeface typeface = FontManager.getTypeface(context, getFileName());
        text.setTypeface(typeface);
        text.setText(String.valueOf((char)valLong));
        text.setTextSize(20);
        if (annotationObject.fontColor != null) {
            text.setTextColor(Color.parseColor(annotationObject.fontColor));
        }
        else {
            text.setTextColor(Color.WHITE);
        }
        relativeSecond.addView(text);
        relative.addView(relativeSecond);

        Bitmap bitmap = createDrawableFromView(context, relative);

        Marker newMarker = _googleMap.addMarker(new MarkerOptions()
                .position(new LatLng(annotationObject.getLatitude(),annotationObject.getLongitude()))
                .icon(BitmapDescriptorFactory.fromBitmap(getRoundedShape(bitmap)))
                .anchor(0.5f, 1));
        newMarker.setTag(annotationObject.getIdentifier());
    }

    String getFileName() {
        if (fileName.equals("")) {
            String [] list;
            try {
                list = context.getAssets().list("");
                if (list.length > 0) {
                    // This is a folder
                    for (String file : list) {
                        if (file.contains("neon-icon-font")) {
                            fileName = file;
                            return fileName;
                        }
                    }
                }
                return "";
            } catch (IOException e) {
                return "";
            }
        }
        return fileName;
    }

    public void removeAllMarkers() {
        _googleMap.clear();
        // for(Marker marker : markersArray) {
        //     marker.remove();
        // }
    }

    public void removeMap() {
        if (_googleMap != null) {
            _googleMap.clear();
            _googleMap = null;
        }
        ((LinearLayout)_mapView.getParent()).removeView(_mapView);
          _mapView = null;
        _callback = null;
        annotationArray.clear();
    }

    public Bitmap createDrawableFromView(Context context, View view) {
        DisplayMetrics displayMetrics = new DisplayMetrics();
        ((Activity) context).getWindowManager().getDefaultDisplay().getMetrics(displayMetrics);
        view.setLayoutParams(new FrameLayout.LayoutParams(FrameLayout.LayoutParams.WRAP_CONTENT, FrameLayout.LayoutParams.WRAP_CONTENT));
        view.measure(displayMetrics.widthPixels, displayMetrics.heightPixels);
        view.layout(0, 0, displayMetrics.widthPixels, displayMetrics.heightPixels);
        view.buildDrawingCache();
        Bitmap bitmap = Bitmap.createBitmap(view.getMeasuredWidth(), view.getMeasuredHeight(), Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(bitmap);
        view.draw(canvas);
        return bitmap;
    }

    public Bitmap getRoundedShape(Bitmap scaleBitmapImage) {
        int targetWidth = scaleBitmapImage.getWidth();
        int targetHeight = scaleBitmapImage.getHeight();
        Bitmap targetBitmap = Bitmap.createBitmap(targetWidth,
                targetHeight,Bitmap.Config.ARGB_8888);

        Paint paint = new Paint();
        paint.setStrokeWidth(10);
        paint.setColor(Color.WHITE);
        paint.setShadowLayer(5, 1, 2, Color.parseColor("#d3d3d3"));
        Canvas canvas = new Canvas(targetBitmap);

        canvas.drawCircle(targetWidth/2, targetHeight/2, targetWidth/2 , paint);
        BitmapShader shader = new BitmapShader(targetBitmap, Shader.TileMode.CLAMP, Shader.TileMode.CLAMP);
        paint.setAntiAlias(true);
        paint.setShader(shader);

        Path path = new Path();
        path.addCircle(((float) targetWidth) / 2,
                ((float) targetHeight) / 2,
                targetWidth/ 2 - 10,
                Path.Direction.CCW);

        canvas.clipPath(path);
        Bitmap sourceBitmap = scaleBitmapImage;
        canvas.drawBitmap(sourceBitmap,
                new Rect(0, 0, sourceBitmap.getWidth(),
                        sourceBitmap.getHeight()),
                new Rect(0, 0, targetWidth, targetHeight), paint);
        return targetBitmap;
    }
}
