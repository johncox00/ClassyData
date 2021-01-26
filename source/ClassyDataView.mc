using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Application;
using Toybox.Graphics as Gfx;
using Toybox.Activity;

var width, height, device_settings;
var fast_updates = true;
var bgColor = Gfx.COLOR_WHITE;
var fgColor = Gfx.COLOR_BLACK;


class ClassyDataView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
        width = dc.getWidth();
	    height = dc.getHeight();
	    device_settings = System.getDeviceSettings();
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        var theme = Application.getApp().getProperty("Theme");
		
		if (theme == 0) {
		    bgColor = Gfx.COLOR_BLACK;
			fgColor = Gfx.COLOR_WHITE;
		} 
		
		       
        dc.setColor( bgColor,  bgColor);
    	dc.fillRectangle(0, 0, width, height);
    	dc.clear();
    	
    	var clockTime = System.getClockTime();
        var dateStrings = Time.Gregorian.info( Time.now(), Time.FORMAT_MEDIUM);
        var dateStrings_s = Time.Gregorian.info( Time.now(), Time.FORMAT_SHORT);
        var hour, min, time, day, sec, month;
        day  = dateStrings.day;
        month  = dateStrings.month;
        min  = clockTime.min;
        hour = clockTime.hour;
        sec  = clockTime.sec;
        
        
        draw_min(dc, 60, 1, (width/2), (height/2-12), fgColor, 360); 
        
        draw_min(dc, 12, 3, (width/2), (height/2-20), fgColor, 360); 
        
        if (fast_updates){
            drawsec(dc, 100);    
        }
        
        draw_watch_finger(dc, hour, min, fgColor, 6, 3, height/2, (0.75*height/2), (0.9*height/2) );
        
        // Layout the non-time data
        dc.setColor(fgColor, fgColor);
        dc.drawCircle(width/2, height/2, height*2/7); // circle around major circle
        
        // Date //
        
   		var dateCircleY = (height / 2); // - (height / 6);
   		var dateCircleX = width * .25;
   		dataCircle(dc, dateCircleX, dateCircleY, day.toString(), month.toString());
        

        // HR //
        
        var hrCircleY = dateCircleY;
        var hrCircleX = width * .75;
        var heartRate = Activity.getActivityInfo().currentHeartRate;
        
        if(heartRate!=null) {

			heartRate = heartRate.toString();
		
		}
		
		else{
		
			heartRate = "--";
		
		}
        
        dataCircle(dc, hrCircleX, hrCircleY, heartRate, "BPM");
        
        // Battery //
        
        var batCircleY = height - (height / 4);
        var batCircleX = (width / 2);
        var batt = System.getSystemStats().battery; // get battery status
        batt = batt.toNumber(); // safety first --> set it to integer
        dc.setColor( fgColor,  Gfx.COLOR_TRANSPARENT);
        dc.drawText(batCircleX, batCircleY + Gfx.FONT_SYSTEM_XTINY, Gfx.FONT_XTINY, batt + "%", Gfx.TEXT_JUSTIFY_CENTER);
        
