#ifndef LOGINBROWSERUI_H
#define LOGINBROWSERUI_H

#include <QMainWindow>
#include <QWebView>

class LoginBrowserUi : public QMainWindow
{
	Q_OBJECT
	QWebView *view;

private slots:
	void urlChanged(QUrl url);

public:
	static QString WL_AUTHSTART;
	static QString REDIRECT_URL;
	static QString CLIENT_ID;
	static QString INITIAL_SCOPE;

	QList<QUrl> urls;

	LoginBrowserUi(QWidget *parent = 0);
	~LoginBrowserUi();
};

#endif // LOGINBROWSERUI_H
