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

#define GST_USE_UNSTABLE_API

#include <ges/ges.h>
#include <QtCore>
#include <QtGui>
#include <QtDeclarative>
#include <QtOpenGL/QGLWidget>
#include "timeline.h"

#include <QtGstQmlSink/qmlvideosurfacegstsink.h>
#include <QtGstQmlSink/qmlgstvideoitem.h>

static void registerTypes () {
  qmlRegisterType<Timeline>("GES", 1, 0, "GESTimeline");
  qmlRegisterType<Pipeline>("GES", 1, 0, "GESTimelinePipeline");
  qmlRegisterType<QmlGstVideoItem> ("Gst", 1, 0, "GstVideoItem");
  qmlRegisterType<QmlPainterVideoSurface> ("Gst", 1, 0, "GstVideoSurface");
}

static void createGLSurface (QString qmlName, QDeclarativeView * view) {
  QmlPainterVideoSurface * timelineSurface = new QmlPainterVideoSurface;
  QGLWidget * g = (QGLWidget *) view->viewport();
  timelineSurface->setGLContext((QGLContext *) g->context());
  view->rootContext()->setContextProperty(qmlName, timelineSurface);
}

int main(int argc, char **argv)
{
  QApplication app(argc, argv);
  gst_init(&argc, &argv);
  ges_init();

  registerTypes();

  QDeclarativeView view;
  QGLWidget *g = new QGLWidget;
  
  view.setViewport(g);

  createGLSurface("timelineSurface", &view);
  createGLSurface("inPointSurface", &view);
  createGLSurface("outPointSurface", &view);

  view.setSource(QUrl::fromLocalFile("Timeline.qml"));
  view.setResizeMode(QDeclarativeView::SizeRootObjectToView);
  view.resize(640, 480);
  view.show();

  if (!QDir::current().exists("media")) {
      qDebug () << "Media files missing. Download them by running './download.sh'";
      return -1;
  }

  QObject::connect((QObject*)view.engine(), SIGNAL(quit()), &app, SLOT(quit()));
  
  return app.exec();
}
