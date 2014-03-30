package app.controller;

import app.api.DownloadApi;
import app.api.SiteApi;
import app.Config;
import ufront.web.Controller;
import ufront.web.Dispatch;
import ufront.web.result.FilePathResult;
import ufront.web.result.ViewResult;
import ufront.view.TemplateData;
using Strings;
using tink.CoreApi;
using haxe.io.Path;

class DownloadController extends Controller {
	
	@inject("contentDirectory") public var contentDir:String;
	@inject public var apiDownload:DownloadApi;
	@inject public var apiSite:SiteApi;

	static inline function versionRepo() return Config.app.siteContent.folder+'/'+Config.app.siteContent.versions.folder;

	@:route("")
	public function doDefault(  ) {
		var currentVersion = apiSite.getCurrentVersion( versionRepo() );
		return doVersion( currentVersion );
	}

	@:route("list/")
	public function doList() {
		var result = apiDownload.getDownloadList( context.request.scriptDirectory+versionRepo() );
		var versions = result.versions;
		versions.reverse();
		return ViewResult.create({
			title: 'Haxe Download List', 
			topNav: '/download/',
			tagBaseUrl: Config.app.siteContent.versions.tagBaseUrl,
			editLink: Config.app.siteContent.versions.versionsBaseUrl,
			versions: versions,
			currentViewion: result.current
		});
	}

	@:route("version/$version")
	public function doVersion( version:String ) {
		var result = apiDownload.getDownloadVersion( contentDir+versionRepo(), version );
		return ViewResult.create({
			title: 'Haxe $version',
			topNav: '/download/',
			tagBaseUrl: Config.app.siteContent.versions.tagBaseUrl,
			compareBaseUrl: Config.app.siteContent.versions.compareBaseUrl,
			editLink: Config.app.siteContent.versions.versionsBaseUrl + version.replace(".",",") + '/'
		}).setVars( result );
	}

	@:route("file/$version/$file")
	public function doFile( version:String, file:String ) {
		version = version.replace( '.', ',' );
		var scriptDir = context.request.scriptDirectory;
		return new FilePathResult( scriptDir+versionRepo()+'/$version/downloads/$file', null, file );
	}
}