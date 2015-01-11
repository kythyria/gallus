#include "loginbrowserui.h"
#include <QApplication>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QUrl>
#include <QUrlQuery>
#include <QFile>
#include <iostream>

void writeStateJson(QUrl &lastUrl, LoginBrowserUi *bui)
{
	QUrlQuery params(lastUrl.fragment(QUrl::FullyDecoded));
	QJsonObject paramObj;

	typedef QPair<QString,QString> stringpair;
	foreach(stringpair param, params.queryItems())
	{
		paramObj.insert(param.first, param.second);
	}

	QJsonObject tokenObj;
	tokenObj.insert("initial", paramObj);

	QJsonObject stateObj;
	stateObj.insert("tokens", tokenObj);

	stateObj.insert("cookies", bui->cookieJson());

	QFile stateFile("state.json");
	if(!stateFile.open(QIODevice::WriteOnly))
	{
		qFatal("Could not open state.json");
	}
	QJsonDocument stateDoc(stateObj);
	stateFile.write(stateDoc.toJson());
}

int main(int argc, char *argv[])
{
	QApplication a(argc, argv);
	LoginBrowserUi w;
	w.show();

	int aresult = a.exec();

	foreach (QUrl thing, w.urls) {
		std::cout << thing.url().toStdString() << std::endl;
	}

	QUrl lasturl = w.urls.last();

	if(lasturl.url().startsWith(LoginBrowserUi::REDIRECT_URL))
	{
		writeStateJson(lasturl, &w);
		return aresult;
	}
	else
	{
		return 1;
	}
}
