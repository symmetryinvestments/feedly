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


/* Token

	Your user id is a878553f-e3a3-491d-92f2-c3bf57cec7fb
	Your access token: AnvhQeF7ImEiOiJGZWVkbHkgRGV2ZWxvcGVyIiwiZSI6MTQyODAwNzUwMTY0MSwiaSI6ImE4Nzg1NTNmLWUzYTMtNDkxZC05MmYyLWMzYmY1N2NlYzdmYiIsInAiOjYsInQiOjEsInYiOiJwcm9kdWN0aW9uIiwidyI6IjIwMTMuMjMiLCJ4IjoicHJvIn0:feedlydev
	Your token expires on 2015-04-02
*/

void testFeedly()
{
	//auto feedly=FeedlyClient("sandbox","9ZUHFZ9N2ZQ0XM5ERU1Z");
	//feedly.setSandbox(true);
	//writefln("%s",feedly.authenticateUser("","http://localhost",""));
	//auto feedly=FeedlyClient("sandbox","9ZUHFZ9N2ZQ0XM5ERU1Z");

	auto feedly=FeedlyClient("a878553f-e3a3-491d-92f2-c3bf57cec7fb","");
	feedly.setClientToken("AnvhQeF7ImEiOiJGZWVkbHkgRGV2ZWxvcGVyIiwiZSI6MTQyODAwNzUwMTY0MSwiaSI6ImE4Nzg1NTNmLWUzYTMtNDkxZC05MmYyLWMzYmY1N2NlYzdmYiIsInAiOjYsInQiOjEsInYiOiJwcm9kdWN0aW9uIiwidyI6IjIwMTMuMjMiLCJ4IjoicHJvIn0:feedlydev");
	//writefln("%s",feedly.getTopics());
	//writefln("%s",feedly.getCategories());
	//writefln("%s",feedly.getUserSubscriptions());
	writefln("%s",feedly.getTags());
	//writefln("%s",feedly.searchFeeds("#python",-1,""));
	writefln("*finished");
}		

shared static this()
{
	testFeedly();
}
