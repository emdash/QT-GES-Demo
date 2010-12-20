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

	  property int start: 50
	  property int duration: 500
	  property int max_duration: 1000
	  property int position: joggle.position
	  
	  anchors {
	  	  right: parent.right
		  left: parent.left
	  }
	  
	  color: "grey"
	  height: 25

	  Rectangle {
	  	    anchors {
		    	    top: parent.top
			    bottom: parent.bottom
		    }
		    x: 100
		    width: 100
		    color: "lightsteelblue"
		    		    radius: 5

	  }

	  Rectangle {
	  	    anchors.top: parent.top
		    anchors.bottom: parent.bottom
		    x: position / max_duration * width
		    width: 1
		    color: "black"
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