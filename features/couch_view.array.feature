Feature: All subsets of an array


  Scenario: Generating all subsets of an array
    
    Given an array of 3 elements:
      """
      @array = [1,2,3]
      """

    When I call the "all_combinations" method on it:
      """
      @result = @array.all_combinations
      """

    Then I should receive all of the subsets of my array:
      """
        @result.should == [
          [],
          [1],
          [2],
          [3],
          [1,2],
          [1,3],
          [2,3],
          [1,2,3]
        ]
      """
