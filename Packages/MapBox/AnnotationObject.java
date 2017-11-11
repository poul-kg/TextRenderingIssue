package com.apps.neonmapbox;

/**
 * Created by dhvlsimac on 18/09/17.
 */

public class AnnotationObject {

    public String name;
    public double latitude;
    public double longitude;
    public int identifier;
    public String icon;
    public String fontColor;
    public String bgColor;

    public AnnotationObject(String name, double lat, double lng, int identifier, String icon, String fontColor, String bgColor) {
        this.name = name;
        this.latitude = lat;
        this.longitude = lng;
        this.identifier = identifier;
        this.icon = icon;
        this.fontColor = fontColor;
        this.bgColor = bgColor;
    }

    public String getName() {
        return name;
    }

    public double getLatitude() {
        return latitude;
    }

    public double getLongitude() {
        return longitude;
    }

    public int getIdentifier() {
        return identifier;
    }

    public String getIcon() {
        return icon;
    }

    public String getFontColor() {
        return fontColor;
    }

    public String getBGColor() {
        return bgColor;
    }

}
