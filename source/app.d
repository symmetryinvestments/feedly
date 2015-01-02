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
import webapi.feedly;
import webapi.tokens;

/**

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

void testFeedly()
{
	auto feedly=FeedlyClient(myUser,"");
	feedly.setClientToken(myToken);
	/*
	{
		writefln("%s",feedly.getTopics());
		writefln("%s",feedly.getCategories());
		writefln("%s",feedly.getUserSubscriptions());
		writefln("%s",feedly.getTags());
		writefln("%s",feedly.getOPML());
		writefln("%s",feedly.searchFeeds("#python",-1,""));

	}*/
	writefln("%s",feedly.twitterSuggest2(["feedly","BillGates","@BillGates","@cnnbrk","cnnbrk","DoktorInflation"]));
	writefln("*finished");
}		

shared static this()
{
	testFeedly();
}
