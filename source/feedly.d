module webapi.feedly;

/***
	Feedly API Client for the D Programming Language - written 2014 Laeeth Isharc

	Pre-alpha stage.  Please report issues on GitHub.

		not yet implemented: Microsoft, Facebook

	struct FeedlyClient - methods

		this(string clientID,string clientSecret)
		void setSandbox(bool sandbox)
		void setClientID(string clientID)
		void setClientToken(string clientToken)
		void setClientSecret(string clientSecret)
		auto epochTime(DateTime dt)
		string getCodeURI(string callbackURI)
	    	string authenticateUser(string responseType, string redirectURI, string state)
		string getAccessToken(string redirectURI,string code,string state)
		string refreshAccessToken(string refreshToken)
		string revokeAccessToken(string revokeToken)
		string getCategories()
		string updateCategoryLabel(string category, string newlabel)
		string deleteCategory(string category)
		string getFeedMetadata(string feedID)
		string getFeedMetadata(string[] feedIDs)
		string linkDropbox(string redirectURI, string state)
		string unlinkDropbox()
		string linkEvernote(string redirectURI, string state)
		string unlinkEvernote()
		string getEvernoteBookList()
		string saveArticleEvernote(string notebookName, string[] tags, string entryID, string notebookType, string notebookGUID,
		string getEntry(string entryID)
		string getEntries(string[] entryIDs)
		string createEntry(string title, string content, bool contentLeftToRight, string summary, bool summaryLeftToRight, 
				string[]  enclosure,string[2][] alternate,DateTime crawled, DateTime published, DateTime updated)
		string saveArticleDropbox(string entryID)
		string getMixes(string streamID, int count, bool unreadOnly, int hours, DateTime newerThan, bool backFill, string locale)
		string getOPML()
		string postOPML(string opml)
		string getPreferences()
		string updatePreferences(string[string] preferences)
		string getProfile()
		string updateProfile(string email, string givenName, string familyName, string picture, bool gender, string locale, string twitter, string facebook)
		string searchStreamContent(string streamID, string query)
		string getUserSubscriptions()
		string subscribeFeed(string ID, string title, string[2][] categories)
		string updateSubscription(string ID, string title, string[2][] categories)
		string unsubscribeFeed(string ID)
	    	string getShortenedURL(string entryID)
	    	string getFeedIDs(string streamID, int count, string ranked, bool unreadOnly, DateTime newerThan, int continuation)
		string getFeedContent(string streamID, int count, string ranked, bool unreadOnly, DateTime newerThan, int continuation)
		string getFeedUnreadCounts(bool autorefresh, DateTime newerThan, string streamID)
		string getFeedUnreadCounts(bool autorefresh, string streamID)
		string markArticlesAsRead(string[] entryIDs)
		string markArticlesAsSaved(string[] entryIDs)
		string markArticlesAsUnsaved(string[] entryIDs)
		string getLatestRead(DateTime newerThan)
		string getLatestTaggedEntries(DateTime newerThan)
		string markArticlesAsUnread(string[] entryIDs)
		string markFeedAsRead(string feedID, string lastReadEntryID)
		string undoMarkFeedsAsRead(string[] feedIDs)
		string markCategoriesAsRead(string[] categoryIDs, string lastReadEntryID)
		string markCategoriesAsRead(string[] categoryIDs, DateTime asOf)
		string undoMarkCategoriesAsRead(string[] categoryIDs)
		string saveForLater(string[] entryIDs)
		string searchFeeds(string query, int count, string locale)
		string getTags()
		string addTag(string[] tags, string[] entryIDs)
		string changeTagLabel(string tag, string oldLabel, string newLabel)
		string unTagEntries(string[] tags, string[] entryIDs)
		string deleteTags(string[] tags)
		string getTopics()
		string addTopic(string topicID, string topicInterest)
		string updateTopic(string topicID, string topicInterest)
		string deleteTopic(string topicID)
		string twitterSuggest1()
		string twitterSuggest2(string[] twitterHandles)
		string twitterUnlink()
		string twitterLink(string redirectURI, string state)
	
*/

import std.stdio;
import std.conv;
import std.exception;
import std.string;
import std.file;
import std.exception;
import std.datetime;
import vibe.d;
import vibe.core.log;
import vibe.http.client;
import vibe.stream.operations;
import vibe.utils.dictionarylist;

