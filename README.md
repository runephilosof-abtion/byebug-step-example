# Demonstrate the bug described below and on https://github.com/deivid-rodriguez/byebug/issues/877#issuecomment-4246648231

Sometimes, I can use `step`, `next` to get to into the second call made on a line. Other times, the `next` skips the second call.

With
```
require 'byebug'
class Foo
  def some2
    true
  end
end

def some1
  Foo.new
end

byebug  
some1().some2()
"second line"
```

After `step`, `next`, I expect to be in the first line of `def some2`.

This type of stepping works for the above simple example.

```
[6, 15] in some.rb
    6:   end
    7: end
    8: 
    9: def some1
   10:   Foo.new
   11: end
   12: 
   13: byebug  
=> 14: some1().some2()
   15: "second line"
(byebug) s

[5, 14] in some.rb
    5:     true
    6:   end
    7: end
    8: 
    9: def some1
=> 10:   Foo.new
   11: end
   12: 
   13: byebug  
   14: some1().some2()
(byebug) n

[1, 10] in some.rb
    1: require 'byebug'
    2: 
    3: class Foo
    4:   def some2
=>  5:     true
    6:   end
    7: end
    8: 
    9: def some1
   10:   Foo.new
(byebug) n

[6, 15] in some.rb
    6:   end
    7: end
    8: 
    9: def some1
   10:   Foo.new
   11: end
   12: 
   13: byebug  
   14: some1().some2()
=> 15: "second line"
(byebug) n
```

Currently, I am debugging Capybara 3.40.0 and found a case where it does not happen.

```
=> 90:         check('My label')
   91:         check('My second label')
(byebug) s

[47, 56] in /home/user/.asdf/installs/ruby/3.2.8/lib/ruby/gems/3.2.0/gems/capybara-3.40.0/lib/capybara/dsl.rb
   47:     end
   48: 
   49:     Session::DSL_METHODS.each do |method|
   50:       class_eval <<~METHOD, __FILE__, __LINE__ + 1
   51:         def #{method}(...)
=> 52:           page.method("#{method}").call(...)
   53:         end
   54:       METHOD
   55:     end
   56:   end
(byebug) s

[41, 50] in /home/user/.asdf/installs/ruby/3.2.8/lib/ruby/gems/3.2.0/gems/capybara-3.40.0/lib/capybara/dsl.rb
   41:     #     end
   42:     #
   43:     # @return [Capybara::Session] The current session object
   44:     #
   45:     def page
=> 46:       Capybara.current_session
   47:     end
   48: 
   49:     Session::DSL_METHODS.each do |method|
   50:       class_eval <<~METHOD, __FILE__, __LINE__ + 1
(byebug) n

[85, 94] in some.rb
   90:         check('My label')
=> 91:         check('My second label')
(byebug) s
```

In the above, I expected to `step` into the `call(...)`, when I `next` out of the `page` call.

But instead, I have to do the below.

```
[47, 56] in /home/user/.asdf/installs/ruby/3.2.8/lib/ruby/gems/3.2.0/gems/capybara-3.40.0/lib/capybara/dsl.rb
   47:     end
   48: 
   49:     Session::DSL_METHODS.each do |method|
   50:       class_eval <<~METHOD, __FILE__, __LINE__ + 1
   51:         def #{method}(...)
=> 52:           page.method("#{method}").call(...)
   53:         end
   54:       METHOD
   55:     end
   56:   end
(byebug) s

[41, 50] in /home/user/.asdf/installs/ruby/3.2.8/lib/ruby/gems/3.2.0/gems/capybara-3.40.0/lib/capybara/dsl.rb
   41:     #     end
   42:     #
   43:     # @return [Capybara::Session] The current session object
   44:     #
   45:     def page
=> 46:       Capybara.current_session
   47:     end
   48: 
   49:     Session::DSL_METHODS.each do |method|
   50:       class_eval <<~METHOD, __FILE__, __LINE__ + 1
(byebug) s

[312, 321] in /home/user/.asdf/installs/ruby/3.2.8/lib/ruby/gems/3.2.0/gems/capybara-3.40.0/lib/capybara.rb
   312:     # The current {Capybara::Session} based on what is set as {app} and {current_driver}.
   313:     #
   314:     # @return [Capybara::Session]     The currently used session
   315:     #
   316:     def current_session
=> 317:       specified_session || session_pool["#{current_driver}:#{session_name}:#{app.object_id}"]
   318:     end
   319: 
   320:     ##
   321:     #
(byebug) n

[768, 777] in /home/user/.asdf/installs/ruby/3.2.8/lib/ruby/gems/3.2.0/gems/capybara-3.40.0/lib/capybara/session.rb
   768:     end
   769: 
   770:     NODE_METHODS.each do |method|
   771:       class_eval <<~METHOD, __FILE__, __LINE__ + 1
   772:         def #{method}(...)
=> 773:           @touched = true
   774:           current_scope.#{method}(...)
   775:         end
   776:       METHOD
   777:     end
```

Now, I arrived at the method I wanted.
