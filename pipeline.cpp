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

#include "pipeline.h"

/* declarations for C friend functions which handle GLib signals */

void pipeline_pad_added_cb(GstElement *unused,
			   GstPad *pad,
			   Pipeline *);

/* bus message handler so we can track things like EOS and state changes */

void
bus_message_cb (GstBus * bus, GstMessage * message, Pipeline * pipeline)
{
  const GstStructure *s;
  s = gst_message_get_structure (message);

  switch (GST_MESSAGE_TYPE (message)) {
  case GST_MESSAGE_ERROR:
    g_print ("ERROR\n");
    GST_DEBUG_BIN_TO_DOT_FILE(GST_BIN(pipeline->pipeline),
			      GST_DEBUG_GRAPH_SHOW_ALL,
			      "debug");
    break;
  case GST_MESSAGE_EOS:
    pipeline->stop();
    break;
  case GST_MESSAGE_STATE_CHANGED:
    if (s && GST_MESSAGE_SRC (message) == GST_OBJECT_CAST (pipeline->pipeline)) {
      GstState old, new_, pending;
      gst_message_parse_state_changed (message, &old, &new_, &pending);
      pipeline->privSetState(new_);
    }
    break;
  default:
    break;
  }
}

Pipeline::
Pipeline()
{
  isUriSource = false;
  src = 0;
  mSurface = 0;
  
  pipeline = gst_pipeline_new ("Pipeline");
  asnk = gst_element_factory_make ("autoaudiosink", NULL);
  vq = gst_element_factory_make ("queue2", NULL);
  aq = gst_element_factory_make ("queue2", NULL);
  aconv = gst_element_factory_make ("audioconvert", NULL);
  csp = gst_element_factory_make ("ffmpegcolorspace", NULL);
  
  GstBus *bus = gst_pipeline_get_bus(GST_PIPELINE(pipeline));
  gst_bus_add_signal_watch(bus);
   
  gst_bin_add_many(GST_BIN(pipeline),
		   vq,
		   aq,
		   asnk,
		   aconv,
		   csp,
		   NULL);
  
  gst_element_link_many(csp, vq, NULL);
  gst_element_link_many(aconv, aq, asnk, NULL);

  // register bus handler so we can keep track of state changes
  m_state = GST_STATE_NULL;
  g_signal_connect(G_OBJECT(bus), "message",
		   G_CALLBACK(bus_message_cb), this);

  // these timers help implement seeking and the position/duration
  // properties
  queryTimer = new QTimer ();
  seekTimer = new QTimer ();
  lastSeek = new QElapsedTimer ();
  connect(queryTimer, SIGNAL(timeout()), this, SLOT(queryPositionDuration()));
  connect(seekTimer, SIGNAL(timeout()), this, SLOT(seekToPosition()));
}

void Pipeline::
setSource (GstElement * inSrc)
{
  qDebug () << "setting source" << inSrc;
  
  if (src) {
    qDebug () << "warning: already have source set";
    return;
  }
  
  src = inSrc;
  gst_bin_add(GST_BIN(pipeline), src);
 
  // this handles connecting to the source when new pads are added
  g_signal_connect(G_OBJECT(src), "pad-added",
		   G_CALLBACK(pipeline_pad_added_cb), this);

}

void Pipeline::
setUri(QString uri)
{
  if (!src) {
    setSource(gst_element_factory_make("uridecodebin", NULL));
    isUriSource = true;
  } else if (!isUriSource) {
    qDebug () << "This pipeline is displaying something other than a file."
      " You cannot set the uri.";
    return;
  }

  if (paused() || playing ()) {
    stop();
  }

  g_object_set (G_OBJECT(src), "uri", (char *) uri.toAscii().constData(), NULL);
}

Pipeline::~Pipeline()
{
  gst_element_set_state(GST_ELEMENT(pipeline), GST_STATE_NULL);
  // FIXME: why does this call throw std::bad_alloc?
  // gst_object_unref(GST_OBJECT(pipeline));
  pipeline = 0;
  pipeline = 0;
}

