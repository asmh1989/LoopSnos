#ifndef FILEIO_H
#define FILEIO_H

#include <QObject>
#include <QUrl>
class FileIO : public QObject
{
    Q_OBJECT

public:
    Q_PROPERTY(QString source
                   READ source
                       WRITE setSource
                           NOTIFY sourceChanged)

    Q_PROPERTY(QList<QStringList> result
                   READ result
                   NOTIFY resultChanged
               )

    Q_PROPERTY(QList<QStringList> data
                   READ data
                   NOTIFY dataChanged
               )

    explicit FileIO(QObject *parent = 0);

    Q_INVOKABLE QString read();
    Q_INVOKABLE bool write(const QString& data);
    Q_INVOKABLE int getNumberOfLines();

    Q_INVOKABLE QString saveToCsv(const QString &filePath, const QStringList &headers, const QList<QStringList> &data);

    Q_INVOKABLE void readCsv(const QString &filePath);
    Q_INVOKABLE QString selectFile(const QUrl &url);

    QString source() { return mSource; }
    QList<QStringList> data() {return mData;}
    QList<QStringList> result() {return mResult;}

    void readCsvFile(const QString &filePath, QList<QStringList> &csvData);

public slots:
    void setSource(const QString& source) { mSource = source; }

signals:
    void sourceChanged(const QString& source);
    void error(const QString& msg);
    void resultChanged();
    void dataChanged();

private:
    QString mSource;
    QList<QStringList> mResult;
    QList<QStringList> mData;
};



#endif // FILEIO_H
