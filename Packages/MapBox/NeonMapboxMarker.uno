using Fuse.Elements;
using Uno.UX;
using Uno;
using Neon.Mapbox;
namespace Fuse.Controls
{
    /** Adds a map marker to a @MapView
    To annotate the map, you must decorate it with `MapMarker` nodes. `MapMarker` nodes are simple value objects that contain a `Latitude`, a `Longitude` and a `Label`
    ```HTML
    <NativeViewHost>
        <MapView>
            <MapMarker Label="Fuse HQ" Latitude="59.9115573" Longitude="10.73888" />
        </MapView>
    </NativeViewHost>
    ```
    If you need to generate MapMarkers dynamically from JS, data binding and @(Each) are your friends. While we're scripting we might as well hook into the MapMarker's `Tapped` event to detect when the user has selected a marker.
    ```HTML
    <JavaScript>
        var Observable = require("FuseJS/Observable");
        module.exports = {
            markers : Observable({latitude:30.282786, longitude:-97.741736, label:"Austin, Texas", hometown:true}),
            onMarkerTapped : function(args) {
                console.log("Marker tapped: "+args.data.hometown);
            }
        }
    </JavaScript>
    <NativeViewHost>
        <MapView>
            <Each Items={markers}>
                <MapMarker Latitude="{latitude}" Longitude="{longitude}" Label="{label}" Tapped={onMarkerTapped} />
            </Each>
        </MapView>
    </NativeViewHost>
    ```
    @seealso Fuse.Controls.MapView
    */
    public class NeonMapboxMarker : Node
    {
        static int UID_POOL = 0;
        internal int uid = UID_POOL++;
        public delegate void MarkerTappedHandler(object sender, EventArgs args);
        public event MarkerTappedHandler Tapped;
        
        internal void HandleTapped()
        {
            if (Tapped != null)
                Tapped(this, new EventArgs());
        }

        int _identifier;
        public int Identifier {
            get
            {
                return _identifier;
            }
            set
            {
                _identifier = value;
                MarkDirty();
            }
        }
        
        string _label;
        public string Label {
            get
            {
                return _label;
            }
            set
            {
                _label = value;
                MarkDirty();
            }
        }

        string _icon;
        public string Icon {
            get
            {
                return _icon;
            }
            set
            {
                _icon = value;
                MarkDirty();
            }
        }

        double _latitude;
        /**
            The latitude coordinate of this marker
        */
        public double Latitude {
            get
            {
                return _latitude;
            }
            set
            {
                _latitude = value;
                MarkDirty();
            }
        }

        double _longitude;
        /**
            The longitude coordinate of this marker
        */
        public double Longitude {
            get
            {
                return _longitude;
            }
            set
            {
                _longitude = value;
                MarkDirty();
            }
        }

        string _fontColor;
        /**
            The longitude coordinate of this marker
        */
        public string FontColor {
            get
            {
                return _fontColor;
            }
            set
            {
                _fontColor = value;
                MarkDirty();
            }
        }

        string _backgroundColor;
        /**
            The longitude coordinate of this marker
        */
        public string BGColor {
            get
            {
                return _backgroundColor;
            }
            set
            {
                _backgroundColor = value;
                MarkDirty();
            }
        }

        protected override void OnRooted()
        {
            base.OnRooted();
            Neon.Mapbox.NeonMapbox m = Parent as Neon.Mapbox.NeonMapbox;
            if(m != null) m.AddMarker(this);
        }

        protected override void OnUnrooted()
        {
            base.OnUnrooted();
            Neon.Mapbox.NeonMapbox m = Parent as Neon.Mapbox.NeonMapbox;
            if(m != null) m.RemoveMarker(this);
        }

        void MarkDirty()
        {
            Neon.Mapbox.NeonMapbox m = Parent as Neon.Mapbox.NeonMapbox;
            if(m != null) m.UpdateMarkersNextFrame();
        }
    }
}