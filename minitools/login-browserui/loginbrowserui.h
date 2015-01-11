#ifndef LOGINBROWSERUI_H
#define LOGINBROWSERUI_H

#include <QMainWindow>
#include <QWebView>
#include <QNetworkCookie>

class JsonWritingCookieJar;

class LoginBrowserUi : public QMainWindow
{
	Q_OBJECT
	QWebView *view;
	JsonWritingCookieJar *cookies;

private slots:
	void urlChanged(QUrl url);

public:
	static QString WL_AUTHSTART;
	static QString REDIRECT_URL;
	static QString CLIENT_ID;
	static QString INITIAL_SCOPE;

	QList<QUrl> urls;

	QJsonArray cookieJson();

	LoginBrowserUi(QWidget *parent = 0);
	~LoginBrowserUi();
};

#endif // LOGINBROWSERUI_H
