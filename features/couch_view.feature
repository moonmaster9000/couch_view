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

    Then I should receive a map proxy:
      """
        @proxy.class.should == CouchView::Map::Proxy
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
