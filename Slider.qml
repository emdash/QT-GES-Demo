/* GStreamer Editing Services
 * Copyright (C) 2010 Brandon Lewis <brandon.lewis@collabora.co.uk>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */
 
import Qt 4.7

Rectangle {

	  property double start: 50
	  property double duration: 500
	  property double max_duration: 1000
	  property double position: 0
	  property bool edit_points: false
	  
	  anchors {
	  	  right: parent.right
		  left: parent.left
	  }
	  
	  color: "grey"
	  height: 10

	  Rectangle {
	  	    anchors {
		    	top: parent.top
			    bottom: parent.bottom
		    }
		    x: 100
		    width: 100
		    color: "red"
		    radius: 5
		    visible: edit_points
	  }

	  Image {
            source: "images/slider_thumb.png"
	    anchors.top: parent.top
	    anchors.bottom: parent.bottom
            anchors.topMargin: -7
            anchors.bottomMargin: -7
            x: ((position / max_duration) * parent.width) - (width / 2)
	  }

      Rectangle {
        anchors.fill: parent
	    gradient: Gradient {
		        GradientStop { position: 0.0; color: "#99FFFFFF" }
		        GradientStop { position: 0.5; color: "#00FFFFFF" }
	    }
	    border.width: 1
	    border.color: "gray"
    }

}