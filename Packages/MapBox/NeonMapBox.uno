using Uno;
using Uno.UX;
using Uno.Time;
using Uno.Collections;
using Uno.Compiler.ExportTargetInterop;
using Fuse.Controls;
using Fuse.Controls.Native;
using Uno.Permissions;
using Uno.Threading;
// Uno to JS event support
using Fuse.Scripting;
using Fuse.Reactive;
using Fuse;

namespace Neon.Mapbox
{
	public delegate void NeonMarkerEventHandler(object sender, NeonMarkerEventArgs args);
	public delegate void NeonMapRegionChangeEventHandler(object sender, NeonMapRegionChangeEventArgs args);

	public sealed class NeonMarkerEventArgs : EventArgs, Fuse.Scripting.IScriptEvent
	{
		public readonly int Identifier;

		public NeonMarkerEventArgs(int identifier)
		{
			Identifier = identifier;
		}

		void Fuse.Scripting.IScriptEvent.Serialize(IEventSerializer s)
		{
			s.AddInt("identifier", Identifier);
		}
	}

	public sealed class NeonMapRegionChangeEventArgs : EventArgs, Fuse.Scripting.IScriptEvent
	{
		public readonly double Latitude;
		public readonly double Longitude;
		public readonly double Zoom;

		public NeonMapRegionChangeEventArgs(double lat, double lng, double zoom)
		{
			Latitude = lat;
			Longitude = lng;
			Zoom = zoom;
		}

		void Fuse.Scripting.IScriptEvent.Serialize(IEventSerializer s)
		{
			s.AddDouble("latitude", Latitude);
			s.AddDouble("longitude", Longitude);
			s.AddDouble("zoom", Zoom);
		}
	}

	internal class NeonMapboxConfig
	{
		public double Latitude { get; set; }
		public double Longitude { get; set; }
		public double Zoom { get; set; }
		public bool ShowMyLocation { get; set; }

		public void CopyFrom(INeonMapbox mv)
		{
			Latitude = mv.Latitude;
			Longitude = mv.Longitude;
			Zoom = mv.Zoom;
		}
	}

	public interface INeonMapbox 
	{
		ObservableList<NeonMapboxMarker> Markers { get; }
		double Latitude { get; }
		double Longitude { get; }
		double Zoom { get; }

		void setMap(double latitude, double longitude, double zoomlevel);
		Action OnReady { get; set; }
		void showMyLocationOnMap();
		void UpdateMarkers();
	}

	[ForeignInclude(Language.Java, "android.content.pm.PackageManager")]
	[ForeignInclude(Language.Java, "android.support.v4.app.ActivityCompat")]
	[ForeignInclude(Language.Java, "com.fuse.Activity")]

	public partial class NeonMapbox : Panel
	{
		NeonMapboxConfig _mapConfig;
		bool _mapReady = false;
		public event NeonMarkerEventHandler MarkerTapped;
		public event NeonMapRegionChangeEventHandler RegionChanged;
		internal ObservableList<NeonMapboxMarker> _markers;

		INeonMapbox _mapboxClient;
		internal INeonMapbox MapboxClient
		{
			get { return _mapboxClient; }
			set
			{
				_mapboxClient = value;
				if(_mapboxClient == null)
				{
					_mapReady = false;
					return;
				}
				MapboxClient.OnReady = OnMapReady;
			}
		}

		public NeonMapbox()
		{
			_mapConfig = new NeonMapboxConfig();
		}

		protected override IView CreateNativeView()
		{
			if defined(iOS)
			{
				return Neon.Mapbox.iOS.NeonMapbox.Create(this);
			}
			else if defined(Android)
			{
				return Neon.Mapbox.Android.NeonMapbox.Create(this);
			}
			else
			{
				return base.CreateNativeView();
			}
		}

		void OnMapReady()
		{
			debug_log "OnMapReady";
			if(MapboxClient == null) return;
			_mapReady = true;
			MapboxClient.OnReady = null;
			MapboxClient.setMap(_mapConfig.Latitude, _mapConfig.Longitude, _mapConfig.Zoom);
			if (_mapConfig.ShowMyLocation) {
				MapboxClient.showMyLocationOnMap();
			}
			UpdateRestState();
			UpdateMarkers();
		}

