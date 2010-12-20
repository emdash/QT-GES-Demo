#ifndef __TIMELINE_H__
#define __TIMELINE_H__

#include <QObject>
#include <QtCore>

#define GST_USE_UNSTABLE_API
#include <ges/ges.h>

class Timeline : public QAbstractListModel {
  Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)

    
 public:
  Timeline(QObject *parent = 0);
  ~Timeline();
  int rowCount(const QModelIndex &parent = QModelIndex()) const;
  QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
  int count();
  Q_INVOKABLE void appendPath(QString path);
  Q_INVOKABLE void move(int source, int dest, int n);
  Q_INVOKABLE void remove(int index);
  Q_INVOKABLE void preview();
  Q_INVOKABLE void pause();
  Q_INVOKABLE void stop();

 signals:
  void countChanged(int count);
  
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
  GESTimelinePipeline *pipeline;
  GstState m_state;
  int row_count;
  QHash<QString, QString> thumbs;
  friend void bus_message_cb (GstBus *, GstMessage *, Timeline *);
  friend void layer_object_added_cb (GESTimelineLayer *, GESTimelineObject *, Timeline *);
  friend void layer_object_moved_cb (GESTimelineLayer *, GESTimelineObject *, gint, gint, Timeline *);
  friend void layer_object_removed_cb (GESTimelineLayer *, GESTimelineObject *, Timeline *);
  friend void timeline_object_notify_duration_cb (GESTimelineObject *, GParamSpec *, Timeline *);
};

#endif
