class Array
  def all_combinations
    (0..self.length).map do |i| 
      self.combination(i).to_a 
    end.inject([]) do |sum, value| 
      sum += value 
    end
  end
end
