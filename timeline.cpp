#include "timeline.h"

enum roles {
  uri,
  duration
};

void
layer_object_added_cb(GESTimelineLayer *layer, GESTimelineObject * obj, Timeline * timeline)
{
  timeline->privAddObject(obj);
}

Timeline::Timeline(QObject *parent) : QAbstractListModel(parent)
{
  timeline = ges_timeline_new_audio_video();
  layer = ges_simple_timeline_layer_new();
  ges_timeline_add_layer(timeline, GES_TIMELINE_LAYER(layer));

  g_signal_connect(G_OBJECT(layer), "object-added", G_CALLBACK(layer_object_added_cb), this);
  
  QHash <int, QByteArray> rolenames;
  rolenames[uri] = "uri";
  rolenames[duration] = "duration";
  setRoleNames(rolenames);
  row_count = 0;
}

Timeline::~Timeline()
{
  gst_object_unref(GST_OBJECT(timeline));
}

int Timeline::rowCount(const QModelIndex &parent) const
{
  return row_count;
}

int Timeline::count()
{
  return row_count;
}

QVariant Timeline::data(const QModelIndex &index, int role) const
{
  switch (role) {
  case uri:
    return QVariant::fromValue(QString("media/thumbnails/20100510_007.png"));
  case duration:
    return QVariant::fromValue(0);
  };
}

bool Timeline::canFetchMore(const QModelIndex &parent) const
{
  return false;
}

void Timeline::fetchMore(const QModelIndex &parent)
{
}

void Timeline::append(QString uri)
{
  QByteArray foo = uri.toUtf8();
  GESTimelineFileSource *src = ges_timeline_filesource_new (foo.data());
  ges_simple_timeline_layer_add_object (layer, GES_TIMELINE_OBJECT(src), -1);
}

void Timeline::privAddObject(GESTimelineObject * obj)
{
  beginInsertRows(QModelIndex(), row_count, row_count);
  row_count++;
  endInsertRows();
  emit countChanged(row_count);
}

static void swap(int &a, int &b)
{
  int temp;
  temp = a;
  a = b;
  b = temp;
}

void Timeline::move(int source, int dest, int n)
{
  QModelIndex parent;

  /* FIXME: currently ignoring the 'n' parameter */
  /* FIXME: there's something I don't understand about the API,
     because it seems to be impossible to increment an item's position
     by one. So if the destination is one greater than the source,
     swap dest and source. It seems to work fine.
  */
  if (dest == (source + 1)) {
    swap(source, dest);
  }
  

  qDebug() << source << dest;
  if (!beginMoveRows(parent, source, source, parent, dest)) {
    qDebug() << "early exit";
    return;
  }
  endMoveRows();
}
