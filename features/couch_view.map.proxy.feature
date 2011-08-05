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

    Then the "_map" method should return ":by_id"
      """
        @proxy._map.should == :by_id
      """

    And the "_model" method should return "Article"
      """
        @proxy._model.should == Article
      """
