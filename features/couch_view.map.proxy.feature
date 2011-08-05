Feature: CouchView::Map::Proxy
  As a programmer
  I want a CouchView::Map::Proxy
  So that I can lazily build my CouchDB map queries

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

    And the "_options" method should return an empty hash:
      """
        @proxy._options.should == {}
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

    Then @new_proxy should be a new proxy object:
      """
        @new_proxy.object_id.should_not == @proxy.object_id
      """

    And the "_options" method on the new proxy should return a limit of 10:
      """
        @new_proxy._options.should == {"limit" => 10} 
      """

    And the "_options" method on the old proxy should return an empty hash:
      """
        @proxy._options.should == {}
      """