struct FeedlyClient
{
 
        	enum baseURLCloud ="cloud.feedly.com";
        	enum baseURLSandbox="sandbox.feedly.com";
    	string baseURL=baseURLCloud;

 	string urlAuth="/v3/auth/auth";
 	string urlCategories="/v3/categories";
 	string urlDropbox="/v3/dropbox";
 	string urlEvernote="/v3/evernote";
 	string urlEntries="/v3/entries";
 	string urlFeeds="/v3/feeds";
 	string urlToken="/v3/auth/token";
	string urlMarkers="/v3/markers";
	string urlMixes="/v3/mixes";
	string urlOPML="/v3/opml";
	string urlPreferences="/v3/preferences";
	string urlProfile="/v3/profile";
	string urlSaveForLater="/v3/tags/user%2F";
	string urlSearchStream="/v3/search";
	string urlSearchFeeds="/v3/search/feeds";
	string urlStreams="/v3/streams";
	string urlShorten = "/v3/shorten/entries";
	string urlSubscriptions = "/v3/subscriptions";
	string urlTags="/v3/tags";
	string urlTopics="/v3/topics";

	string urlTwitterAuth="/v3/twitter/auth";
	string urlTwitterSuggest1="/v3/twitter/suggestions";
	string urlTwitterSuggest2="/v3/twitter/feeds/.mget";

	string clientID;
	string clientSecret;
	string clientToken;
	bool sandbox=false;

	this(string clientID,string clientSecret)
	{
		this.clientID=clientID;
		this.clientSecret=clientSecret;
	}

	void setSandbox(bool sandbox)
	{
		this.sandbox=sandbox;
		if (sandbox)
			baseURL=baseURLSandbox;
		else
			baseURL=baseURLCloud;
	}

	void setClientID(string clientID)
	{
		this.clientID=clientID;
	}
	void setClientToken(string clientToken)
	{
		this.clientToken=clientToken;
	}
	void setClientSecret(string clientSecret)
	{
		this.clientSecret=clientSecret;
	}

	
	auto epochTime(DateTime dt)
	{
		return SysTime(dt).toUnixTime();
	}

	string getCodeURI(string callbackURI)
	{
		return(format("%s?client_id=%s&redirect_uri=%s&scope=%s&response_type=%s",
			"https://" ~ urlAuth,this.clientID,callbackURI,"https://"~urlSubscriptions,"code"));
	}
	
    	string authenticateUser(string responseType, string redirectURI, string state)
	{
		string url="https://"~baseURL~urlAuth;
		auto jsonparam=Json.emptyObject;
		if (responseType.length==0)
			jsonparam.responseType="code";
		else
			jsonparam.responseType=responseType;
		jsonparam.clientID=this.clientID;
		jsonparam.redirectURI=redirectURI;
		jsonparam.state=state;
		jsonparam["scope"]=urlSubscriptions;

		string ret;
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				req.method = HTTPMethod.GET;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}
    
	string getAccessToken(string redirectURI,string code,string state)
	{
		string url="https://"~baseURL~urlToken;
		auto jsonparam=Json.emptyObject;
		jsonparam.client_id=this.clientID;
		jsonparam.client_secret=this.clientSecret;
		jsonparam.grant_type="authorization_code";
		jsonparam.redirect_uri=redirectURI;
		jsonparam.code=code;
		if (state.length>0)
			jsonparam.state=state;

		string ret;
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				req.method = HTTPMethod.POST;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}
    
        	// obtain a new access token by sending a refresh token to the feedly Authorization server
        	// return contents of a feed
	string refreshAccessToken(string refreshToken)
	{
		string url="https://"~baseURL~urlToken;
		auto jsonparam=Json.emptyObject;
		jsonparam.refresh_token=refreshToken;
		jsonparam.client_id=this.clientID;
		jsonparam.client_secret=this.clientSecret;
		jsonparam.grant_type="refresh_token";

		
		string ret;
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.POST;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}

