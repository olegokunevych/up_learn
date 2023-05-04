# Task Assumptions

* Assuming the code will run on a server, I've decided to use Phoenix as the framework for the API.
* Floki and Finch dependencies let us make HTTP requests and parse HTML responses.
* The code is splitted into separate modules, `UpLearn.Crawler` is the main module, which is responsible for crawling the webpages. `UpLearn.Parsers.HTML` is responsible for parsing HTML responses and extracting links and images from it. It is possible to add more parsers for different types of responses, e.g. JSON, XML, etc.
* As we need to test HTTP requests, it make sense to use `mock` in tests.
* Assuming web request can return other than 200 status, I've decided to return error tuple in this case.
* When parsing sites, I've found out that external links starts from http/https, however internal links starts from `/`. So I've decided to use this rule to distinguish between internal and external links. It might be not the best solution, but it works for now.

# TODO

* In order not to hit 3rd party services with tons of requests for the same url, we might want to use caching. For caching purposes, ETS is ideal candidate to be used. for production environment, I would use Nebulex library, which is battle tested solution.
* function `UpLearn.Crawler.fetch/1` could be wrapped into GenServer to handle the caching logic, since it's a simple and straightforward way to handle the cache.
* `UpLearn.Crawler.fetch/1` could be added to REST or WS API, so that it can be called outside.
* To handle errors GenServer should be running within the supervision tree. In case we want to crawl internet deeply, we might want to use DynamicSupervisor to spawn GenServer for each request and process recursively all the links.
* I haven't added explicit tests for `UpLearn.Parsers.HTML` module, since it's covered by `UpLearn.CrawlerTest` tests. However, it might be a good idea to add them in case we want to test it separately.
* Another testing approach is to use mock server, which will return different responses for different requests. This way we can test different scenarios. However, it might be an overkill for this task.
