class Fluent::DelayInspectorOutput < Fluent::Output
  Fluent::Plugin.register_output('delay_inspector', self)

  config_param :tag, :string, :default => nil
  config_param :remove_prefix, :string, :default => nil
  config_param :add_prefix, :string, :default => nil

  config_param :key_name, :string, :default => 'delay'
  config_param :reserve_data, :bool, :default => false

  # Define `log` method for v0.10.42 or earlier
  unless method_defined?(:log)
    define_method("log") { $log }
  end

  def configure(conf)
    super

    if not @tag and not @remove_prefix and not @add_prefix
      raise Fluent::ConfigError, "missing both of remove_prefix and add_prefix"
    end
    if @tag and (@remove_prefix or @add_prefix)
      raise Fluent::ConfigError, "both of tag and remove_prefix/add_prefix must not be specified"
    end
    if @remove_prefix
      @removed_prefix_string = @remove_prefix + '.'
      @removed_length = @removed_prefix_string.length
    end
    if @add_prefix
      @added_prefix_string = @add_prefix + '.'
    end
  end

  def emit(tag, es, chain)
    tag = if @tag
            @tag
          else
            if @remove_prefix and
                ( (tag.start_with?(@removed_prefix_string) and tag.length > @removed_length) or tag == @remove_prefix)
              tag = tag[@removed_length..-1]
            end
            if @add_prefix
              tag = if tag and tag.length > 0
                      @added_prefix_string + tag
                    else
                      @add_prefix
                    end
            end
            tag
          end
    if @reserve_data
      es.each do |time,record|
        record[@key_name] = Fluent::Engine.now - time
        Fluent::Engine.emit(tag, time, record)
      end
    else
      es.each do |time,record|
        Fluent::Engine.emit(tag, time, {@key_name => (Fluent::Engine.now - time)})
      end
    end
    chain.next
  end
end