	string revokeAccessToken(string revokeToken)
	{
		string url="https://"~baseURL~urlToken;
		auto jsonparam=Json.emptyObject;
		jsonparam.refresh_token=revokeToken;
		jsonparam.client_id=this.clientID;
		jsonparam.client_secret=this.clientSecret;
		jsonparam.grant_type="revoke_token";

		
		string ret;
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
 				req.method = HTTPMethod.POST;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}

	string getCategories()
	{
		string url="https://"~baseURL~urlCategories;
		
		string ret;
		auto jsonbody="";
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8";
				req.headers["Authorization"]="OAuth "~this.clientToken;
				req.method = HTTPMethod.GET;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}

	string updateCategoryLabel(string category, string newlabel)
	{
		string url="https://"~baseURL~urlCategories~"/"~category;
		auto jsonparam=Json.emptyObject;

		
		jsonparam.label=newlabel;
		string ret;
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.POST;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}

	string deleteCategory(string category)
	{
		string url="https://"~baseURL~urlCategories~"/"~category;
		auto jsonparam=Json.emptyObject;

		
		string ret;
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.DELETE;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}
	
	string getFeedMetadata(string feedID)
	{
		string url="https://"~baseURL~urlFeeds~"/"~feedID;
		auto jsonparam=Json.emptyObject;

		
		string ret;
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.POST;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}

	string getFeedMetadata(string[] feedIDs)
	{
		string url="https://"~baseURL~urlFeeds~"/.mget";
		auto jsonparam=serializeToJson(feedIDs);
		string ret;
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.POST;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}
	string linkDropbox(string redirectURI, string state)
	{
		string url="https://"~baseURL~urlDropbox ~ "/auth";
		auto jsonparam=Json.emptyObject;

		
		jsonparam.redirectUri=redirectURI;
		if (state.length>0)
			jsonparam.state=state;
		string ret;
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.GET;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}

	string unlinkDropbox()
	{
		string url="https://"~baseURL~urlDropbox ~ "/auth";
		auto jsonparam=Json.emptyObject;

		
		string ret;
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.DELETE;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}


	string linkEvernote(string redirectURI, string state)
	{
		string url="https://"~baseURL~urlEvernote ~ "/auth";
		auto jsonparam=Json.emptyObject;

		
		jsonparam.redirectUri=redirectURI;
		if (state.length>0)
			jsonparam.state=state;
		string ret;
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.GET;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}

	string unlinkEvernote()
	{
		string url="https://"~baseURL~urlEvernote ~ "/auth";
		auto jsonparam=Json.emptyObject;

		
		string ret;
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.DELETE;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}

	string getEvernoteBookList()
	{
		string url="https://"~baseURL~urlEvernote ~ "/notebooks";
		auto jsonparam=Json.emptyObject;

		
		string ret;
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.GET;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}

	string saveArticleEvernote(string notebookName, string[] tags, string entryID, string notebookType, string notebookGUID,
															string comment)
	{
		string url="https://"~baseURL~urlEvernote ~ "/note";
		auto jsonparam=Json.emptyObject;
		jsonparam.notebookName=notebookName;
		jsonparam.tags=serializeToJson(tags);
		jsonparam.entryID=entryID;
		jsonparam.notebookType=notebookType;
		jsonparam.notebookGUID=notebookGUID;
		jsonparam.comment=comment;
		
		
		string ret;
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.POST;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}
	

	string getEntry(string entryID)
	{
		string url="https://"~baseURL~urlEntries ~ "/"~entryID;
		auto jsonparam=Json.emptyObject;

		
		string ret;
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.GET;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}
	
	string getEntries(string[] entryIDs)
	{
		string url="https://"~baseURL~urlEntries ~ "/"~".mget";
		auto jsonparam=Json.emptyArray;
		jsonparam.appendArrayElement(serializeToJson(entryIDs));
		
		string ret;
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.POST;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}
	
