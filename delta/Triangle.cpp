#include "Triangle.h"
#include <QPainter>
#include <QPainterPath>
#include <QDebug>
#include <QtMath>

Triangle::Triangle()
{
    setAntialiasing(true);
}

void Triangle::paint(QPainter* painter)
{
    QPainterPath path;
    const double w = width();
    const double h = height();

    path.arcTo()
}