//        dataCircle(dc, batCircleX, batCircleY, batt + "%", null);
        
 
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
      fast_updates = false;
      WatchUi.requestUpdate();
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
        fast_updates = true;    // indicator that everythings goes fast now (fast = 1 sec per update)    
        WatchUi.requestUpdate();
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
        fast_updates = false;
        WatchUi.requestUpdate();
    }
    
    function draw_min(dc, divisor, pen, rad1, rad2, color, maxdeg){  
            var xx, x, yy, y, cur_deg;
            cur_deg = 0;
            dc.setPenWidth(pen);
            dc.setColor( color,  color);
            for (var k = 0; k < divisor; k++){
                cur_deg =   k * (360 / divisor);
                cur_deg = cur_deg.toFloat();
                if (cur_deg < maxdeg){
	                yy  = rad1 + rad2 * ( Math.cos(Math.PI * ((180 + -1 * cur_deg.toFloat()) / 180)));
	                y = rad1 + rad1 * ( Math.cos(Math.PI * ((180 + -1 * cur_deg.toFloat()) / 180)));  
	                xx  = rad1 + rad2 * ( Math.sin(Math.PI * ((180 + -1 * cur_deg.toFloat()) / 180)));
	                x = rad1 + rad1 *  ( Math.sin(Math.PI * ((180 + -1 * cur_deg.toFloat()) / 180)));
	                // draw line
					dc.setColor( color,  color);
					dc.drawLine(x, y, xx, yy);
				}                
             }
            dc.setPenWidth(1);
    }
    
    function draw_watch_finger(dc,hour, min, color, hourpen, minpen, rad1, radhour, radmin){
    	var xx, x, yy, y, cur;
    	//DRAW HOUR FINGER	
		dc.setColor( color,  color); // set color
		cur = 180 + hour % 12 * -30; 
        cur = cur.toFloat() - ((min.toFloat()/60)*30); 
		x = rad1;
		y = rad1;
		xx = rad1 + radhour * ( Math.sin(Math.PI * (cur.toFloat() / 180))); 
		yy = rad1 + radhour * ( Math.cos(Math.PI * (cur.toFloat() / 180))); 
		dc.setPenWidth(hourpen);
		dc.drawLine(x, y, xx, yy); 
		
		// now draw minute finger
		x = rad1;
		y = rad1;
		cur = 180 + min * -6; // 6° per Minute 
		xx = rad1 + radmin * ( Math.sin(Math.PI * (cur.toFloat() / 180)));  
		yy = rad1 + radmin * ( Math.cos(Math.PI * (cur.toFloat()  /180)));  
		dc.setPenWidth(minpen); 
		dc.drawLine(x, y, xx, yy); 

    }
    
    function drawsec(dc, rad2){  
            var dateInfo = Time.Gregorian.info( Time.now(), Time.FORMAT_SHORT );
            var sec  = dateInfo.sec;  
            for (var k = 0; k <= 59; k++){
	            if ( k == sec ) {    
	                dc.setColor(fgColor, fgColor);
	                var xx, xx2, yy, yy2,kxx,kyy,kxx2,kyy2, cur, slim;
	                cur = 180 + k * -6;
	                slim = 2;
	                yy  = 1 + dc.getWidth()/2 * (1+Math.cos(Math.PI*(cur-2)/180));
	                yy2 = 1 + dc.getWidth()/2 * (1+Math.cos(Math.PI*(cur+3)/180));  
	                xx  = 1 + dc.getWidth()/2 * (1+Math.sin(Math.PI*(cur-2)/180));
	                xx2 = 1 + dc.getWidth()/2 * (1+Math.sin(Math.PI*(cur+3)/180)); 
	                kyy  = 1 + dc.getWidth()/2 + rad2 * (Math.cos(Math.PI*(cur-2)/180)); 
	                kyy2 = 1 + dc.getWidth()/2 + rad2 * (Math.cos(Math.PI*(cur+3)/180));  
	                kxx  = 1 + dc.getWidth()/2 + rad2 * (Math.sin(Math.PI*(cur-2)/180));
	                kxx2 = 1 + dc.getWidth()/2 + rad2 * (Math.sin(Math.PI*(cur+3)/180));                               
	                if ( k == sec ){dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_RED); }  
	                if (yy > 180) {yy = yy -1; yy2 = yy2 -1;} 
	                dc.fillPolygon([[kxx, kyy], [xx, yy], [xx2, yy2], [kxx2, kyy2]]);
	            }  
            }           
                
    }
    
    function dataCircle(dc, x, y, text1, text2) {
    	dc.drawCircle(x, y, 25); //circle around tiny date-circle
        dc.setColor( bgColor,  bgColor);
        dc.fillCircle(x, y, 25);
        dc.setColor( fgColor,  Gfx.COLOR_TRANSPARENT);
        if (text2 == null) {
            dc.drawText(x, y-13, Gfx.FONT_TINY, text1, Gfx.TEXT_JUSTIFY_CENTER);
        } else {
	        dc.drawText(x, y-23, Gfx.FONT_TINY, text1, Gfx.TEXT_JUSTIFY_CENTER);
	        dc.drawText(x, y-6, Gfx.FONT_XTINY, text2, Gfx.TEXT_JUSTIFY_CENTER);
	    }
    }

}
