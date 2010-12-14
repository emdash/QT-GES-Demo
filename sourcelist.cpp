#include "sourcelist.h"

SourceList::SourceList()
{
  QString path = QDir::homePath() + "/media/";
  dir.setPath(path);

  QStringList filenames;
  QStringList::const_iterator i;
  filenames = dir.entryList(QDir::Files | QDir::NoDotAndDotDot);
  for(i = filenames.constBegin(); i != filenames.constEnd(); ++i) {
    l << path + *i;
  }
}

QStringList SourceList::getFiles()
{
  return l;
}
