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

#ifndef __TIMELINE_H__
#define __TIMELINE_H__

#include <QObject>
#include <QtCore>

#define GST_USE_UNSTABLE_API
#include <ges/ges.h>

class Timeline : public QAbstractListModel {
  Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(bool playing READ playing NOTIFY playingChanged)

    
 public:
  Timeline(QObject *parent = 0);
  ~Timeline();
  int rowCount(const QModelIndex &parent = QModelIndex()) const;
  QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
  int count();
  bool playing();
  Q_INVOKABLE void appendPath(QString path);
  Q_INVOKABLE void move(int source, int dest, int n);
  Q_INVOKABLE void remove(int index);
  Q_INVOKABLE void preview();
  Q_INVOKABLE void pause();
  Q_INVOKABLE void stop();

 signals:
  void countChanged(int count);
  void playingChanged(bool isPlaying);
  
 public slots:

 protected:
  bool canFetchMore(const QModelIndex &parent) const;
  void fetchMore(const QModelIndex &parent);
  
 private:
  void privAddObject(GESTimelineObject *);
  void privDurationChanged(GESTimelineObject *);
  void privRemoveObject(GESTimelineObject *);
  void privMoveObject(gint source, gint dest);
  void privSetState(GstState state);
  QString thumbForObject(GESTimelineObject *) const;
  GESTimeline *timeline;
  GESSimpleTimelineLayer *layer;
  GstElement *pipeline;
  GstElement *vq;
  GstElement *aq;
  GstElement *vsnk;
  GstElement *asnk;
  GstElement *aconv;
  GstElement *csp;
  GstState m_state;
  int row_count;
  QHash<QString, QString> thumbs;
  friend void bus_message_cb (GstBus *, GstMessage *, Timeline *);
  friend void timeline_pad_added_cb (GESTimeline *, GstPad *, Timeline *);
  friend void layer_object_added_cb (GESTimelineLayer *, GESTimelineObject *, Timeline *);
  friend void layer_object_moved_cb (GESTimelineLayer *, GESTimelineObject *, gint, gint, Timeline *);
  friend void layer_object_removed_cb (GESTimelineLayer *, GESTimelineObject *, Timeline *);
  friend void timeline_object_notify_duration_cb (GESTimelineObject *, GParamSpec *, Timeline *);
};

#endif