	string createEntry(string title, string content, bool contentLeftToRight, string summary, bool summaryLeftToRight, 
			string[]  enclosure,string[2][] alternate,DateTime crawled, DateTime published, DateTime updated)
	{
		string url="https://"~baseURL~urlEntries;
		auto jsonparam=Json.emptyArray;
		jsonparam.title=title;
		auto jsonContent=Json.emptyObject;
		jsonContent.direction=contentLeftToRight?"ltr":"rtl";
		jsonparam.content=jsonContent;
		auto jsonparamSummary=Json.emptyObject;
		jsonparamSummary.direction=summaryLeftToRight?"ltr":"rtl";
		jsonparamSummary.content=summary;
		jsonparam.summary=jsonparamSummary;
		jsonparam.enclosure=serializeToJson(enclosure);
		jsonparam.alternate=serializeToJson(alternate);
		jsonparam.crawled=serializeToJson(epochTime(crawled));
		jsonparam.published=serializeToJson(epochTime(published));
		jsonparam.updated=serializeToJson(epochTime(updated));

		
		string ret;
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.POST;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}


	
	string saveArticleDropbox(string entryID)
	{
		string url="https://"~baseURL~urlDropbox ~ "/save";
		auto jsonparam=Json.emptyObject;
		jsonparam.entryID=entryID;

		
		string ret;
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.POST;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}
	string getMixes(string streamID, int count, bool unreadOnly, int hours, DateTime newerThan, bool backFill, string locale)
	{
		string url="https://"~baseURL~urlOPML~"/"~streamID~"/contents";
		auto jsonparam=Json.emptyObject;
		
		if (count>=0)
			jsonparam.count=count;
		jsonparam.unreadOnly=unreadOnly;
		if (hours>=0)
			jsonparam.hours=hours;
		jsonparam.backFill=backFill;
		jsonparam.newerThan=serializeToJson(epochTime(newerThan));
		if (locale.length>0)
			jsonparam.locale=locale;

		string ret;
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.GET;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}

	string getOPML()
	{
		string url="https://"~baseURL~urlOPML;
		string ret;
		auto jsonbody="";
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8";
				req.headers["Authorization"]="OAuth "~this.clientToken;
				req.method = HTTPMethod.GET;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}

