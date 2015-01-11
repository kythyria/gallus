#ifndef JSONWRITINGCOOKIEJAR_H
#define JSONWRITINGCOOKIEJAR_H
#include <QNetworkCookieJar>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>


class JsonWritingCookieJar : public QNetworkCookieJar
{
public:
	JsonWritingCookieJar(QObject *parent = 0);
	~JsonWritingCookieJar();

	QJsonArray toJson();
};

#endif // JSONWRITINGCOOKIEJAR_H
