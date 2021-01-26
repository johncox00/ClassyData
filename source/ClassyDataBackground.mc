using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Graphics;
using Toybox.System;

class Background extends WatchUi.Drawable {

    function initialize() {
        var dictionary = {
            :identifier => "Background"
        };

        Drawable.initialize(dictionary);
    }

    function draw(dc) {
        // Set the background color then call to clear the screen
        var color = Graphics.COLOR_BLACK;
        if (Application.getApp().getProperty("Theme") == 1) {
             color = Graphics.COLOR_WHITE;
        }
        dc.setColor(Graphics.COLOR_TRANSPARENT, color);
        dc.clear();
    }

}
