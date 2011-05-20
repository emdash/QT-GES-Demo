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
     visible: false
     property int curindex;
     property alias inPoint: viewer.inPoint
     property alias outPoint: viewer.outPoint
     property double duration: outPoint - inPoint
     property alias durationOnly: viewer.durationOnly

     function edit (index, uri, in_point, out_point, duration_only) {
         curindex = index
         editorPipeline.setUri (uri)
	 editorPipeline.pause()
	 if (!duration_only) {
	    editorPipeline.seek (in_point)
	    inPoint = in_point
	 } else {
	    inPoint = 0
	 }
	 outPoint = out_point
	 durationOnly = duration_only
	 timeline.visible = false
	 visible = true
     }

     function seekToInPoint() {
         editorPipeline.seek (inPoint)
     }

     function seekToOutPoint() {
         editorPipeline.seek (outPoint)
     }

     function setOutPoint () {
         outPoint = editorPipeline.position
     }

     function setInPoint () {
         inPoint = editorPipeline.position
     }

     function done () {
         editor.visible = false
	 timeline.visible = true
	 editorPipeline.stop()
	 if (!durationOnly) {	 
	    timeline.model.setInPoint (curindex, inPoint)
	 }
	 timeline.model.setOutPoint (curindex, outPoint)
     }
     
     GESTimelinePipeline {
         id: editorPipeline
	 surface: editorSurface
     }

     MediaViewer {
         id: viewer
         anchors {
	     left: parent.left
	     right: parent.right
	     top: parent.top
	     bottom: parent.bottom
	 }
	 
	 text: "Viewer"
         surface: editorSurface
	 pipeline: editorPipeline
	 showEditPoints: true
     }
}