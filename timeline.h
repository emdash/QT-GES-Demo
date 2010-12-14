#ifndef __TIMELINE_H__
#define __TIMELINE_H__

#include <QObject>
#include <QtCore>

#define GST_USE_UNSTABLE_API
#include <ges/ges.h>

class Timeline : public QAbstractListModel {
  Q_OBJECT

    
 public:
  Timeline(QObject *parent = 0);
  ~Timeline();
  int rowCount(const QModelIndex &parent = QModelIndex()) const;
  QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;

 signals:
  void numberPopulated(int number);
  
 public slots:

 protected:
  bool canFetchMore(const QModelIndex &parent) const;
  void fetchMore(const QModelIndex &parent);
  
 private:
  GESTimeline *timeline;
};

#endif
