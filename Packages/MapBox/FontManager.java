package com.apps.neonmapbox;

import android.content.Context;
import android.graphics.Typeface;

/**
 * Created by dhvlsimac on 21/09/17.
 */

public class FontManager {

    public static final String ROOT = "fonts/",
            FONTAWESOME = ROOT + "fontawesome-webfont.ttf";

    public static Typeface getTypeface(Context context, String font) {
        return Typeface.createFromAsset(context.getAssets(), font);
    }

}