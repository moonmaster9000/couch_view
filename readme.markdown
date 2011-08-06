# CouchView

A decorator library for generating CouchDB view (map/reduce) functions for CouchRest::Model models. 

## Why?

CouchView makes your `CouchRest::Model::Base` views modular, and also makes it easier to unit test them.

## Requirements?

This gem integrates with the `couchrest_model` gem (version ~> 1.0.0)

## Installation

Install it as a gem:

```sh
    $ gem install couch_map
```

## Your first view

Let's imagine that we want to create a map on our model that includes all of the document labels (human-readable ids):

```ruby
    class ByLabel
      include CouchView::Map
      
      def map
        "
          function(doc){
            if (#{conditions})
              emit(doc.label, null)
          }
        "
      end
    end
```

Note that instead of specifying the conditions for inclusion in our map, we instead called the `conditions` instance method. This is a method mixed into your class via `CouchView::Map`.

Now, you can use this in your `CouchRest::Model::Base` class thusly: 

```ruby
    class Article < CouchRest::Model::Base
      include CouchMap

      map ByLabel
    end
```

This will generate a map `by_label` on `Article` that looks like this:

```javascript
    function(doc){
      if (doc['couchrest-type'] == 'Article')
        emit(doc.label, null) 
    }
```

If you'd like to also count by label, you could use the `map_and_count` method instead:

```ruby
    class Article < CouchRest::Model::Base
      include CouchMap

      map_and_count ByLabel
    end
```

By using the `count` method on our model, we now have the following methods:

```ruby
    Article.map_by_label   #==> return all documents in order of label
    Article.count_by_label #==> return the count of all documents in the "by_label" map
```

These methods return a proxy for your query. You can continue to add CouchDB view conditions to your query:
    
```ruby
    query = Article.map_by_label
    query = query.startkey("a").endkey("b")
```

Each time you add a condition to your query, you will get a new query returned. If you'd rather update your existing query, you can append your condition with a "!":

```ruby   
    query = Article.map_by_label
    query.startkey!("a").endkey!("b")

    # query at this point includes the conditions :startkey => 'a', :endkey => 'b'
```

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


## Conditional Variations

Now, let's suppose we'd like to extend our map with new conditions: we only include a document in the index if the "visible" property is true:

```ruby
    module Visible
      def conditions
        "#{super} && doc.visible == true"
      end
    end
```

We can now add this into our model thusly:

```ruby
    class Article < CouchRest::Model::Base
      include CouchView

      property :visible, TrueClass, :default => false
      
      map_and_count ByLabel, Visible
    end
```

Just like before, this created the following methods on our model:
   
```ruby
    Article.map_by_label
    Article.count_by_label
```

When called without any conditions, these methods did the exact same thing they did before: mapped (or counted) all the `Article` documents in your database.

However, it also opened up the possibility to use the `visible` and `visible!` conditions on these queries:
   
```ruby
    Article.map_by_label.visible.get!
    Article.count_by_label.visible.get!
```

These queries map (or count) over the visible `Article` documents in your database.

If you add more condition modules onto the `map`, then you'll simply get more conditions to use on your map:

```ruby
    module Published
      def conditions
        "#{super} && doc.published == true"
      end
    end

    class Article < CouchRest::Model::Base
      include CouchView

      property :visible,   TrueClass, :default => false
      property :published, TrueClass, :default => false
      
      map_and_count ByLabel, Visible, Published
    end

    Article.map_by_label.visible
      #==> all visible Article documents in the database
    
    Article.map_by_label.published
      #==> all published Article documents in the database
    
    Article.map_by_label.published.visible
      #==> all published, visible documents in the database
```

## Arbitrary Reduce

You can add any arbitrary reduce onto your `map` by simply specifying a `:reduce => "...."` method at the end of your `map`:

```ruby
    class Article < CouchRest::Model::Base
      include CouchMap

      property :visible, TrueClass, :default => false
      
      map ByLabel, Visible, :reduce => "
        function(key, values){
          return sum(values)
        }
      "
    end
```

And now you can call it by call it with:
   
```ruby
    Article.reduce_by_label.get!
```

## Custom Names

You find yourself needing to run more than one reduce on the same map. In that case, you'll have to supply the maps with unique names:

```ruby
    class Article < CouchRest::Model::Base
      include CouchMap

      map ByLabel, Visible, :reduce => "_count"
      map :by_label_with_doubler, ByLabel, Visible, :reduce => 
        "
          function(key, values){
            return sum(values) * 2
          end
        "
    end
```

You can now call these reduce methods thusly:

```ruby
    Article.reduce_by_label!
    Article.reduce_by_label_with_doubler!
```
