Feature: CouchView::Map
  As a programmer
  I want a `CouchView::Map` mixin
  So that I can create a class with a CouchDB map function

  Scenario: Default map
    Given an empty class Map that includes CouchView::Map
    When I execute "Map.new.map"
    Then I should get
      """
        function(doc){
          emit(doc.id, null)
        }
      """
  
  Scenario: Instantiating a default map with a model
    Given a CouchRest::Model::Base model MyModel
    Given an empty class Map that includes CouchView::Map
    When I execute "Map.new(MyModel).map"
    Then I should get
      """
        function(doc){
          if (doc['couchrest-type'] == 'MyModel')
            emit(doc.id, null)
        }
      """ 
