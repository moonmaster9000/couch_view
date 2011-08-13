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
  Scenario: Setting a custom reduce
    
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

  
  @db
  Scenario: Setting conditions on the view
    
    Given the following model:
      """
        class Article < CouchRest::Model::Base
          include CouchView
          property :label
          property :name
        end
      """
    
    And the following conditions:
      """
        module Published
          def conditions
            "#{super} && doc.published == true"
          end
        end
        
        module Visible
          def conditions
            "#{super} && doc.visible == true"
          end
        end
      """

    When I create a CouchView::Config to map over Article labels:
      """
        @config = CouchView::Config.new :model => Article, :map => [:label]
      """

    And I add the Published and Visible conditions to it:
      """
        @config.conditions Published, Visible
      """

    Then the conditions should be Published and Visible:
      """
        @config.conditions.should == [Published, Visible]
      """

    And the view names should include views for published, visible, and published/visible documents:
      """
        @config.view_names.sort.should == ["by_label", "by_label_published", "by_label_published_visible", "by_label_visible"]
      """
    
      
  @db
  Scenario: Getting all the views
    
    Given the following model:
      """
        class Article < CouchRest::Model::Base
          include CouchView
          property :label
          property :name
        end
      """
    
    And the following conditions:
      """
        module Published
          def conditions
            "#{super} && doc.published == true"
          end
        end
        
        module Visible
          def conditions
            "#{super} && doc.visible == true"
          end
        end
      """

    When I create a CouchView::Config to map over Article labels:
      """
        @config = CouchView::Config.new :model => Article, :map => [:label]
      """

    And I add the Published and Visible conditions to it:
      """
        @config.conditions Published, Visible
      """

    Then the views should include a "by_label" view:
      """
        @config.views[:by_label][:map].should == 
              "
                function(doc){
                  if (doc['couchrest-type'] == 'Article')
                    emit(doc.label, null)
                }
              "
        @config.views[:by_label][:reduce].should == "_count"
      """

    And the views should include a "by_label_published" view:
      """
        @config.views[:by_label_published][:map].should == 
              "
                function(doc){
                  if (doc['couchrest-type'] == 'Article' && doc.published == true)
                    emit(doc.label, null)
                }
              "
        @config.views[:by_label_published][:reduce].should == "_count"
      """

    And the views should include a "by_label_visible" view:
      """
        @config.views[:by_label_visible][:map].should == 
              "
                function(doc){
                  if (doc['couchrest-type'] == 'Article' && doc.visible == true)
                    emit(doc.label, null)
                }
              "
        @config.views[:by_label_visible][:reduce].should == "_count"
      """

    And the views should include a "by_label_published_visible" view:
      """
        @config.views[:by_label_published_visible][:map].should == 
              "
                function(doc){
                  if (doc['couchrest-type'] == 'Article' && doc.published == true && doc.visible == true)
                    emit(doc.label, null)
                }
              "
        @config.views[:by_label_published_visible][:reduce].should == "_count"
      """
