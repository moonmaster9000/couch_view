Feature: CouchView
  As a programmer
  I want a `CouchView` mixin for my `CouchRest::Model::Base` models
  So that I can define maps and reduces on my model 

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

    When I create an Article:
      """
        @article = Article.create
      """

    Then `map_by_id!` should return the article
      """
        Article.map_by_id!.first.should == @article
      """
