#include "fileio.h"
#include <QFile>
#include <QTextStream>
#include <QDir>

FileIO::FileIO(QObject *parent) :
    QObject(parent)
{

}

QString FileIO::read()
{
    if (mSource.isEmpty()){
        emit error("source is empty");
        return QString();
    }

    QFile file(mSource);
    QString fileContent;
    if ( file.open(QIODevice::ReadOnly) ) {
        QString line;
        QTextStream t( &file );
        do {
            line = t.readLine();
            fileContent += line;
        } while (!line.isNull());

        file.close();
    } else {
        emit error("Unable to open the file");
        return QString();
    }
    return fileContent;
}

int FileIO::getNumberOfLines(){

    if (mSource.isEmpty()){
        emit error("source is empty");
        return -1;
    }

    QFile file(mSource);
    int numberOfLines=0;

    if ( file.open(QIODevice::ReadOnly) ) {
        QString line;
        QTextStream t( &file );
        do {
            line = t.readLine();
            numberOfLines++;
        } while (!line.isNull());

        file.close();
    } else {
        emit error("Unable to open the file");
        return -1;
    }
    return numberOfLines-1;
}

bool FileIO::write(const QString& data)
{
    if (mSource.isEmpty())
        return false;

    QFile file(mSource);

    //"append" allows adding a new line instead of rewriting the file
    if (!file.open(QFile::WriteOnly | QIODevice::Text | QFile::Append))
        return false;

    QTextStream out(&file);
    out << data <<"\n";
    file.close();

    return true;
}


QString FileIO::saveToCsv(const QString &filePath, const QStringList &headers, const QList<QStringList> &data) {

    QFile file(filePath);

    QFileInfo fileInfo(filePath);
    QDir dir(fileInfo.dir().absolutePath());
    if (!dir.exists()) {
        dir.mkpath(".");
    }

    if (file.open(QIODevice::WriteOnly | QIODevice::Append | QIODevice::Text)) {
        QTextStream stream(&file);
        stream.setEncoding(QStringConverter::Utf8);

        // 写入表头
        if (file.size() == 0) {
            for (auto i = 0; i < headers.size(); i++) {

                stream << headers[i];
                if(i != headers.size() - 1){
                    stream<< ",";
                }
            }
            stream << "\n";
        }

        // 写入数据
        for (const QStringList &row : data) {
            for (auto i = 0; i < row.size(); i++) {

                stream << row[i];
                if(i != row.size() - 1){
                    stream<< ",";
                }
            }
            stream << "\n";
        }

        file.close();
        return tr("文件已保存: %1").arg(fileInfo.absoluteFilePath());
    } else {
        return tr("文件写入错误: %1").arg(fileInfo.absoluteFilePath());
    }

}


void FileIO::readCsvFile(const QString &filePath, QList<QStringList> &csvData) {

    QFile file(filePath);
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&file);

        // 跳过头部（第一行）
        in.readLine();

        // 读取并解析CSV数据
        while (!in.atEnd()) {
            QString line = in.readLine();
            QStringList fields = line.split(',');

            // 添加数据到csvData
            csvData.append(fields);
        }

        file.close();
        qDebug() << "CSV file successfully read: " << filePath;
    } else {
        emit error(tr("错误, 文件不存在: %1").arg(filePath));
    }

}


void FileIO::readCsv(const QString &filePath) {
    QDir dir(filePath);
    if(dir.exists()) {
        mResult.clear();
        mData.clear();
        readCsvFile(dir.filePath("result.csv"), mResult);
        readCsvFile(dir.filePath("data.csv"), mData);
    } else {
        emit error(tr("该目录不存在: %1").arg(filePath));
    }
}

QString FileIO::selectFile(const QUrl &url){
    auto path = url.toLocalFile();
    QFileInfo info(path);
    auto path2= info.dir().absolutePath();
//    readCsv(path2);
    return path2;
}
