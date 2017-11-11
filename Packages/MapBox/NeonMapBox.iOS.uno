using Uno;
using Uno.UX;
using Uno.Time;
using Uno.Compiler.ExportTargetInterop;
using Fuse;
using Uno.Collections;
using Fuse.Controls;
using Fuse.Controls.Native;
using Fuse.Controls.Native.iOS;
// event support
using Fuse.Scripting;
using Fuse.Reactive;
using Fuse.Gestures;

namespace Neon.Mapbox.iOS
{	
	[Require("Source.Include", "UIKit/UIKit.h")]
	[Require("Cocoapods.Platform.Name", "ios")]
	[Require("Cocoapods.Platform.Version", "9.0")]
	[Require("Cocoapods.Podfile.Pre", "use_frameworks!")]
	[Require("Cocoapods.Podfile.Target", "pod 'Mapbox-iOS-SDK', '~> 3.6'")]
	[Require("Xcode.Plist.Element", "<key>MGLMapboxAccessToken</key><string>pk.eyJ1IjoicGF2ZWxrb3N0ZW5rbyIsImEiOiJjajVmYWYwMW8xMWc0MzNvZGt1ajZhdHlzIn0.v3z5PDM8pAbRZZnCHWka5Q</string>")]

    [extern(iOS) Require("Source.Include", "Mapbox/Mapbox.h")]
	[extern(iOS) Require("Source.Include", "NeonMapView.h")]
	extern (iOS) internal class NeonMapboxView
	{
		public readonly ObjC.Object mapbox;		
		public Action OnReady;

		public NeonMapboxView()
		{
			mapbox = CreateContainer(viewDidAppear);
		}

		[Foreign(Language.ObjC)]
		ObjC.Object CreateContainer(Action onReady)
		@{
			NeonMapView* mapView =[[NeonMapView alloc] initWithonAppeard: onReady];
			[mapView initMapWithLatitude: 39.742043 longitude: -104.991531 andZoom: 13];
			return mapView;
		@}

		void viewDidAppear()
		{
			if(OnReady!=null)
				OnReady();
		}
	}

