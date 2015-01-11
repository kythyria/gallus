#include "loginbrowserui.h"
#include <QUrl>
#include <QUrlQuery>
#include <QCoreApplication>
#include <QNetworkAccessManager>
#include <QNetworkCookieJar>

#include "jsonwritingcookiejar.h"

QString LoginBrowserUi::WL_AUTHSTART = "https://login.live.com/oauth20_authorize.srf";
QString LoginBrowserUi::REDIRECT_URL = "https://login.live.com/oauth20_desktop.srf";
QString LoginBrowserUi::CLIENT_ID("00000000480BC46C");
QString LoginBrowserUi::INITIAL_SCOPE("service::skype.com::MBI_SSL");

LoginBrowserUi::LoginBrowserUi(QWidget *parent)
    : QMainWindow(parent)
{
	this->cookies = new JsonWritingCookieJar(this);

	QUrlQuery params;
	params.addQueryItem("client_id",CLIENT_ID);
	params.addQueryItem("scope", INITIAL_SCOPE);
	params.addQueryItem("response_type","token");
	params.addQueryItem("redirect_uri",REDIRECT_URL);
	params.addQueryItem("state","999");
	params.addQueryItem("locale","en");

	QUrl startUrl(WL_AUTHSTART);
	startUrl.setQuery(params);

	this->view = new QWebView(this);

	this->view->page()->networkAccessManager()->setCookieJar(cookies);

	this->setCentralWidget(view);

	connect(view, SIGNAL(urlChanged(QUrl)), this, SLOT(urlChanged(QUrl)));
	view->load(startUrl);
}

void LoginBrowserUi::urlChanged(QUrl url)
{
	this->urls.append(url);
	if(url.url().startsWith(REDIRECT_URL))
	{
		QCoreApplication::exit(0);
	}
}

QJsonArray LoginBrowserUi::cookieJson()
{
	return cookies->toJson();
}

LoginBrowserUi::~LoginBrowserUi()
{

}
