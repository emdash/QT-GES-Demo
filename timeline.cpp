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

#include "timeline.h"

enum roles
{
  thumb_uri_role,
  media_uri_role,
  duration_role,
  inpoint_role,
  outpoint_role,
  duration_only_role,
};

/* declarations for C friend functions which handle GLib signals */

void layer_object_added_cb(GESTimelineLayer *,
  GESTimelineObject *,
  Timeline *);

void layer_object_removed_cb(GESTimelineLayer *,
  GESTimelineObject *,
  Timeline *);

void layer_object_moved_cb(GESTimelineLayer *,
  GESTimelineObject *,
  gint,
  gint,
  Timeline *);

void timeline_object_notify_duration_cb(GESTimelineObject *,
  GParamSpec *,
  Timeline *);

/* class constructor */

Timeline::
Timeline(QObject *parent) : QAbstractListModel(parent)
{
  timeline = ges_timeline_new_audio_video();
  layer = ges_simple_timeline_layer_new();
  ges_timeline_add_layer(timeline, GES_TIMELINE_LAYER(layer));

  g_signal_connect(G_OBJECT(layer), "object-added",
    G_CALLBACK(layer_object_added_cb), this);
  g_signal_connect(G_OBJECT(layer), "object-moved",
    G_CALLBACK(layer_object_moved_cb), this);
  g_signal_connect(G_OBJECT(layer), "object-removed",
    G_CALLBACK(layer_object_removed_cb), this);

  QHash <int, QByteArray> rolenames;
  rolenames[thumb_uri_role] = "thumb_uri";
  rolenames[media_uri_role] = "media_uri";
  rolenames[inpoint_role] = "in_point";
  rolenames[outpoint_role] = "out_point";
  rolenames[duration_role] = "duration";
  rolenames[duration_only_role] = "duration_only";
  setRoleNames(rolenames);
  row_count = 0;
}

Timeline::~Timeline()
{
}

/* functions and methods implementing the QAbstractListModel
   interface */

int Timeline::
rowCount(const QModelIndex &parent) const
{
  return row_count;
}

int Timeline::count()
{
  return row_count;
}

QString Timeline::
thumbForObject(GESTimelineObject * obj) const
{
  gchar * uri;
  g_object_get(G_OBJECT(obj), "uri", &uri, NULL);
  QString quri(uri);
  g_free(uri);
  QString local = QUrl(quri).toLocalFile();
  QString relative = QDir("media/").relativeFilePath(local);
  qDebug() << local << relative;
  return "media/thumbnails/" + relative + ".jpg";
}

static QString mediaUri(GESTimelineObject *obj) {
  gchar * uri;
  g_object_get(G_OBJECT(obj), "uri", &uri, NULL);
  QString quri(uri);
  g_free (uri);
  return quri;
}

QString Timeline::
timeToString(double dTime)
{
  guint64 time = (guint64) dTime;
  gchar buffer[30];
  g_snprintf(buffer, sizeof(buffer), "%u:%02u:%02u.%09u",
    GST_TIME_ARGS(time));
  return QString(buffer);
}

QVariant Timeline::
data(const QModelIndex &index, int role) const
{
  GESTimelineObject * object;
  object = ges_simple_timeline_layer_nth(layer, index.row());

  if (!object)
  {
    return QVariant::fromValue(QString("Invalid index"));
  }

  switch (role)
  {
    case thumb_uri_role:
      return thumbForObject(object);
    case media_uri_role:
      return mediaUri(object);
    case duration_role:
      return QVariant::fromValue((double) GES_TIMELINE_OBJECT_DURATION(object));
    case inpoint_role:
      return QVariant::fromValue((double) GES_TIMELINE_OBJECT_INPOINT(object));
    case outpoint_role:
      return QVariant::fromValue((double) GES_TIMELINE_OBJECT_INPOINT(object) +
				 GES_TIMELINE_OBJECT_DURATION(object));
    case duration_only_role:
      gboolean is_image;
      g_object_get (G_OBJECT(object),
		    "is-image", (gboolean *) &is_image, NULL);
      return QVariant::fromValue((bool) is_image);
      
    default:
      return QVariant::fromValue(QString("Invalid role " + role));
  };
}

void
timeline_object_notify_duration_cb(GESTimelineObject *obj,
  GParamSpec *param,
  Timeline * timeline)
{
  timeline->privDurationChanged(obj);
}


void Timeline::
privDurationChanged(GESTimelineObject *obj)
{
  qDebug() << GES_TIMELINE_OBJECT_DURATION (obj);

  gint index = ges_simple_timeline_layer_index(layer, obj);

  if (index == -1)
  {
    qDebug() << "houston, we have a problem";
    return;
  }

  emit dataChanged(createIndex(index, 0), createIndex(index + 1, 1));
}


bool Timeline::
canFetchMore(const QModelIndex &parent) const
{
  return false;
}


void
Timeline::fetchMore(const QModelIndex &parent)
{
}

/* functions and methods related to adding sources to the timeline */

static void
timeline_object_notify_is_image_cb(GESTimelineObject * obj,
  Timeline * timeline)
{
  gboolean image;
  g_object_get(G_OBJECT(obj), "is-image", &image, NULL);
  if (image)
    g_object_set(G_OBJECT(obj), "duration", (guint64) GST_SECOND, NULL);
}


