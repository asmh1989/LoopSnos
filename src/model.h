#ifndef MODEL_H
#define MODEL_H

#include <QObject>
#include <QString>
#include <QGlobalStatic>
#include <QJsonObject>

Q_GLOBAL_STATIC(const QString, globalReadOnlyKey, "1234567890abcdef");

struct SerialData {
    QString addr;
    QString code;
    QString data;
    QString name;
    QString quantity="";
    QString time="";
    bool circle = false;

    // 赋值操作符重载函数，实现深度拷贝
    SerialData& operator=(const SerialData& other) {
        if (this != &other) { // 避免自赋值
            addr = other.addr;
            code = other.code;
            data = other.data;
            name = other.name;
            quantity = other.quantity;
            time = other.time;
            circle = other.circle;
        }
        return *this;
    }

    // 定义比较操作符
    bool operator==(const SerialData& other) const {
        return addr == other.addr &&
               code == other.code &&
               data == other.data &&
               name == other.name &&
               quantity == other.quantity &&
               time == other.time &&
               circle == other.circle;
    }

    bool operator!=(const SerialData& other) const {
        return !(*this == other);
    }

    QJsonObject toJson() const {
        QJsonObject obj;
        obj["addr"] = addr;
        obj["code"] = code;
        obj["data"] = data;
        obj["name"] = name;
        //        obj["quantity"] = quantity;
        //        obj["time"] = time;
        obj["circle"] = circle;
        return obj;
    }

    static SerialData fromJson(const QJsonObject &obj) {
        SerialData data;
        if (obj.contains("addr") && obj["addr"].isString()) {
            data.addr = obj["addr"].toString();
        } else {
            data.addr ="30";
        }

        if (obj.contains("code") && obj["code"].isString()) {
            data.code = obj["code"].toString();
        } else {
            data.code = "05";
        }

        if (obj.contains("data") && obj["data"].isString()) {
            data.data = obj["data"].toString();
        } else {
            data.data = "20010001 0001 12";
        }

        if (obj.contains("name") && obj["name"].isString()) {
            data.name = obj["name"].toString();
        } else {
            data.name = "【获取电源数据】";
        }
        //        data.quantity = obj["quantity"].toString();
        //        data.time = obj["time"].toString();
        //        data.circle = obj["circle"].toBool();
        return data;
    }
};
#endif // MODEL_H
