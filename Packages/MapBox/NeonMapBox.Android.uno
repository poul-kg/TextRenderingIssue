using Uno;
using Uno.UX;
using Uno.Time;
using Uno.Compiler.ExportTargetInterop;
using Fuse;
using Uno.Collections;
using Fuse.Controls;
using Fuse.Controls.Native;
using Fuse.Controls.Native.Android;
// event support
using Fuse.Scripting;
using Fuse.Reactive;
using Fuse.Gestures;

namespace Neon.Mapbox.Android
{
	[Require("Gradle.Dependency","compile('com.google.android.gms:play-services-maps:11.0.4')")]
	[Require("Gradle.Dependency","compile('com.google.android.gms:play-services-location:11.0.4')")]
	[ForeignInclude(Language.Java, "com.google.android.gms.maps.MapView")]	
	[ForeignInclude(Language.Java, "com.apps.neonmapbox.NeonMapView")]	
	
	extern (Android) internal class NeonMapboxView
	{
		public readonly Java.Object mapbox;		

		public NeonMapboxView()
		{
			mapbox = CreateContainer();
		}

		[Foreign(Language.Java)]
		Java.Object CreateContainer()
		@{
			NeonMapView mapView = new NeonMapView();
			return mapView;
		@}

	}

	[ForeignInclude(Language.Java, "android.util.Log")]
	[ForeignInclude(Language.Java, "com.apps.neonmapbox.NeonMapView")]	
	[ForeignInclude(Language.Java, "com.apps.neonmapbox.AnnotationObject")]

	extern(Android) public class NeonMapbox : LeafView, Neon.Mapbox.INeonMapbox
	{
		Neon.Mapbox.NeonMapbox _mapboxHost;
		NeonMapboxView _mapView;
		public readonly Java.Object mapbox;	

		public static NeonMapbox Create(Neon.Mapbox.NeonMapbox mapViewHost)
		{
			debug_log("Get New View");
			return new NeonMapbox(mapViewHost, new NeonMapboxView());
		}

		NeonMapbox(Neon.Mapbox.NeonMapbox mapViewHost, NeonMapboxView view) : base(view.mapbox)
		{
			_mapView = view;
			mapbox = _mapView.mapbox;
			_mapboxHost = mapViewHost;
			_mapboxHost.MapboxClient = this;
			getCallback(mapbox);
		}

		bool _isReady;
		void OnReadyInternal()
		{
			debug_log "Ready Callback";
			_isReady = true;
			if(OnReady!=null) OnReady();

		}

		[Foreign(Language.Java)]
		void getCallback(Java.Object mapbox)
		@{
			NeonMapView mb = (NeonMapView)mapbox;
			mb._callback = new NeonMapView.NeonMapCallback() {
		        @Override
		        public void onReady() {
		            @{NeonMapbox:Of(_this).OnReadyInternal():Call()};
		        }

		        @Override
		        public void mapRegionChangedCallback(double latitude, double longitude, double zoomLevel) {
		            Log.e("mapRegionChangedCallback", "");
	                Log.e("f", " " + latitude);
	                Log.e("f", " " + longitude);
	                Log.e("f", " " + zoomLevel);
					@{NeonMapbox:Of(_this).mapRegionChanged():Call()};
		        }

		        @Override
	            public void markerClicked(AnnotationObject annotationObject) {
	                @{NeonMapbox:Of(_this).selectedAnnotation(int):Call(annotationObject.getIdentifier())};
	            }
	        };
		@}

		[Foreign(Language.Java)]
		public void setMapCenter(Java.Object mapbox, double latitude, double longitude, double zoomlevel)
		@{
			NeonMapView mb = (NeonMapView)mapbox;
			mb.moveTo(latitude, longitude, zoomlevel);
		@}

		public void setMap(double latitude, double longitude, double zoomlevel)
		{
			debug_log "Moving Map";
			setMapCenter(mapbox, latitude, longitude, zoomlevel);
		}

		[Foreign(Language.Java)]
		public void setMyLocation(Java.Object mapbox)
		@{
			NeonMapView mb = (NeonMapView)mapbox;
			mb.showMyLocation();
		@}

		public void showMyLocationOnMap() {
			setMyLocation(mapbox);
		}

		[Foreign(Language.Java)]
		public void removeAllMarkers(Java.Object mapbox)
		@{
			NeonMapView mb = (NeonMapView)mapbox;
			mb.removeAllMarkers();
		@}

		void mapRegionChanged() 
		{
			_mapboxHost.OnMapChangedEnd();
		}

		public void selectedAnnotation(int identifier)
		{
			_mapboxHost.HandleMarkerTapped(identifier);
		}

		public void AddMarker(NeonMapboxMarker m)
		{
			AddMarkerToMapbox(mapbox, m.Label, m.Latitude, m.Longitude, m.Identifier, m.Icon, m.FontColor, m.BGColor);
		}

		[Foreign(Language.Java)]
		void AddMarkerToMapbox(Java.Object mapbox, String name, double latitude, double longitude, int identifier, String icon, String fontColor, String backgroundColor)
		@{
			NeonMapView mb = (NeonMapView)mapbox;
			AnnotationObject annotationObject = new AnnotationObject(name, latitude, longitude, identifier, icon, fontColor, backgroundColor);
			mb.addMarkerOnMap(annotationObject);
		@}

		[Foreign(Language.Java)]
		public double GetLatitude(Java.Object mapbox)
		@{
			NeonMapView mb = (NeonMapView)mapbox;
			return mb.getMapCenterLatitude();
		@}

		[Foreign(Language.Java)]
		public double GetLongitude(Java.Object mapbox)
		@{
			NeonMapView mb = (NeonMapView)mapbox;
			return mb.getMapCenterLongitude();
		@}

		[Foreign(Language.Java)]
		public double GetZoomLevel(Java.Object mapbox)
		@{
			NeonMapView mb = (NeonMapView)mapbox;
			return mb.getMapZoomLevel();
		@}

		public void UpdateMarkers()
		{
			removeAllMarkers(mapbox);
			debug_log "UpdateMarkers removing";
			debug_log("UpdateMarkers" + Markers.Count);
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
				return Double.IsNaN(GetLatitude(mapbox))
					? _latInternal : GetLatitude(mapbox);
			}
		}

		double _lngInternal;
		public double Longitude
		{
			get
			{
				return Double.IsNaN(GetLongitude(mapbox))
					? _lngInternal : GetLongitude(mapbox);
			}
		}

		public double Zoom
		{
			get
			{
				return GetZoomLevel(mapbox);
			}
		}

		[Foreign(Language.Java)]
		void DisposeMapView(Java.Object mapbox)
		@{
			NeonMapView mb = (NeonMapView)mapbox;
			mb.removeMap();
		@}

		public override void Dispose()
		{
			debug_log("Dispose" + Markers.Count);
			debug_log("Dispose");
			DisposeMapView(mapbox);
			debug_log("Dispose complete");
			_mapView = null;
			_mapboxHost.MapboxClient = null;
			_mapboxHost = null;
			base.Dispose();
		}

		public Action OnReady { get; set; }
	}

}