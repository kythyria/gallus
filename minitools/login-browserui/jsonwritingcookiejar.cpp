#include "jsonwritingcookiejar.h"
#include <QNetworkCookie>
#include <QDateTime>

JsonWritingCookieJar::JsonWritingCookieJar(QObject *parent) : QNetworkCookieJar(parent)
{

}

QJsonArray JsonWritingCookieJar::toJson()
{
	QJsonArray out;
	foreach(QNetworkCookie i, this->allCookies())
	{
		QJsonObject cookie;
		cookie.insert("domain",i.domain());
		cookie.insert("path", i.path());
		QDateTime ed = i.expirationDate();
		cookie.insert("expirationDate", ed.toString(Qt::ISODate));
		if(i.isHttpOnly())
		{
			cookie.insert("httpOnly",QJsonValue(true));
		}
		if(i.isSecure())
		{
			cookie.insert("secure", QJsonValue(true));
		}
		cookie.insert("name",QString(i.name()));
		cookie.insert("value", QString(i.value()));
		out.append(cookie);
	}
	return out;
}

JsonWritingCookieJar::~JsonWritingCookieJar()
{

}

