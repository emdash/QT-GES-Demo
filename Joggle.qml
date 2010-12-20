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
    anchors {
    	    right: parent.right
	    left: parent.left
    }

    property int duration: 100
    property int position: 0

    color: "grey"
    height: 25
    clip: true

    Repeater {
    	id:stripes
	model: 8
	delegate: Image {
	    id:stripe
	    height: 25
	    source: "images/stripes.png"
	    fillMode: Image.TileHorizontally
	    opacity: 0.5
	    x: (index - 1) * width + (position % width)
	}
    }

    MouseArea {
    	      anchors.fill: parent
	      property int curpos
	      property int mdown

	      onPressed: {
	      		 curpos = position
			 mdown = mouse.x
	      }

	      onReleased: {
	      		  // this is where you might set a playback rate based on the mouse velocity to implement "flicking" the movie
	      }
	      
	      onPositionChanged: {
	      		position = curpos + (mouse.x - mdown)
	      }
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

    Text {
    	 anchors.left: parent.left
	 anchors.top: parent.top
    	 text: position
    }
}