/* connect pads to the output sinks */

void
pipeline_pad_added_cb (GstElement * unused,
		       GstPad * pad,
		       Pipeline * pipeline)
{
    GstPad * tpad;

    qDebug () << "in pad-added cb";
    
    if ((tpad = gst_element_get_compatible_pad (pipeline->csp, pad, NULL))) {
	gst_pad_link (pad, tpad);
    } else if ((tpad = gst_element_get_compatible_pad (pipeline->aconv, pad, NULL))) {
	gst_pad_link (pad, tpad);
    }
}
  
/* playback state funtions and methods */

void Pipeline::
preview()
{
  gst_element_set_state(GST_ELEMENT(pipeline), GST_STATE_PLAYING);
}

void Pipeline::
pause()
{
  gst_element_set_state(GST_ELEMENT(pipeline), GST_STATE_PAUSED);
}

void Pipeline::
stop()
{
  gst_element_set_state(GST_ELEMENT(pipeline), GST_STATE_READY);
}

void Pipeline::
seek(double position)
{
  if (!seekTimer->isActive()) {
    seekTimer->start (80);
  }

  if (playing()) {
    pause();
  }
  
  mSeekRequest = (gint64) position;
  lastSeek->start();
}

void Pipeline::
seekToPosition()
{
  if (gst_element_seek(GST_ELEMENT(pipeline),
		       1.0,
		       GST_FORMAT_TIME,
		       (GstSeekFlags)(GST_SEEK_FLAG_ACCURATE | GST_SEEK_FLAG_FLUSH),
		       GST_SEEK_TYPE_SET,
		       (gint64) mSeekRequest,
		       GST_SEEK_TYPE_NONE,
		       GST_CLOCK_TIME_NONE)) {
    
    queryPositionDuration();
  }
  
  if (lastSeek->hasExpired(250)) {
    seekTimer->stop();
  }
}

void Pipeline::
privSetState(GstState state)
{
  bool wasPlaying = playing();
  bool wasPaused = paused();
  m_state = state;
  if (playing() != wasPlaying)
  {
    emit playingChanged(playing());
  }
  if (paused() != wasPaused)
  {
    emit pausedChanged(playing());
  }

  if (playing() && !queryTimer->isActive() ) {
    queryTimer->start(50);
  } else if (paused()) {
    queryTimer->stop();
    queryPositionDuration();
  } else {
    queryTimer->stop();
  }
}

bool Pipeline::
playing()
{
  return m_state == GST_STATE_PLAYING;
}

bool Pipeline::
paused()
{
    return m_state == GST_STATE_PAUSED;
}

QmlPainterVideoSurface * Pipeline::
surface()
{
    return mSurface;
}

void Pipeline::
setSurface(QmlPainterVideoSurface * surface)
{
  qDebug () << "setting surface" << surface;
  if (mSurface) {
    qDebug () << "WARNING: We already have a surface!";
    return;
  }
  mSurface = surface;
  vsnk = GST_ELEMENT(QmlVideoSurfaceGstSink::createSink(surface));
  gst_bin_add(GST_BIN(pipeline), vsnk);
  gst_element_link (vq, vsnk);
}

void Pipeline ::
queryPositionDuration()
{
  GstFormat format = GST_FORMAT_TIME;
  gint64 new_duration, new_position;

  if (gst_element_query_duration (pipeline, &format, &new_duration)) {
    if (((double) new_duration) != mDuration) {
      mDuration = (double) new_duration;
      emit durationChanged(mDuration);
    }
  }
  
  if (gst_element_query_position (pipeline, &format, &new_position)) {
    if (((double) new_position) != mPosition) {
      mPosition = (double) new_position;
      emit positionChanged(mPosition);
    }
  }
}

double Pipeline::
position ()
{
  return mPosition;
}

double Pipeline::
duration ()
{
  return mDuration;
}
