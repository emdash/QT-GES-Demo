#ifndef __SOURCELIST_H__
#define __SOURCELIST_H__

#include <QObject>
#include <QDir>

class SourceList : public QObject
{
  Q_OBJECT
 public:
  
  SourceList();
  Q_INVOKABLE QStringList getFiles();
  
 private:
  QDir dir;
  QStringList l;
};

#endif
