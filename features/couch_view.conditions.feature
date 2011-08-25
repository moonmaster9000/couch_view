Feature: CouchView::Config::Conditions
  
  CouchView::Config::Conditions are a simple way to keep track of the conditions in a view configuration.

  h2. Instantiation

  To create a new CouchView::Config::Conditions instance, simply call ".new" on it.

  During instantiation, you can pass some modules to it representing conditions:
      
      conditions_config = CouchView::Config::Conditions.new Condition1, Condition2

  h2. Adding conditions

  You can add more conditions to it by passing them to the "add_conditions":
      
      conditions_config.add_conditions Condition3, Condition4

  If you add a condition that's namespaced, the name of the condition will be defaulted to the unqualified class name:
      
      conditions_config.add_condition Namespace::Subspace::ConditionX

      conditions_Config.conditions[:condition_x] #==> Namespace::Subspace::ConditionX

  h2. Adding named conditions

  You can add named conditions to your config by calling a method on them with the name you want to reference the condition by:

      conditions_config.published Conditions::Published

  h2. Getting all of the conditions

  If you call the "conditions" method without any arguments, you'll receive a hash of all of the conditions. The key is the name of a condition, the value is the condition module.

      #conditions_config.conditions
      #  #==> {
      #      :condition1 => Condition1,
      #      :condition2 => Condition2,
      #      :condition3 => Condition3,
      #      :condition4 => Condition4,
      #      :published  => Conditions::Published
      #    }


  Scenario: Conditions passed during CouchView::Config::Conditions instantiation
    Given the following conditions:
      """
        module Published; end
        module Visible; end
      """

    When I instantiate a CouchView::Config::Conditions object and pass those condition modules to it:
      """
        @conditions_config = CouchView::Config::Conditions.new Published, Visible
      """

    Then the "conditions" method on the config should return those conditions:
      """
        @conditions_config.conditions.should == {
          :published => Published, 
          :visible => Visible
        }
      """


  Scenario: Adding conditions after instantiation
    Given the following conditions:
      """
        module Published; end
        module Visible; end
      """

    And a CouchView::Config::Conditions object:
      """
        @conditions_config = CouchView::Config::Conditions.new
      """

    When I pass those condition modules to the condition config object's "add_conditions" method:
      """
        @conditions_config.add_conditions Published, Visible
      """

    Then the "conditions" method on the config should return those conditions:
      """
        @conditions_config.conditions.should == {
          :published => Published, 
          :visible => Visible
        }
      """

  Scenario: Creating named conditions
    Given the following conditions:
      """
        module Published; end
        module Visible; end
      """

    And a CouchView::Config::Conditions object:
      """
        @conditions_config = CouchView::Config::Conditions.new
      """

    When I add those conditions to my config with custom names:
      """
        @conditions_config.filter_by_published Published
        @conditions_config.filter_by_visible Visible
      """

    Then the "conditions" method on the config should return those conditions:
      """
        @conditions_config.conditions.should == {
          :filter_by_published => Published, 
          :filter_by_visible => Visible
        }
      """

  Scenario: Namespaced conditions get unqualified keys
    Given the following conditions:
      """
        module Conditions
          module Published; end
          module Visible; end
        end
      """

    And a CouchView::Config::Conditions object:
      """
        @conditions_config = CouchView::Config::Conditions.new
      """

    When I pass those condition modules to the condition config object's "add_conditions" method:
      """
        @conditions_config.add_conditions Conditions::Published, Conditions::Visible
      """

    Then the "conditions" method on the config should return those conditions:
      """
        @conditions_config.conditions.should == {
          :published => Conditions::Published, 
          :visible => Conditions::Visible
        }
      """