		internal extern(iOS) void AddMarker(NeonMapboxMarker m)
		{
			debug_log "Want to add marker m";
			debug_log "Latitude: " + m.Latitude;
			debug_log "Longitude: " + m.Longitude;
			debug_log "Label: " + m.Label;
			debug_log "Icon: " + m.Icon;
			debug_log "BackgroundColor: " + m.BGColor;
			debug_log "FontColor: " + m.FontColor;
			Markers.Add(m);
		}

		internal extern(Android) void AddMarker(NeonMapboxMarker m)
		{
			debug_log "Want to add marker m";
			debug_log "Latitude: " + m.Latitude;
			debug_log "Longitude: " + m.Longitude;
			debug_log "Label: " + m.Label;
			debug_log "Icon: " + m.Icon;
			debug_log "BackgroundColor: " + m.BGColor;
			debug_log "FontColor: " + m.FontColor;
			Markers.Add(m);
		}

		internal extern(!Mobile) void AddMarker(NeonMapboxMarker m)
		{
			debug_log "PREVIEW: Want to add marker m";
			debug_log "PREVIEW: Latitude: " + m.Latitude;
			debug_log "PREVIEW: Longitude: " + m.Longitude;
			debug_log "PREVIEW: Label: " + m.Label;
			debug_log "Icon: " + m.Icon;
			debug_log "BackgroundColor: " + m.BGColor;
			debug_log "FontColor: " + m.FontColor;
			Markers.Add(m);
		}

		internal extern(iOS) void RemoveMarker(NeonMapboxMarker m)
		{
			debug_log "Want to remove marker m";
			debug_log "Latitude: " + m.Latitude;
			debug_log "Longitude: " + m.Longitude;
			debug_log "Label: " + m.Label;
			debug_log "Icon: " + m.Icon;
			debug_log "BackgroundColor: " + m.BGColor;
			debug_log "FontColor: " + m.FontColor;
			Markers.Remove(m);
		}

		internal extern(Android) void RemoveMarker(NeonMapboxMarker m)
		{
			debug_log "Want to remove marker m";
			debug_log "Latitude: " + m.Latitude;
			debug_log "Longitude: " + m.Longitude;
			debug_log "Label: " + m.Label;
			debug_log "Icon: " + m.Icon;
			debug_log "BackgroundColor: " + m.BGColor;
			debug_log "FontColor: " + m.FontColor;
			Markers.Remove(m);
		}

		internal extern(!Mobile) void RemoveMarker(NeonMapboxMarker m)
		{
			debug_log "Want to remove marker m";
			debug_log "Latitude: " + m.Latitude;
			debug_log "Longitude: " + m.Longitude;
			debug_log "Label: " + m.Label;
			debug_log "Icon: " + m.Icon;
			debug_log "BackgroundColor: " + m.BGColor;
			debug_log "FontColor: " + m.FontColor;
			Markers.Remove(m);
		}

		void ApplyCameraState()
		{
			_willUpdateCameraNextFrame = false;
			if(_mapReady)
				MapboxClient.setMap(Latitude, Longitude, Zoom);
		}

		bool _willUpdateCameraNextFrame;
		internal void UpdateCameraNextFrame()
		{
			if(!_mapReady || _willUpdateCameraNextFrame) return;
			UpdateManager.PerformNextFrame(ApplyCameraState, UpdateStage.Primary);
			_willUpdateCameraNextFrame = true;
		}

		internal void OnMapChangedEnd()
		{
			if(_mapReady)
				_mapConfig.CopyFrom(MapboxClient);
			UpdateRestState();
			RegionChanged(this, new NeonMapRegionChangeEventArgs(_mapConfig.Latitude, _mapConfig.Longitude, _mapConfig.Zoom));
		}

		internal void UpdateRestState()
		{
			OnPropertyChanged(_latitudeName, this);
			OnPropertyChanged(_longitudeName, this);
			OnPropertyChanged(_zoomName, this);
		}

		public ObservableList<NeonMapboxMarker> Markers
		{
			get
			{
				if(_markers==null) _markers = new ObservableList<NeonMapboxMarker>(OnMarkerAdded, OnMarkerRemoved);
				return _markers;
			}
		}

		public void UpdateMarkers()
		{
			if(_mapReady && MapboxClient != null)
				MapboxClient.UpdateMarkers();
		}

		public void ClearMarkers(){
			_markers.Clear();
			UpdateMarkers();
		}

		void OnMarkerAdded(NeonMapboxMarker marker)
		{
			UpdateMarkersNextFrame();
		}

