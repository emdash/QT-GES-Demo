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
import GES 1.0
import Gst 1.0

Item {
     id:root
     property string uri
     visible: false

     function edit (uri) {
         inPointPipeline.setUri (uri)
	 inPointPipeline.pause()
	 outPointPipeline.setUri (uri)
	 outPointPipeline.pause ()
	 visible = true
	 timeline.visible = false
     }
     
     GESTimelinePipeline {
         id: inPointPipeline
	 surface: inPointSurface
     }

     GESTimelinePipeline {
        id: outPointPipeline
	surface: outPointSurface
     }

     MediaViewer {
         anchors {
	     left: parent.left
	     top: parent.top
	     bottom: parent.bottom
	 }
	 
	 text: "In Point"
	 width: (parent.width / 2) - 12
         surface: inPointSurface
	 pipeline: inPointPipeline
     }

     MediaViewer {
         anchors {
	     right: parent.right
	     top: parent.top
	     bottom: parent.bottom
	 }

	 text: "Out Point"
	 width: (parent.width / 2) - 12
         surface: outPointSurface
	 pipeline: outPointPipeline
     }

}