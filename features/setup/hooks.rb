Before do
  Object.class_eval do
    if defined? Article
      remove_const "Article"
    end
  end
end
