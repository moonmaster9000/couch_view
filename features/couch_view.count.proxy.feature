Feature: CouchView::Count::Proxy
  
  A `CouchView::Count::Proxy` is like a regular `CouchView::Proxy`, except that it defaults the CouchDB "reduce" option to "true".

      proxy = CouchView::Count::Proxy SomeModel, :some_view
      proxy._options #==> { "reduce" => true }

  Another noticable difference: you can't call ".each" on the proxy unless you've set the "group" option to "true":
      
      proxy = CouchView::Count::Proxy SomeModel, :some_view

      proxy.each {...} #==> raises an exception "You can't call 'each' on a count proxy that doesn't set 'group' to 'true'."

  If you've set "group" to true, then when you call ".each" on it, you will iterate over the key/value pairs in the response:

      proxy.group(true).each do |key, value|
        ...
      end

  If you'd rather work with the raw (hash) response on a group level query, simply use the "get!" method:

      proxy.get!

  If you're not running a group level query, then "get!" will return the actual count (`Fixnum`):

      proxy = CouchView::Count::Proxy SomeModel, :some_view
      proxy.get! #==> 0, or some other positive integer


  @db
  Scenario: Options default to "reduce" => true
    
    Given an Article model with a view "by_id":
      """
        class Article < CouchRest::Model::Base
          view_by :id
        end
      """

    When I instantiate a new CouchView::Map::Proxy with "Article" and ":by_id":
      """
        @proxy = CouchView::Count::Proxy.new Article, :by_id
      """

    Then the options on the proxy should default to "reduce" => true
      """
        @proxy._options.should == {:reduce => true}
      """


  @db
  Scenario: ".each" should iterate over the key/value pairs of the 'rows' result:
    
    Given the following map definition:
      """
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
      """

    And an Article model that maps ByLabel:
      """
        class Article < CouchRest::Model::Base
          include CouchView
          map ByLabel
        end
      """

    And several articles:
      """
        Article.create :label => "fun-article"
        Article.create :label => "awesome-article"
        Article.create :label => "awesome-article"
      """

    When I instantiate a new CouchView::Map::Proxy with "Article" and ":by_id":
      """
        @proxy = CouchView::Count::Proxy.new Article, :by_by_label
      """

    And I set the CouchDB "group" query option to "true":
      """
        @proxy.group! true
      """

    Then the ".each" method should iterate over the keys and values in the 'rows' array in the query response: 
      """
        @results = []
        @proxy.each {|label, count| @results << {label => count}}
        @results.first.should == {"awesome-article" => 2}
        @results.last.should  == {"fun-article"     => 1}
        @results.count.should == 2
      """


  @db @focus
  Scenario: ".get!" should return 0 when the reduce returns an empty 'rows' response:
    
    Given the following map definition:
      """
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
      """

    And an Article model that maps ByLabel:
      """
        class Article < CouchRest::Model::Base
          include CouchView
          map ByLabel
        end
      """

    And there are no articles:
      """
        Article.all.count.should == 0
      """

    When I instantiate a new CouchView::Map::Proxy with "Article" and ":by_id":
      """
        @proxy = CouchView::Count::Proxy.new Article, :by_by_label
      """

    Then the ".get!" method should return 0: 
      """
        @proxy.get!.should == 0
      """


  @db @focus
  Scenario: ".get!" should return the 'value' of the first row of the 'rows' reduce response:
    
    Given the following map definition:
      """
        class ById
          include CouchView::Map
        end
      """

    And an Article model that maps ByLabel:
      """
        class Article < CouchRest::Model::Base
          include CouchView
          map ById
        end
      """

    And there are 2 articles:
      """
        2.times { Article.create }
      """

    When I instantiate a new CouchView::Map::Proxy with "Article" and ":by_by_id":
      """
        @proxy = CouchView::Count::Proxy.new Article, :by_by_id
      """

    Then the ".get!" method should return 2: 
      """
        @proxy.get!.should == 2
      """


 
  @db @focus
  Scenario: ".get!" should return the raw JSON (hash) response from CouchDB for a group query:
    
    Given the following map definition:
      """
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
      """

    And an Article model that maps ByLabel:
      """
        class Article < CouchRest::Model::Base
          include CouchView
          map ByLabel
        end
      """

    And several articles:
      """
        Article.create :label => "fun-article"
        Article.create :label => "awesome-article"
        Article.create :label => "awesome-article"
      """

    When I instantiate a new CouchView::Map::Proxy with "Article" and ":by_id":
      """
        @proxy = CouchView::Count::Proxy.new Article, :by_by_label
      """

    And I set the CouchDB "group" query option to "true":
      """
        @proxy.group! true
      """

    Then the ".get!" method should return the raw JSON response from CouchDB as a hash: 
      """
        @proxy.get!.should == {
          "rows" => [
            { "key" => "awesome-article", "value" => 2 },
            { "key" => "fun-article",     "value" => 1 }
          ]
        }
      """
 

  @db
  Scenario: You can't call ".each" on a count proxy unless the CouchDB "group" option is set to true
    
    Given the following map definition:
      """
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
      """

    And an Article model that maps ByLabel:
      """
        class Article < CouchRest::Model::Base
          include CouchView
          map ByLabel
        end
      """

    When I instantiate a new CouchView::Map::Proxy with "Article" and ":by_label":
      """
        @proxy = CouchView::Count::Proxy.new Article, :by_by_label
      """
    
    Then ".each" should raise an exception:
      """
        proc { @proxy.each {|k,v|} }.should raise_exception("You can't call 'each' on a count proxy that doesn't set 'group' to 'true'.")
      """
    
    When I set the CouchDB "group" query option to "true":
      """
        @proxy.group!(true)
      """

    Then ".each" should not raise an exception:
      """
        proc { @proxy.each {|k,v|} }.should_not raise_exception
      """

