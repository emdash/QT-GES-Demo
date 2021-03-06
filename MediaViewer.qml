/* GStreamer Editing Services
 * Copyright (C) 2011 Brandon Lewis <brandon.lewis@collabora.co.uk>
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
import GES 1.0
import Gst 1.0

Item {
     id:root
     property GESTimelinePipeline pipeline
     property GstVideoSurface surface
     property alias text: label.text
     property alias inPoint: controls.inPoint
     property alias outPoint: controls.outPoint
     property alias showEditPoints: controls.showEditPoints
     property alias durationOnly: controls.durationOnly

     Text {
         id: label
         anchors {
	     top: parent.top
	     horizontalCenter: parent.horizontalCenter
	 }
	 font.pixelSize: 36
	 text: "label me"
	 color: "white"
     }
     
     GstVideoItem {
     	 id:viewer
	 x: 0
	 y: label.height
	 size: Qt.size(parent.width, parent.height - controls.height -
	               label.height - 24)
	 surface: parent.surface
     }

     MediaControls {
         id: controls
	 pipeline: parent.pipeline

	 anchors {
	    left: parent.left
	    right: parent.right
	    bottom: parent.bottom
	    bottomMargin: 12
	 }
	 
	 height: 50
     }
}