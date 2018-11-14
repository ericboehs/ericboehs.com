---
title: Test if memcache is running and accessible
date: 2014-02-03
---

I've been writing a Rails template for our future projects at [Brightbit](http://brightbit.com) and I've been testing everything, including our application's environment. I've wrote a special rake task to test our different environments (development, test, staging, production, etc). This helps us ensure each environment is configured correctly. Ideally it would let the person running the tests know what is wrong with their environment and how to resolve it.

One of the environment details I wanted to test was that memcache was setup and running correctly. I could of course test for the memcached binary or check if it was running, but since we are running these tests in the context of a Rails app, why not just ask Rails if it can connect to the memcache server?

READMORE

There's a multitude of ways to test for this. We don't have memcache setup in our test environment's config file, so I'll have to ask Rails to lookup a memcache store.  Also, I wanted to have something that would give a true/false rather than raise an exception (such as `Rails.cache.read 'some-made-up-key'`). After poking around a bit, I found that `Rails.cache.stats` would always return something if memcache was up but have nil values in its result hash if it was down.

So, if you just want to check in your console, you can run:

```ruby
Rails.cache.stats.values.include? nil
```

But since we're writing a test which doesn't have memcache configured, we'll need to ask `ActiveSupport` to lookup a mem cache store:

```ruby
ActiveSupport::Cache.lookup_store(:mem_cache_store).stats.values.include? nil
```

So there ya go: quick and simple.
