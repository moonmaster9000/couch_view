Feature: CouchView::Map
  As a programmer
  I want a `CouchView::Map` mixin
  So that I can create a class with a CouchDB map function

  Scenario: Default map
    Given an empty class Map that includes CouchView::Map:
      """
        class Map
          include CouchView::Map
        end
      """

    When I execute:
      """
        Map.new.map
      """

    Then I should get:
      """
        function(doc){
          emit(doc._id, null)
        }
      """
  
  Scenario: Instantiating a default map with a model
    Given an Article model

    And an empty class Map that includes CouchView::Map:
      """
        class Map
          include CouchView::Map
        end
      """

    When I execute: 
      """
        Map.new(Article).map
      """

    Then I should get:
      """
        function(doc){
          if (doc['couchrest-type'] == 'Article')
            emit(doc._id, null)
        }
      """ 
