Steinbrenner Oracle App
=======================

- **Todo**
	- Update launch images
		- Include Oracle logo text
		- Make custom ones instead of Gimp'ed images
	- See below about stats
	- See below about WP plugin
		- and Drupal migration/plugin/framework
	- Dynamic type - about pages and content pages
	- Content display - show title like in Mail app
- **Stats ideas**
	- Start over with Drupal 7 website
	- Create module that adds 'app' content type w/ fields for icons, screenshots, price, App Store link, availability date, ...
	- Complementary iOS library that communicates with the server and uploads statistics
		- Sends iOS version, app version, device type, screen size, ... once per version
		- Records what version the server has and when that is different from the version on the device upload w/ old version and new version
		- Periodically send average session length
	- Module 'autoingests' from iTunes daily on cron
	- 'App Statistics' tab on app nodes with graphs and so on about the app
		- Show number of total users, number of users per version, number of users per device, number of users per iOS version, number of sales vs. number of installs
		- Predict lowest deployment target necessary (if only <1% of users are on 6, then there's no reason to support it)
	- iOS app client for viewing statistics
- **WordPress plugin ideas**
	- Exposes API for getting categories, posts and their content, pages and their content
	- More reliable, paginated way to get posts than Atom feed
	- API design notes in back of tech binder
	- Publish plugin and iOS library as FOSS
	- Future: take over website and migrate to Drupal? Then use Drupal iOS SDK
