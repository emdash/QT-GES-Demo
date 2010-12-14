#include "timeline.h"

Timeline::Timeline(QObject *parent) : QAbstractListModel(parent)
{
  timeline = ges_timeline_new_audio_video();
}

Timeline::~Timeline()
{
  gst_object_unref(GST_OBJECT(timeline));
}

int Timeline::rowCount(const QModelIndex &parent) const
{
  return 1;
}

QVariant Timeline::data(const QModelIndex &index, int role) const
{
  return QVariant::fromValue(QString("media/thumbmails/20100510_007.png")); 
}

bool Timeline::canFetchMore(const QModelIndex &parent) const
{
  return false;
}

void Timeline::fetchMore(const QModelIndex &parent)
{
}