		void OnMarkerRemoved(NeonMapboxMarker marker)
		{
			UpdateMarkersNextFrame();
		}

		bool _willUpdateMarkersNextFrame;
		internal void UpdateMarkersNextFrame()
		{
			if(!_mapReady || _willUpdateMarkersNextFrame) return;
			UpdateManager.PerformNextFrame(DeferredMarkerUpdate, UpdateStage.Primary);
			_willUpdateMarkersNextFrame = true;
		}

		void DeferredMarkerUpdate()
		{
			_willUpdateMarkersNextFrame = false;
			UpdateMarkers();
		}

		Selector _zoomName = "Zoom";

		[UXOriginSetter("SetZoom")]
		/** The zoom level of the camera. Corresponds to [Google Maps' Zoom Levels](https://developers.google.com/maps/documentation/static-maps/intro#Zoomlevels). */
		public double Zoom
		{
			get { return _mapConfig.Zoom; }
			set { SetZoom(value, this);	}
		}

		public void SetZoom(double value, IPropertyListener origin)
		{
			_mapConfig.Zoom = value;
			UpdateCameraNextFrame();
			OnPropertyChanged(_zoomName, origin);
		}

		/**
			Latitude
		**/
		Selector _latitudeName = "Latitude";

		[UXOriginSetter("SetLatitude")]
		/** The latitude coordinate. */
		public double Latitude
		{
			get { return _mapConfig.Latitude; }
			set { SetLatitude(value, this);	}
		}

		public void SetLatitude(double value, IPropertyListener origin)
		{
			_mapConfig.Latitude = value;
			UpdateCameraNextFrame();
			OnPropertyChanged(_latitudeName, origin);
		}

		Selector _longitudeName = "Longitude";

		[UXOriginSetter("SetLongitude")]
		/** The longitude coordinate. */
		public double Longitude
		{
			get { return _mapConfig.Longitude; }
			set { SetLongitude(value, this);	}
		}

		public void SetLongitude(double value, IPropertyListener origin)
		{
			_mapConfig.Longitude = value;
			UpdateCameraNextFrame();
			OnPropertyChanged(_longitudeName, origin);
		}

		Selector _showMyLocationName = "ShowMyLocation";

		[UXOriginSetter("SetShowMyLocationn")]
		/** The longitude coordinate. */
		public bool ShowMyLocation
		{
			get { return _mapConfig.ShowMyLocation; }
			set { 
					if defined (Android)
					{
						debug_log("ShowMyLocation");
						AskMapPermission(value);
					}
					else 
					{
						SetShowMyLocationn(value, this);
					}
				}
		}

		public void SetShowMyLocationn(bool value, IPropertyListener origin)
		{
			_mapConfig.ShowMyLocation = value;
			OnPropertyChanged(_showMyLocationName, origin);
		}

		[Foreign(Language.Java)]
    	extern(Android) bool CheckMapPermission()
   		@{
      		  return (ActivityCompat.checkSelfPermission(Activity.getRootActivity(), android.Manifest.permission.ACCESS_FINE_LOCATION) ==
                PackageManager.PERMISSION_GRANTED && 
                ActivityCompat.checkSelfPermission(Activity.getRootActivity(), android.Manifest.permission.ACCESS_COARSE_LOCATION) ==
                PackageManager.PERMISSION_GRANTED );
    	@}

		bool showLocation;
    	public void AskMapPermission(bool value)
    	{
    		showLocation = value;
    		if defined(Android) {
	    		if (!CheckMapPermission())
	    		{
	    			var permissions = new PlatformPermission[] 
					{
						Permissions.Android.ACCESS_FINE_LOCATION,
						Permissions.Android.ACCESS_COARSE_LOCATION
					};
					Permissions.Request(permissions).Then(Execute, Reject);
	    		}
	    		else {
	    			SetShowMyLocationn(showLocation, this);
	    		}
    		}
    	}

    	public void Execute(PlatformPermission[] grantedPermissions)
		{
			SetShowMyLocationn(showLocation, this);
		}

		public void Reject(Exception e)
		{
			debug_log("Could not acquire location permissions");
		}

		public void HandleMarkerTapped(int indentifier)
		{
			if(MarkerTapped != null)
				MarkerTapped(this, new NeonMarkerEventArgs(indentifier));

			foreach(NeonMapboxMarker m in Markers)
			{
				if(m.Identifier == indentifier)
				{
					m.HandleTapped();
					return;
				}
			}
		}
	}
}
