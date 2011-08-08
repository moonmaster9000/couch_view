Feature: CouchView::Map
  As a programmer
  I want a `CouchView::Map` mixin
  So that I can create a class with a CouchDB map function


  Scenario: Mixing CouchView::Map into a class should generate a map over ids

    Given the following class definition:
      """
        class Map
          include CouchView::Map
        end
      """

    When I instantiate a new Map:
      """
        Map.new.map
      """

    Then I should receive the following CouchDB javascript map:
      """
        function(doc){
          emit(doc._id, null)
        }
      """

  Scenario: Instantiating a Map with a Model should generate a map over that model

    Given the following model definition:
      """
        class Article < CouchRest::Model::Base
        end
      """

    And the following map definition:
      """
        class Map
          include CouchView::Map
        end
      """

    When I instantiate a new Map with Article: 
      """
        Map.new(Article).map
      """

    Then I should receive the following map over the Article documents:
      """
        function(doc){
          if (doc['couchrest-type'] == 'Article')
            emit(doc._id, null)
        }
      """ 


  Scenario: Defining a custom map 

    Given the the following custom map:
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

    When I instantiate a new ByLabel map:
      """
        ByLabel.new.map
      """

    Then I should receive a CouchDB javascript map over the labels:
      """
        function(doc){
          if (true)
            emit(doc.label, null)
        }
      """


  Scenario: Decorating a map with conditions
    Given the following map definition:
      """
        class ById
          include CouchView::Map
        end
      """

    And the following module:
      """
        module Published
          def conditions
            "#{super} && doc.published"
          end
        end
      """

    When I instantiate my map, extend it with my module, and call map:
      """
        ById.new.extend(Published).map
      """

    Then I should receive a CouchDB javascript map function over the published documents:
      """
        function(doc){
          if (true && doc.published)
            emit(doc._id, null)
        }
      """