void Timeline::
appendPath(QString path)
{
  QString url = QUrl::fromLocalFile(QDir(path).absolutePath()).toString();
  GESTimelineFileSource *src;
  src = ges_timeline_filesource_new (url.toUtf8().data());

  g_signal_connect(G_OBJECT(src),
    "notify::is-image",
    G_CALLBACK(timeline_object_notify_is_image_cb),
    this);

  ges_simple_timeline_layer_add_object (layer, GES_TIMELINE_OBJECT(src), -1);
}


void
layer_object_added_cb(GESTimelineLayer *layer,
  GESTimelineObject * obj,
  Timeline * timeline)
{
  timeline->privAddObject(obj);
}


void Timeline::
privAddObject(GESTimelineObject * obj)
{
  beginInsertRows(QModelIndex(), row_count, row_count);
  row_count++;
  endInsertRows();
  emit countChanged(row_count);
  g_signal_connect(G_OBJECT(obj),
    "notify::duration",
    G_CALLBACK(timeline_object_notify_duration_cb),
    this);
}

/* functions and methods related to removing objects from the timeline */

/* Note, this isn't quite right. I call beginRemoveRows() in remove(),
   because at that point we still know what the index is going to
   be. really we should wait until privRemoveObject, but by this time
   the object has been removed from the layer, so we can't work out
   what the index was. At some point this will be fixed in GES, and
   then we should fix it here too. */

void
layer_object_removed_cb(GESTimelineLayer * layer,
  GESTimelineObject * object,
  Timeline * timeline)
{
  timeline->privRemoveObject(object);
}


void Timeline::
privRemoveObject(GESTimelineObject * object)
{
  row_count--;
  endRemoveRows();
}


void Timeline::
remove(int index)
{
  GESTimelineObject * obj;
  if (!(obj = ges_simple_timeline_layer_nth(layer, index)))
    return;
   
  beginRemoveRows(QModelIndex(), index, index);
  ges_timeline_layer_remove_object(GES_TIMELINE_LAYER(layer), obj);
}

void Timeline::
setInPoint(int index, double pos)
{
  
  GESTimelineObject * obj;

  if (!(obj = ges_simple_timeline_layer_nth (layer, index))) {
    return;
  }

  guint64 curInPoint, curOutPoint, curDuration;
  guint64 newInPoint, newOutPoint, newDuration;

  g_object_get (G_OBJECT(obj),
		"duration", (guint64 *) &curDuration,
		"in-point", (guint64 *) &curInPoint, NULL);

  curOutPoint = curDuration + curInPoint;
  newInPoint = (guint64) pos;
  newOutPoint = curOutPoint;
  newDuration = newOutPoint - newInPoint;

  g_object_set (G_OBJECT(obj),
		"duration", (guint64) newDuration,
		"in-point", (guint64) newInPoint, NULL);
}

void Timeline::
setOutPoint(int index, double pos)
{
  GESTimelineObject * obj;

  if (!(obj = ges_simple_timeline_layer_nth (layer, index))) {
    return;
  }

  guint64 curInPoint, curOutPoint, curDuration;
  guint64 newInPoint, newOutPoint, newDuration;

  g_object_get (G_OBJECT(obj),
		"duration", (guint64 *) &curDuration,
		"in-point", (guint64 *) &curInPoint, NULL);

  curOutPoint = curDuration + curInPoint;
  newInPoint = curInPoint;
  newOutPoint = (guint64) pos;
  newDuration = newOutPoint - newInPoint;

  g_object_set (G_OBJECT(obj),
		"duration", (guint64) newDuration,
		"in-point", (guint64) newInPoint, NULL);

}

/* functions and methods related to re-ordering the timeline */

static void swap(int &a, int &b)
{
  int temp;
  temp = a;
  a = b;
  b = temp;
}


void Timeline::
move(int source, int dest, int n)
{
  GESTimelineObject *obj = ges_simple_timeline_layer_nth (layer, source);
  ges_simple_timeline_layer_move_object(layer, obj, dest);
}


void
layer_object_moved_cb(GESTimelineLayer *layer,
  GESTimelineObject * obj,
  gint old, gint new_,
  Timeline * timeline)
{
  timeline->privMoveObject(old, new_);
}


void Timeline::
privMoveObject(int source, int dest)
{
  QModelIndex parent;

  /* FIXME: currently ignoring the 'n' parameter */
  /* FIXME: there's something I don't understand about the API,
     because it seems to be impossible to increment an item's position
     by one. So if the destination is one greater than the source,
     swap dest and source. It seems to work fine.
  */

  if (dest == (source + 1))
  {
    swap(source, dest);
  }

  qDebug() << source << dest;
  if (!beginMoveRows(parent, source, source, parent, dest))
  {
    qDebug() << "early exit";
    return;
  }
  endMoveRows();
}

void Timeline::
setPipeline (Pipeline * pipeline)
{
    mPipeline = pipeline;
    pipeline->setSource (GST_ELEMENT(timeline));
}

Pipeline * Timeline::
pipeline ()
{
    return mPipeline;
}