    [extern(iOS) Require("Source.Include", "Mapbox/Mapbox.h")]
	[extern(iOS) Require("Source.Include", "NeonMapView.h")]
	[extern(iOS) Require("Source.Include", "AnnotationObject.h")]
	extern(iOS) public class NeonMapbox : LeafView, Neon.Mapbox.INeonMapbox
	{
		Neon.Mapbox.NeonMapbox _mapboxHost;
		NeonMapboxView _mapView;
		public readonly ObjC.Object mapbox;	

		public static NeonMapbox Create(Neon.Mapbox.NeonMapbox mapViewHost)
		{
			return new NeonMapbox(mapViewHost, new NeonMapboxView());
		}

		NeonMapbox(Neon.Mapbox.NeonMapbox mapViewHost, NeonMapboxView view) : base(view.mapbox)
		{
			_mapView = view;
			mapbox = _mapView.mapbox;
			_mapboxHost = mapViewHost;
			_mapboxHost.MapboxClient = this;
			view.OnReady = OnReadyInternal;
		}

		bool _isReady;
		void OnReadyInternal()
		{
			getCalback();
			_isReady = true;
			if(OnReady!=null) OnReady();
		}

		[Foreign(Language.ObjC)]
		public void setMapCenter(double latitude, double longitude, double zoomlevel)
		@{
			NeonMapView* mb = @{NeonMapbox:Of(_this).mapbox:Get()};
			[mb moveTo:latitude longitude:longitude zoom:zoomlevel];
		@}

		public void setMap(double latitude, double longitude, double zoomlevel)
		{
			setMapCenter(latitude, longitude, zoomlevel);
		}

		[Foreign(Language.ObjC)]
		public void setMyLocation()
		@{
			NeonMapView* mb = @{NeonMapbox:Of(_this).mapbox:Get()};
			[mb setMyLocation];
		@}

		public void showMyLocationOnMap() {
			setMyLocation();
		}

		[Foreign(Language.ObjC)]
		public void removeAllMarkers()
		@{
			NeonMapView* mb = @{NeonMapbox:Of(_this).mapbox:Get()};
			[mb removeAllMarkers];
		@}

		[Foreign(Language.ObjC)]
		void getCalback()
		@{
			NeonMapView* mb = @{NeonMapbox:Of(_this).mapbox:Get()};
			mb.annotationClicked = ^(AnnotationObject* selectedAnnotation) {
				@{NeonMapbox:Of(_this).selectedAnnotation(int):Call(selectedAnnotation.identifier)};
			};
			mb.mapRegionChangedCallback = ^(double latitude, double longitude, double zoomLevel) {
			    NSLog(@"mapRegionChangedCallback");
                NSLog(@"%f", latitude);
                NSLog(@"%f", longitude);
                NSLog(@"%f", zoomLevel);
				@{NeonMapbox:Of(_this).mapRegionChanged():Call()};
			};
		@}

		void mapRegionChanged() 
		{
			_mapboxHost.OnMapChangedEnd();
		}

		public void selectedAnnotation(int identifier)
		{
			_mapboxHost.HandleMarkerTapped(identifier);
		}

		[Foreign(Language.ObjC)]
		ObjC.Object CreateAnnotationObject(String name, double latitude, double longitude, int identifier, String fontColor, String backgroundColor)
		@{
			AnnotationObject* selectedAnnotation = [[AnnotationObject alloc] initWithName:name 
				latitude:latitude longitude:longitude identifier:identifier fontColor:fontColor andBackgroundColor:backgroundColor];
            return selectedAnnotation;
		@}

		public void AddMarker(NeonMapboxMarker m)
		{
			AddMarkerToMapbox(m.Label, m.Latitude, m.Longitude, m.Identifier, m.FontColor, m.BGColor);
		}

		[Foreign(Language.ObjC)]
		void AddMarkerToMapbox(String name, double latitude, double longitude, int identifier, String fontColor, String backgroundColor)
		@{
			NeonMapView* mb = @{NeonMapbox:Of(_this).mapbox:Get()};
			AnnotationObject* selectedAnnotation = [[AnnotationObject alloc] initWithName:name 
				latitude:latitude longitude:longitude identifier:identifier fontColor:fontColor andBackgroundColor:backgroundColor];
			[mb addCustomAnnotation: selectedAnnotation];
		@}

		[Foreign(Language.ObjC)]
		public double GetLatitude()
		@{
			NeonMapView* mb = @{NeonMapbox:Of(_this).mapbox:Get()};
			return [mb getMapCenterLatitude];
		@}

		[Foreign(Language.ObjC)]
		public double GetLongitude()
		@{
			NeonMapView* mb = @{NeonMapbox:Of(_this).mapbox:Get()};
			return [mb getMapCenterLongitude];
		@}

		[Foreign(Language.ObjC)]
		public double GetZoomLevel()
		@{
			NeonMapView* mb = @{NeonMapbox:Of(_this).mapbox:Get()};
			return [mb getMapZoomLevel];
		@}

		public void UpdateMarkers()
		{
			removeAllMarkers();
			foreach(NeonMapboxMarker m in Markers)
			{
				AddMarker(m);
			}
		}

		public ObservableList<NeonMapboxMarker> Markers {
			get
			{
				return _mapboxHost.Markers;
			}
		}

		double _latInternal;
		public double Latitude
		{
			get
			{
				return Double.IsNaN(GetLatitude())
					? _latInternal : GetLatitude();
			}
		}

		double _lngInternal;
		public double Longitude
		{
			get
			{
				return Double.IsNaN(GetLongitude())
					? _lngInternal : GetLongitude();
			}
		}

		public double Zoom
		{
			get
			{
				return GetZoomLevel();
			}
		}

		[Foreign(Language.ObjC)]
		void DisposeMapView()
		@{
			NeonMapView* mb = @{NeonMapbox:Of(_this).mapbox:Get()};
			[mb removeMap];
			mb = nil;
		@}

		public override void Dispose()
		{
			DisposeMapView();
			_mapView = null;
			_mapboxHost.MapboxClient = null;
			_mapboxHost = null;
			base.Dispose();
		}

		public Action OnReady { get; set; }
	}
}