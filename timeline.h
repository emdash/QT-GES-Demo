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
  Q_INVOKABLE void append(QString uri);
  Q_INVOKABLE void move(int source, int dest, int n);

 signals:
  void countChanged(int count);
  
 public slots:

 protected:
  bool canFetchMore(const QModelIndex &parent) const;
  void fetchMore(const QModelIndex &parent);
  
 private:
  void privAddObject(GESTimelineObject *);
  GESTimeline *timeline;
  GESSimpleTimelineLayer *layer;
  int row_count;
  friend void layer_object_added_cb (GESTimelineLayer *, GESTimelineObject *, Timeline *);
};

#endif
