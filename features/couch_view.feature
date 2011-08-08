Feature: CouchView
  As a programmer
  I want a `CouchView` mixin for my `CouchRest::Model::Base` models
  So that I can define maps and reduces on my model 
  

  @db
  Scenario: Define a map on your model with the `map` class method
    Given the following map definition:
      """
        class ById
          include CouchView::Map
        end
      """

    When I mix `CouchView` into my model and define a `map ById`:
      """
        class Article < CouchRest::Model::Base
          include CouchView

          map ById
        end
      """

    Then my model should respond to `map_by_id`:
      """
        Article.should respond_to(:map_by_id)
      """

    And my model should respond to `map_by_id!`:
      """
        Article.should respond_to(:map_by_id!)
      """


  @db
  Scenario: Retrieve a map proxy
    
    Given the following map definition:
      """
        class ById
          include CouchView::Map
        end
      """

    When I mix `CouchView` into my model and define a `map ById`:
      """
        class Article < CouchRest::Model::Base
          include CouchView
          map ById
        end
      """

    And I call the "map_by_id" method on my model:
      """
        @proxy = Article.map_by_id
      """

    Then I should receive a view proxy:
      """
        @proxy.class.should == CouchView::Proxy
      """

    And my proxy should map over ":by_by_id":
      """
        @proxy._map.should == :by_by_id
      """

    And my proxy should map on the "Article" model:
      """
        @proxy._model.should == Article
      """


  @db
  Scenario: Generate a reduce proxy for counting the number of results in your query

    Given the following map definition:
      """
        class ById
          include CouchView::Map
        end
      """

    When I mix `CouchView` into my model and define a `map ById`:
      """
        class Article < CouchRest::Model::Base
          include CouchView
          map ById
        end
      """
    
    Then my model should respond to `count_by_id`:
      """
        Article.should respond_to(:count_by_id)
      """

    And my model should respond to `count_by_id!`:
      """
        Article.should respond_to(:count_by_id!)
      """

    When I call the `count_by_id` method
      """
        @proxy = Article.count_by_id
      """

    Then I should receive a count proxy:
      """
        @proxy.class.should be(CouchView::Count::Proxy)
      """

  @db @focus
  Scenario: Counting the number of rows in a reduce query
    
    Given the following map definition:
      """
        class ById
          include CouchView::Map
        end
      """

    When I mix `CouchView` into my model and define a `map ById`:
      """
        class Article < CouchRest::Model::Base
          include CouchView
          map ById
        end
      """
    
    And I create 4 articles:
      """
        4.times { Article.create }
      """

    Then `count_by_id!` should return 4:
      """
        Article.count_by_id!.should == 4
      """

  @db
  Scenario: Query a map on your model
    
    Given the following map definition:
      """
        class ById
          include CouchView::Map
        end
      """

    When I mix `CouchView` into my model and define a `map ById`:
      """
        class Article < CouchRest::Model::Base
          include CouchView

          map ById
        end
      """

    And I create an Article:
      """
        @article = Article.create
      """

    Then `map_by_id!` should return the article
      """
        Article.map_by_id!.first.should == @article
      """

    And `map_by_id.get!` should return the article
      """
        Article.map_by_id.get!.first.should == @article
      """
