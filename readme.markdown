# CouchView

[![Build Status](https://secure.travis-ci.org/moonmaster9000/couch_view.png)](http://travis-ci.org/moonmaster9000/couch_view)

A decorator library for generating CouchDB view (map/reduce) functions for CouchRest::Model models. 

## Why?

CouchView makes your views modular, decouples them from your model, and also makes it easier to unit test them.

## Requirements?

This gem integrates with the `couchrest_model` gem (version ~> 1.0.0)

## Installation

Install it as a gem:

```sh
$ gem install couch_view
```

## Your first view

Let's imagine that we want to create a map on our model that includes all of the document labels (human-readable ids):

We can start by simply calling the "map" method on our model, passing in the :label property:

```ruby
class Article < CouchRest::Model::Base
  include CouchView
  
  property :label

  map :label
end
```

This will generate a javascript map function that looks like this:

```javascript
function(doc){
  if (doc['couchrest-type'] == 'Article')
    emit(doc.label, null)
}
```

We can query this map by using the "map_by_label!" method:

```ruby
Article.map_by_label! #==> all of the articles, in order of label
```

You can use any of the standard CouchDB query options on this view; see the section "Query Proxy" for more information.

We can also count all of the articles in the "by_label" map using the `count_by_label!` method:

```ruby
Article.count_by_label! #==> 0, assuming we haven't created any articles
```

Next, let's imagine that we'd like to create a view with a compound key: let's index all of the articles in the system by author and created_at:

```ruby
class Article < CouchRest::Model::Base
  include CouchView
  property :author
  timestamps!

  map :author, :created_at
end
```

And it's as simple as that. `CouchView` generated the following javascript map function:

```javascript
function(doc){
  if (doc['couchrest-type'] == 'Article')
    emit([doc.author, doc.created_at], null)
}
```

We can now iterate over the map using the `map_by_author_and_created_at!` method, and we can count it using the `count_by_author_and_created_at!` method.

## Complex views

But what if you need to create a more complex view? `CouchView` is your friend here. Let's imagine that we want to index all of the articles by the number of comments they've received.

We'll start by creating a map class:

```ruby
class ByCommentCount
  include CouchView::Map

  def map
    <<-JS
      function(doc){
        if (#{conditions})
          emit(doc.comments.length, null)
      }
    JS
  end
end
```

Notice that we call the "conditions" method inside of our map. This method is mixed into our class by the `CouchView::Map` module. You'll learn how this method allows us to decorate our views with conditions in the next section. For now, let's see what happens if we simply instantiate this class and call the "map" method on it:

```ruby
ByCommentCount.new.map #==> 
  "
    function(doc){
      emit(doc.comments.length, null)
    }
  "
```

Well that's not very interesting... However, what if we use this map in a model?

```ruby
class Article < CouchRest::Model::Base
  include CouchView
  property :comments, [String]
  map ByCommentCount
end
```

Now, CouchView will generate a map function on our Article design document that will look like this:

```javascript
function(doc){
  if (doc['couchrest-type'] == 'Article')
    emit(doc.comments.length, null)
}
```

Similar to before, we can query this index with `map_by_comment_count!` and `count_by_comment_count!`.


## Decorating maps with conditions

Next, let's imagine that sometimes we'd like to constrain our Article views to published articles, "web exclusive" articles, and a mixture of the two. Imagine our model was defined like this:

To start, let's define the following condition modules:

```ruby
module WebExclusive
  def conditions
    "#{super} && doc.web_exclusive == true"
  end
end

module Published
  def conditions
    "#{super} && doc.published == true"
  end
end
```

We can then add them into our map definitions thusly:

```ruby
class Article < CouchRest::Model::Base
  include CouchView

  property :label
  property :web_exclusive,  TrueClass, :default => false
  property :published,      TrueClass, :default => false

  map :label do
    conditions WebExclusive, Published
  end
end
```

Now, we can constrain our `map_by_label` query proxy to consider only web exlusive articles, published articles, or both:

```ruby
Article.map_by_label.published.get!               
  #==> published articles ordered by label

Article.map_by_label.web_exclusive.get!           
  #==> web exclusive articles ordered by label

Article.map_by_label.published.web_exclusive.get! 
  #==> published, web exclusive articles ordered by label
```

### Naming conditions

By default, the conditions were named after the module (i.e., "web_exclusive" for WebExclusive, "published" for Published).

In a real app, it's likely that you'll end up namespacing your condition modules, in which case, the autogenerated names for your modules won't work. 

Let's go back to our article example, and imagine that we namespaced our conditions under "Article::Conditions":

```ruby
class Article
  module Conditions
    module WebExclusive
      def conditions
        "#{super} && doc.web_exclusive == true"
      end
    end

    module Published
      def conditions
        "#{super} && doc.published == true"
      end
    end
  end
end
```

If we added these conditions to a map, the condition names would not be qualified.

If you'd prefer that they be qualified, you'll need to tell `couch_view` what to name them:

```ruby
class Article < CouchRest::Model::Base
  include CouchView

  property :label
  property :web_exclusive,  TrueClass, :default => false
  property :published,      TrueClass, :default => false

  map :label do
    conditions do
      filter_by_web_exclusive Conditions::WebExclusive
      filter_by_published     Conditions::Published
    end
  end
end
```

Now you can use these conditions on your proxy:

```ruby
Article.map_by_label.filter_by_web_exclusive.filter_by_published.each {...}
```

## Query Proxy

CouchView includes a simple query proxy system for building your map/reduce queries. 

Given the following model:

```ruby
class Article < CouchRest::Model::Base
  include CouchView
  map :label
end
```

When you call `map_by_label`, you'll recieve a proxy for the query you want to run:

```ruby
proxy = Article.map_by_label
```

You can now begin modifying your proxy with the standard CouchDB query options. For example, suppose we'd like to limit our result to 10. We can call either the `limit` method, or the `limit!` method. The former will return a new proxy, and leave the original untouched. The latter will modify the proxy it was called on.

```ruby
# generate a new proxy
new_proxy = proxy.limit 10

# or update the existing property
proxy.limit!(10)
```

Here's the full list of CouchDB query parameters that `CouchView` supports:

```ruby
limit       
skip           
key
startkey       
endkey         
startkey_docid 
endkey_docid   
stale          
descending     
group          
group_level    
reduce         
include_docs   
update_seq     
```

You can read about what each of these keys do here: http://wiki.apache.org/couchdb/HTTP_view_API

Your query will execute when you call `each` or `get!` on it:  

```ruby
Article.map_by_label.startkey!("a").endkey!("b").each do |articles|
  # do something with the articles
end

# or...

articles = Article.map_by_label.startkey!("a").endkey!("b").get!
```

You can also make your `map_by_label` and `count_by_label` return immediately by adding an `!` onto the end:

```ruby
Article.map_by_label!
  #==> [Article<#848283>,...]

Article.count_by_label!
  #==> 5
```

## Arbitrary Reduce

You can add any arbitrary reduce onto your view by using the `reduce` class method. Just make sure to group it with a map by placing them both within a `couch_view` block:

```ruby
class Article < CouchRest::Model::Base
  include CouchView

  property :label
  
  couch_view do
    map :label
    reduce <<-JS
      function(key, values){
        return sum(values)
      }
    JS
  end
end
```

And now you can call it with:
   
```ruby
Article.reduce_by_label.get!
```

Note that you can still call `map_by_label` as well. You can't, however, call `count_by_label`.


## Custom Names

As you've seen, `CouchView` will generate names for your views based on the properties being mapped (or based on the name of the `CouchView::Map` class passed to `map`).

You can override this default name by passing a name to the `couch_view` method:

```ruby
class Article < CouchRest::Model::Base
  include CouchView

  couch_view :over_label do
    map :label
  end
end
```

You can now call your view using the `map_over_label` and `count_over_label` methods:

```ruby
Article.map_over_label!
Article.count_over_label!
```
