#include "timeline.h"

enum roles
{
  uri,
  duration
};

/* declarations for C friend functions which handle GLib signals */

void layer_object_added_cb(GESTimelineLayer *,
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
  pipeline = ges_timeline_pipeline_new ();
  ges_timeline_pipeline_add_timeline(pipeline, timeline);
  ges_timeline_add_layer(timeline, GES_TIMELINE_LAYER(layer));

  g_signal_connect(G_OBJECT(layer), "object-added",
    G_CALLBACK(layer_object_added_cb), this);
  g_signal_connect(G_OBJECT(layer), "object-moved",
    G_CALLBACK(layer_object_moved_cb), this);

  QHash <int, QByteArray> rolenames;
  rolenames[uri] = "uri";
  rolenames[duration] = "duration";
  setRoleNames(rolenames);
  row_count = 0;

  thumbs["media/20100510_007.jpg"] = "media/thumbnails/20100510_007.png";
  thumbs["media/20100512_003.png"] = "media/thumbnails/20100512_003.png";
  thumbs["media/AVRO1036K.wmv"] = "media/thumbnails/AVRO1036K.png";
  thumbs["media/small-mvi_0009.avi"] = "media/thumbnails/small-mvi_0009.png";
}


Timeline::~Timeline()
{
  gst_object_unref(GST_OBJECT(timeline));
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
  QString relative = QDir::current().relativeFilePath(local);
  return thumbs[relative];
}


static QString timeToString(guint64 time)
{
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
    case uri:
      return thumbForObject(object);
    case duration:
      return timeToString(GES_TIMELINE_OBJECT_DURATION(object));
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
preview()
{
  ges_timeline_pipeline_set_mode(pipeline, TIMELINE_MODE_PREVIEW);
  gst_element_set_state(GST_ELEMENT(pipeline), GST_STATE_PLAYING);
}