	string postOPML(string opml)
	{
		string url="https://"~baseURL~urlOPML;
		string ret;
		requestHTTP(url,
			(scope req)
			{
				req.contentType="text/xml; charset=UTF8";
				req.method = HTTPMethod.POST;
				req.bodyWriter.write(opml);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}

	string getPreferences()
	{
		string url="https://"~baseURL~urlPreferences;
		auto jsonparam=Json.emptyObject;
		
		string ret;
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.GET;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}

	string updatePreferences(string[string] preferences)
	{
		string url="https://"~baseURL~urlPreferences;
		auto jsonparam=Json.emptyObject;
		
		foreach(preference;preferences.keys)
		{
			jsonparam.preferences=preferences[preference];
		}
		string ret;
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.POST;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}


	string getProfile()
	{
		string url="https://"~baseURL~urlProfile;
		auto jsonparam=Json.emptyObject;
		
		string ret;
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.GET;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}

	string updateProfile(string email, string givenName, string familyName, string picture, bool gender, string locale, string twitter, string facebook)
	{
		string url="https://"~baseURL~urlProfile;
		auto jsonparam=Json.emptyObject;
		
		
		if (email.length>0)
			jsonparam.email=email;
		if (givenName.length>0)
			jsonparam.givenName=givenName;
		if (familyName.length>0)
			jsonparam.familyName=familyName;
		if (picture.length>0)
			jsonparam.picture=picture;
		jsonparam.gender=gender;
		if (locale.length>0)
			jsonparam["locale"]=locale;
		if (twitter.length>0)
			jsonparam["twitter"]=twitter;
		if (facebook.length>0)
			jsonparam["facebook"]=facebook;

		string ret;
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.POST;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}



        	// return contents of a feed
	string searchStreamContent(string streamID, string query)
	{
		string url="https://"~baseURL~urlSearchStream ~streamID ~"/contents?query="~query;
		auto jsonparam=Json.emptyObject;
		
		string ret;
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.GET;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}

        	// return contents of a feed
	string getUserSubscriptions()
	{
		string url="https://"~baseURL~urlSubscriptions;
		auto jsonparam=Json.emptyObject;
		
		string ret;
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.GET;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}

	string subscribeFeed(string ID, string title, string[2][] categories)
	{
		string url="https://"~baseURL~urlSubscriptions;
		auto jsonparam=Json.emptyObject;
		
		if (title.length>0)
			jsonparam.title=title;
		jsonparam.id=ID;
		if (categories.length>0)
		{
			auto jsonCategories=Json.emptyArray;
			foreach(category;categories)
			{
				auto jsonCategory=Json.emptyObject;
				jsonCategory["id"]=serializeToJson(category[0]);
				jsonCategory["label"]=serializeToJson(category[1]);
				jsonCategories.appendArrayElement(jsonCategory);
			}
			jsonparam["categories"]=jsonCategories;
		}

		string ret;
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.POST;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}

	string updateSubscription(string ID, string title, string[2][] categories)
	{
		return subscribeFeed(ID,title,categories);
	}

	string unsubscribeFeed(string ID)
	{
		string url="https://"~baseURL~urlSubscriptions ~"/"~ID;
		auto jsonparam=Json.emptyObject;
		

		string ret;
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.DELETE;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}

    	string getShortenedURL(string entryID)
    	{
    		string url="https://"~baseURL~urlShorten~"/"~entryID;
		auto jsonparam=Json.emptyObject;
		
		string ret;
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.GET;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}

    	string getFeedIDs(string streamID, int count, string ranked, bool unreadOnly, DateTime newerThan, int continuation)
    	{
    		string url="https://"~baseURL~urlStreams~"/"~streamID~"/ids";
		auto jsonparam=Json.emptyObject;
		if (count>=0)
			jsonparam.count=serializeToJson(count);
		if (ranked.length>0)
			jsonparam.ranked=serializeToJson(ranked);
		jsonparam.newerThan=serializeToJson(epochTime(newerThan));
		jsonparam.unreadOnly=unreadOnly;
		if (continuation>0)
			jsonparam.continuation=continuation;

		
		string ret;
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.GET;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}

        	// return contents of a feed
    	
	string getFeedContent(string streamID, int count, string ranked, bool unreadOnly, DateTime newerThan, int continuation)
	{
		string url="https://"~baseURL~urlStreams~"/content";
		auto jsonparam=Json.emptyObject;
		jsonparam.streamID=streamID;
		if (count>=0)
			jsonparam.count=count;
		if (ranked.length>0)
			jsonparam.ranked=ranked;
		jsonparam.newerThan=serializeToJson(epochTime(newerThan));
		jsonparam.unreadOnly=unreadOnly;
		if (continuation>0)
			jsonparam.continuation=continuation;

		
		string ret;
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.GET;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}



	string getFeedUnreadCounts(bool autorefresh, DateTime newerThan, string streamID)
	{
		string url="https://"~baseURL~urlMarkers;
		auto jsonparam=Json.emptyObject;
		jsonparam.autorefresh=autorefresh;
		jsonparam.newerThan=serializeToJson(epochTime(newerThan));
		if (streamID.length>0)
			jsonparam.streamID=streamID;
		
		string ret;
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.GET;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}

	string getFeedUnreadCounts(bool autorefresh, string streamID)
	{
		string url="https://"~baseURL~urlMarkers;
		auto jsonparam=Json.emptyObject;
		jsonparam.autorefresh=autorefresh;
		if (streamID.length>0)
			jsonparam.streamID=streamID;
		
		string ret;
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.GET;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}

	// Mark one or multiple articles as read''

	string markArticlesAsRead(string[] entryIDs)
	{
		string url="https://"~baseURL~urlMarkers;
		auto jsonparam=Json.emptyObject;
		jsonparam.action=serializeToJson("markAsRead");
		jsonparam["type"]=serializeToJson("entries");
		jsonparam.Authorization=serializeToJson("OAuth "~clientToken);
		string ret;
		auto jsonIDs=Json.emptyArray;
		jsonparam.entryIds=serializeToJson(entryIDs);
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.POST;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}
    
	string markArticlesAsSaved(string[] entryIDs)
	{
		string url="https://"~baseURL~urlMarkers;
		auto jsonparam=Json.emptyObject;
		jsonparam.action="markAsSaved";
		jsonparam["type"]="entries";
		
		string ret;
		auto jsonIDs=Json.emptyArray;
		jsonparam.entryIds=serializeToJson(entryIDs);
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.POST;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}
	
	string markArticlesAsUnsaved(string[] entryIDs)
	{
		string url="https://"~baseURL~urlMarkers;
		auto jsonparam=Json.emptyObject;
		jsonparam.action="markAsUnsaved";
		jsonparam["type"]="entries";
		
		string ret;
		auto jsonIDs=Json.emptyArray;
		jsonparam.entryIds=serializeToJson(entryIDs);
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.POST;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}

	string getLatestRead(DateTime newerThan)
	{
		string url="https://"~baseURL~urlMarkers~"/reads";
		auto jsonparam=Json.emptyObject;
		jsonparam.newerThan=serializeToJson(epochTime(newerThan));
		
		string ret;
		auto jsonIDs=Json.emptyArray;
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.GET;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}

	string getLatestTaggedEntries(DateTime newerThan)
	{
		string url="https://"~baseURL~urlMarkers~"/tags";
		auto jsonparam=Json.emptyObject;
		jsonparam.newerThan=serializeToJson(epochTime(newerThan));
		
		string ret;
		auto jsonIDs=Json.emptyArray;

		jsonparam.entryIds=jsonIDs;
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.GET;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}
			

	string markArticlesAsUnread(string[] entryIDs)
	{
		string url="https://"~baseURL~urlMarkers;
		auto jsonparam=Json.emptyObject;
		jsonparam.action="keepUnread";
		jsonparam["type"]="entries";
		
		string ret;
		auto jsonIDs=Json.emptyArray;
		jsonparam.entryIds=serializeToJson(entryIDs);
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.POST;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}
    
	string markFeedAsRead(string feedID, string lastReadEntryID)
	{
		string url="https://"~baseURL~urlMarkers;
		auto jsonparam=Json.emptyObject;
		jsonparam.action="markAsRead";
		jsonparam["type"]="feeds";
		jsonparam.lastReadEntryID=lastReadEntryID;
		auto jsonFeed=Json.emptyArray;
		jsonFeed.appendArrayElement(serializeToJson(feedID));
		jsonparam.feedIds=jsonFeed;

		
		string ret;
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.POST;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}

	string undoMarkFeedsAsRead(string[] feedIDs)
	{
		string url="https://"~baseURL~urlMarkers;
		auto jsonparam=Json.emptyObject;
		jsonparam.action="undoMarkAsRead";
		jsonparam["type"]="feeds";
		jsonparam.feddIds=serializeToJson(feedIDs);
		
		string ret;
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.POST;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}

	string markCategoriesAsRead(string[] categoryIDs, string lastReadEntryID)
	{
		string url="https://"~baseURL~urlMarkers;
		auto jsonparam=Json.emptyObject;
		jsonparam.action="markAsRead";
		jsonparam["type"]="categories";
		jsonparam.lastReadEntryID=lastReadEntryID;
		jsonparam.categoryIds=serializeToJson(categoryIDs);
		
		string ret;
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.POST;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}

	string markCategoriesAsRead(string[] categoryIDs, DateTime asOf)
	{
		string url="https://"~baseURL~urlMarkers;
		auto jsonparam=Json.emptyObject;
		jsonparam.action="markAsRead";
		jsonparam["type"]="categories";
		jsonparam.asOf=serializeToJson(epochTime(asOf));
		jsonparam.categoryIds=serializeToJson(categoryIDs);
		
		string ret;
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.POST;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}

	string undoMarkCategoriesAsRead(string[] categoryIDs)
	{
		string url="https://"~baseURL~urlMarkers;
		auto jsonparam=Json.emptyObject;
		jsonparam.action="undoMarkAsRead";
		jsonparam["type"]="categories";
		auto jsonCategories=Json.emptyArray;
		jsonparam.categoryIds=serializeToJson(categoryIDs);
		
		string ret;
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.POST;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}
                

	string saveForLater(string[] entryIDs)
	{
		string url="https://"~baseURL~urlSaveForLater~this.clientID~"%2Ftag%2Fglobal.saved";
		auto jsonparam=Json.emptyObject;
		jsonparam.action="markAsSaved";
		jsonparam["type"]="entries";
		
		string ret;
		jsonparam.entryIds=serializeToJson(entryIDs);
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.POST;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}

	string searchFeeds(string query, int count, string locale)
	{
		string url="https://"~baseURL~urlSearchFeeds;
		auto jsonparam=Json.emptyObject;
		jsonparam.query=serializeToJsonString(query);
		if (count>=0)
			jsonparam.count=count;
		if (locale.length>0)
			jsonparam.locale=locale;
		
		string ret;
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8";
				req.headers["Authorization"]="OAuth "~this.clientToken;
				req.method = HTTPMethod.GET;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}

	string getTags()
	{
		string url="https://"~baseURL~urlTags;
		auto jsonparam=Json.emptyObject;
		
		string ret;

		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8";
				req.headers["Authorization"]="OAuth "~this.clientToken;
				req.method = HTTPMethod.GET;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}

	string addTag(string[] tags, string[] entryIDs)
	{
		string url="https://"~baseURL~urlTags~join(tags,",");
		auto jsonparam=Json.emptyObject;
		

		if (entryIDs.length<=1)
			jsonparam.entryID=serializeToJson(entryIDs[0]);
		else
		{
			jsonparam.entryIds=serializeToJson(entryIDs);
		}
		string ret;

		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.PUT;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}


	string changeTagLabel(string tag, string oldLabel, string newLabel)
	{
		string url="https://"~baseURL~urlTags~tag;
		auto jsonparam=Json.emptyObject;
		
		jsonparam[oldLabel]=newLabel;

		string ret;

		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.POST;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}
	

	string unTagEntries(string[] tags, string[] entryIDs)
	{
		string url="https://"~baseURL~urlTags~join(tags,",")~"/"~join(entryIDs,",");
		auto jsonparam=Json.emptyObject;
		

		string ret;

		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.DELETE;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}

	string deleteTags(string[] tags)
	{
		string url="https://"~baseURL~urlTags~join(tags,",");
		auto jsonparam=Json.emptyObject;
		

		string ret;

		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.DELETE;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}

	
	string getTopics()
	{
		string url="https://"~baseURL~urlTopics;
		auto jsonparam=Json.emptyObject;
		string ret;
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8";
				req.headers["Authorization"]="OAuth "~this.clientToken;
				req.method = HTTPMethod.GET;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}

	string addTopic(string topicID, string topicInterest)
	{
		string url="https://"~baseURL~urlTopics;
		auto jsonparam=Json.emptyObject;
		
		jsonparam.id=topicID;
		jsonparam.interest=topicInterest;
		string ret;

		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8";
				req.headers["Authorization"]="OAuth "~this.clientToken;
				req.method = HTTPMethod.POST;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}
	string updateTopic(string topicID, string topicInterest)
	{
		return addTopic(topicID,topicInterest);
	}

	string deleteTopic(string topicID)
	{
		string url="https://"~baseURL~urlTopics;
		auto jsonparam=Json.emptyObject;
		
		jsonparam.id=topicID;
		string ret;

		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.DELETE;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}

	string twitterSuggest1()
	{
		string url="https://"~baseURL~urlTwitterSuggest1;
		auto jsonparam=Json.emptyObject;
		string ret;

		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.GET;
				req.bodyWriter.write(jsonbody);
				req.headers["Authorization"]="OAuth "~this.clientToken;
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}

	string twitterSuggest2(string[] twitterHandles)
	{
		string url="https://"~baseURL~urlTwitterSuggest2;
		string ret;
		auto jsonparam=serializeToJson(twitterHandles);
		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8";
				req.headers["Authorization"]="OAuth "~this.clientToken;
				req.method = HTTPMethod.POST;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}

	string twitterUnlink()
	{
		string url="https://"~baseURL~urlTwitterAuth;
		string ret;
		auto jsonparam=Json.emptyObject;
		

		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.DELETE;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}

	string twitterLink(string redirectURI, string state)
	{
		string url="https://"~baseURL~urlTwitterAuth;
		string ret;
		auto jsonparam=Json.emptyObject;
		
		jsonparam.redirectUri=redirectURI;
		jsonparam.state=state;

		auto jsonbody=to!string(serializeToJsonString(jsonparam));
		requestHTTP(url,
			(scope req)
			{
				req.contentType="application/json; charset=UTF8"; req.headers["Authorization"]="OAuth "~this.clientToken;
				
				req.method = HTTPMethod.GET;
				req.bodyWriter.write(jsonbody);
			},
			(scope res)
			{
				ret~= to!string(res.bodyReader.readAllUTF8());
			}
		);
		return ret;
	}
}