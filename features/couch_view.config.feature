Feature: CouchView::Config
  
  A `CouchView::Config` consists of the following data:
    * a CouchView::Map
    * the conditions (if any) with which to extend that map
    * the names of the views
    * the reduce for the view

  When you instantiate a CouchView::Config, you must provide both the model and the properties to map over:
      
      class Article < CouchRest::Model::Base; end

      config = CouchView::Config.new :model => Article, :map => [:prop1, :prop2]
      config.view_names #==> ["by_prop1_and_prop2"]
      config.model #==> Article

  You could, alternatively, provide it with a model and a CouchView::Map class:
      
      class ById; include CouchView::Map; end
      config = CouchView::Config.new :model => Article, :map => [ById]
      config.view_names   #==> ["by_id"]
      config.model  #==> Article

  By default, a `CouchView::Config` will assume a reduce of `_count`:
      
      config.reduce #==> "_count"

  You can override this by supplying your own reduce:
      
      config.reduce "function(key, values){}"
      config.reduce #==> "function(key, values){}" 

  Lastly, you can provide your `CouchView::Config` with conditions:

      module Published
        def conditions
          "#{super} && doc.published == true"
        end
      end

      config.conditions Published
      config.conditions #==> [Published]

  You can now ask your `Config` to return a hash containing all of the views (with their corresponding map/reduce) that you should setup on your model:

      class Article < CouchRest::Model::Base
        property :label
        property :published, TrueClass, :default => false
      end
      
      config = CouchView::Config.new :model => Article, :map => :label
      
      module Published
        def conditions
          "#{super} && doc.published == true"
        end
      end

      config.conditions Published

      config.views #==> 
        {
          "by_label" => {
            "map" => "function....",
            "reduce" => "_count"
          },
          "by_label_published" => {
            "map" => "function....",
            "reduce" => "_count"
          }
        }


  @db
  Scenario: Generating a name based on the properties passed in to map over
    
    Given the following model:
      """
        class Article < CouchRest::Model::Base
          include CouchView
          property :label
          property :name
        end
      """

    When I create a CouchView::Config to map over Article labels:
      """
        @config = CouchView::Config.new :model => Article, :map => [:label]
      """

    Then the config should report "by_label" as a view name:
      """
        @config.view_names.should == ["by_label"]
      """

    When I create a CouchView::Config to map over Article labels and names:
      """
        @config = CouchView::Config.new :model => Article, :map => [:label, :name]
      """

    Then the config should report "by_label" as a view name:
      """
        @config.view_names.should == ["by_label_and_name"]
      """
    
    When I create a CouchView::Map `ById`:
      """
        class ById
          include CouchView::Map
        end
      """

    And I create a CouchView::Config to map over article documents `ById`:
      """
        @config = CouchView::Config.new :model => Article, :map => [ById]
      """

    Then the config should report "by_id" as a view name:
      """
        @config.view_names.should == ["by_id"]
      """


  @db
  Scenario: Generating a name based on the properties passed in to map over
    
    Given the following model:
      """
        class Article < CouchRest::Model::Base
          include CouchView
          property :label
          property :name
        end
      """

    When I create a CouchView::Config to map over Article labels:
      """
        @config = CouchView::Config.new :model => Article, :map => [:label]
      """

    Then the config should default the "reduce" to "_count":
      """
        @config.reduce.should == "_count"
      """

    When I change the "reduce" to a javascript function:
      """
        @config.reduce "function(key, values){}"
      """

    Then the config should return that function for the "reduce":
      """
        @config.reduce.should == "function(key, values){}" 
      """
