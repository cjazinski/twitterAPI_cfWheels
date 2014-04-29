/**
* Twitter v0.1a
* Author: Christopher Jazinski
* Description: This plugin requires that we set some variables in our settings file
* Please see the plugin help for more information about needed variabls. This plugin
* will let us easily query the twitter API. You must provide an application/user token
* in order to be granted the needed bearer token. See dev.twitter.com for more information.
* This is basically just making a bunch of http calls to the service with the needed
* headers and parameters.
* Updated: 04-29-2014
* @mixin controller
* @output false
*/
component {
	public any function init() {
		this.version = '1.1.8';
		return this;
	}

	public any function TwitterGetSearch(string search = '##UTRGV', number count = 5) {
		var loc = {};
		var h = new http();
		var key = $getBearerToken();
		var data = '';
		h.setMethod('GET');
		h.setURL('https://api.twitter.com/1.1/search/tweets.json');
		h.addParam(type="header", name="Content-Type", value="application/x-www-form-urlencoded;charset=UTF-8");
		h.addParam(type="header", name="Authorization", value=key);
		h.addParam(type="formField", name="q", value=arguments.search);
		h.addParam(type="formField", name="count", value=arguments.count);
		data = DeserializeJSON(h.send().getPrefix().filecontent);
		loc['data'] = data.statuses;
		if (structKeyExists(data, "errors"))
			loc['status'] = 500;
		else 
			loc['status'] = 200;
		return loc;
	}

	public any function TwitterGetResourceLimits() {
		var loc = {};
		var h = new http();
		var key = $getBearerToken();
		var data = '';
		h.setMethod('GET');
		h.setURL('https://api.twitter.com/1.1/application/rate_limit_status.json');
		h.addParam(type="header", name="Content-Type", value="application/x-www-form-urlencoded;charset=UTF-8");
		h.addParam(type="header", name="Authorization", value=key);
		data = DeserializeJSON(h.send().getPrefix().filecontent);
		if (structKeyExists(data, "resources"))
			loc['data'] = data.resources;
		else
			loc['data'] = data;
		if (structKeyExists(loc.data, 'errors'))
			loc['status'] = 500;
		else
			loc['status'] = 200;
		return loc;
	}

	// Needed to get the bearerToken used in every request
	// to the twitterAPI. 
	public any function $getBearerToken() {
		var loc = {};
		var h = new http();
		$TwitterConfig();
		loc.consumerKey = get('Twitter_apiKey') & ':' & get('Twitter_apiSecret');
		loc.consumerKey = 'Basic ' & toBase64(loc.consumerKey,'utf-8');
		h.setMethod('POST');
		h.setURL('https://api.twitter.com/oauth2/token');
		h.addParam(type="header", name="Content-Type", value="application/x-www-form-urlencoded;charset=UTF-8");
		h.addParam(type="header", name="Authorization", value=loc.consumerKey);
		h.addParam(type="formField", name="grant_type", value="client_credentials");
		loc.return = h.send().getPrefix().filecontent;
		loc.return = DeserializeJSON(loc.return);
		if (structKeyExists(loc.return, 'access_token'))
			return 'Bearer ' & loc.return.access_token;
		else
			return -1;
	}

	public any function $TwitterConfig() {
		try {
			get('Twitter_apiKey');
		}
		catch (any e) {
			flashInsert(error:'Twitter_apiKey is not defined in settings');
			redirectTo(action:'index');
		}
		try {
			get('Twitter_apiSecret');
		}
		catch (any e) {
			flashInsert(error:'Twitter_apiSecret is not defined in settings');
			redirectTo(action:'index');
		}

	}
	
		
}