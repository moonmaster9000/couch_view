Feature: CouchView::Map::Proxy

  A proxy object that lets you lazily build CouchDB map queries.


  h2. Creating a map proxy

  To create a new map proxy, simply instantiate `CouchView::Map::Proxy` with the model to call on, and the map to call:
      
      proxy = CouchView::Map::Proxy.new Article, :by_id


  h2. Adding CouchDB query parameters to the proxy

  You can add CouchDB query parameters to your view proxy by calling their corresponding methods on the proxy. 

  For example, suppose we'd like to limit the results of our query to 10 documents:

      proxy.limit(10)

  This will return a new proxy that's just like the original proxy, except that it will also include a `limit=10` query string parameter when making a call to CouchDB.

  If you'd rather update the existing proxy, instead of getting a new one, you can append a "!" onto the end:

      proxy.limit!(10)


  h2. Modifying the map to call

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


  h2. Triggering the call

  You can trigger a call on a map proxy by calling either the `.each` method or the `get!` method:

      proxy = CouchView::Map::Proxy.new Article, :by_label
      
      proxy.each {...} #==> executes "Article.by_label"
      proxy.get!       #==> executes "Article.by_label"


  
  Scenario: Creating a map proxy

    Given an Article model with a view "by_id":
      """
        class Article < CouchRest::Model::Base
          view_by :id
        end
      """

    When I instantiate a new CouchView::Map::Proxy with "Article" and ":by_id":
      """
        @proxy = CouchView::Map::Proxy.new Article, :by_id
      """

    Then the "_map" method should return ":by_id":
      """
        @proxy._map.should == :by_id
      """

    And the "_model" method should return "Article":
      """
        @proxy._model.should == Article
      """

    And the "_options" method should return the default map option of `"reduce" => false`:
      """
        @proxy._options.should == {"reduce" => false}
      """


  Scenario: Generating a new proxy by adding a query option

    Given an Article model with a view "by_id":
      """
        class Article < CouchRest::Model::Base
          view_by :id
        end
      """

    When I instantiate a new CouchView::Map::Proxy with "Article" and ":by_id":
      """
        @proxy = CouchView::Map::Proxy.new Article, :by_id
      """

    And I limit the results to 10:
      """
        @new_proxy = @proxy.limit 10
      """

    Then @new_proxy should be a new object:
      """
        @new_proxy.object_id.should_not == @proxy.object_id
      """

    And the "_options" method on @new_proxy should return a limit of 10:
      """
        @new_proxy._options.should == {"reduce" => false, "limit" => 10} 
      """

    And the "_options" method on the @proxy should return the default map option of `"reduce" => false`:
      """
        @proxy._options.should == {"reduce" => false}
      """


  Scenario: Destructively modifying the existring query by adding a query option with an exclamation point at the end

    Given an Article model with a view "by_id":
      """
        class Article < CouchRest::Model::Base
          view_by :id
        end
      """

    When I instantiate a new CouchView::Map::Proxy with "Article" and ":by_id":
      """
        @proxy = CouchView::Map::Proxy.new Article, :by_id
      """

    And I destructively limit the results to 10:
      """
        @new_proxy = @proxy.limit! 10
      """

    Then @new_proxy should not be a new object:
      """
        @new_proxy.object_id.should == @proxy.object_id
      """

    And the "_options" method on the new proxy should return a limit of 10:
      """
        @proxy._options.should == {"reduce" => false, "limit" => 10} 
      """


  Scenario: The map name should include alpha-sorted conditions

    Given an Article model with a view "by_id":
      """
        class Article < CouchRest::Model::Base
          view_by :id
        end
      """

    When I instantiate a new CouchView::Map::Proxy with "Article" and ":by_id":
      """
        @proxy = CouchView::Map::Proxy.new Article, :by_id
      """

    And I call the published! method on the proxy:
      """
        @proxy.published!
      """

    Then the "_map" method should return ":by_id_published":
      """
        @proxy._map.should == :by_id_published
      """

    When I call the active! method on the proxy:
      """
        @proxy.active!
      """

    Then the "_map" method should return ":by_id_active_published":
      """
        @proxy._map.should == :by_id_active_published
      """

    When I call the visible! method on the proxy:
      """
        @proxy.visible!
      """

    Then the "_map" method should return ":by_id_active_published_visible": 
      """
        @proxy._map.should == :by_id_active_published_visible
      """
  
  @db
  Scenario: Executing the proxy with "get!" or "each!"
    
    Given an Article model with a view "by_id":
      """
        class Article < CouchRest::Model::Base
          view_by :id
        end
      """

    When I instantiate a new CouchView::Map::Proxy with "Article" and ":by_id":
      """
        @proxy = CouchView::Map::Proxy.new Article, :by_id
      """

    And I call the "get!" method on the proxy
      """
        @call = proc { @proxy.get! }
      """

    Then the proxy should call the ":by_id" method on the Article model:
      """
        Article.should_receive(:by_id)
        @call.call
      """

    When I call the "each" method on the proxy
      """
        Article.should_receive(:by_id).and_return ["result"]
        @call = proc { @proxy.each {|a| a.should == "result"} }
      """

    Then the proxy should call the ":by_id" method on the Article model: 
      """
        @call.call
      """


  Scenario: You are now allowed to call "reduce" on a map proxy
    
    Given an Article model with a view "by_id":
      """
        class Article < CouchRest::Model::Base
          view_by :id
        end
      """

    When I instantiate a new CouchView::Map::Proxy with "Article" and ":by_id":
      """
        @proxy = CouchView::Map::Proxy.new Article, :by_id
      """

    Then I should not be able to call the "reduce" method on my proxy
      """
        proc { @proxy.reduce }.should raise_error("You are not allowed to reduce a map proxy.")
      """
    
    And I should not be able to call the "reduce!" method on my proxy
      """
        proc { @proxy.reduce! }.should raise_error("You are not allowed to reduce a map proxy.")
      """



