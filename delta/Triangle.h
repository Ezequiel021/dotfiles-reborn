#ifndef TRIANGLE_H
#define TRIANGLE_H

#include <QQuickPaintedItem>

class Triangle : public QQuickPaintedItem
{
    // QOBJECT
    Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged FINAL);
    Q_PROPERTY(double radius READ radius WRITE setRadius NOTIFY radiusChanged FINAL);

public:
    Triangle();

    void paint(QPainter* painter) override;

    QColor color() const;
    void setColor(QColor color);

    double radius() const;
    void setRadius(double radius);

signals:
    void colorChanged();
    void radiusChanged();

private:
    QColor m_color;
    double m_radius = 12;
};

#endif
