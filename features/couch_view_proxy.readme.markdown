# CouchView::Map::Proxy

A proxy object that lets you lazily build CouchDB map queries.


## Creating a map proxy

To create a new map proxy, simply instantiate `CouchView::Map::Proxy` with the model to call on, and the map to call:
    
    proxy = CouchView::Map::Proxy.new Article, :by_id


## Adding CouchDB query parameters to the proxy

You can add CouchDB query parameters to your view proxy by calling their corresponding methods on the proxy. 

For example, suppose we'd like to limit the results of our query to 10 documents:

    proxy.limit(10)

This will return a new proxy that's just like the original proxy, except that it will also include a `limit=10` query string parameter when making a call to CouchDB.

If you'd rather update the existing proxy, instead of getting a new one, you can append a "!" onto the end:

    proxy.limit!(10)


## Modifying the map to call

You can modify the map to call by calling a method that doesn't correspond to a CouchDB view query parameter. 

For example, suppose our `Article` model responded to `by_label` and `by_label_published`:

    proxy = CouchView::Map::Proxy.new Article, :by_label

    proxy._map #==> :by_label

    proxy.published!

    proxy._map #==> :by_label_published

If you call several methods on your proxy that don't correspond to CouchDB query parameters, then the proxy will alpha-sort them to generate the view name to call:

    proxy = CouchView::Map::Proxy.new Article, :by_label

    proxy.published!.visible!.active!

    proxy._map #==> :by_label_active_published_visible


## Triggering the call

You can trigger a call on a map proxy by calling either the `.each` method or the `get!` method:

    proxy = CouchView::Map::Proxy.new Article, :by_label
    
    proxy.each {...} #==> executes "Article.by_label"
    proxy.get!       #==> executes "Article.by_label"
