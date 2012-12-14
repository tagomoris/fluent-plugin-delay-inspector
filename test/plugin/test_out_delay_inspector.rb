require 'helper'

class DelayInspectorOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG1 = %[
    tag delay.info
  ]
  CONFIG2 = %[
    add_prefix fixed
    key_name delayinfo
  ]
  CONFIG3 = %[
    remove_prefix before
    add_prefix after
    reserve_data true
  ]

  def create_driver(conf=CONFIG1, tag='test')
    Fluent::Test::OutputTestDriver.new(Fluent::DelayInspectorOutput, tag).configure(conf)
  end

  def test_configure
    assert_raise(Fluent::ConfigError) {
      d = create_driver('')
    }
    assert_nothing_raised {
      d = create_driver %[
        tag foo
      ]
    }
    assert_nothing_raised {
      d = create_driver %[
        remove_prefix bar
      ]
    }

    d = create_driver
    assert_equal 'delay', d.instance.key_name
    assert_equal false, d.instance.reserve_data

    d3 = create_driver(CONFIG3)
    assert_equal true, d3.instance.reserve_data
  end

  def test_emit1
    d1 = create_driver(CONFIG1, 'whatever')
    time = Time.now.to_i - 3
    d1.run do
      d1.emit({'foo' => 'bar', 'baz' => 'boo'}, time)
      d1.emit({'foo' => 'bar', 'baz' => 'boo'}, time)
    end
    emits = d1.emits
    assert_equal 2, emits.length

    assert_equal 'delay.info', emits[0][0]
    assert_equal time, emits[0][1]
    assert_equal ['delay'], emits[0][2].keys
    assert ( 3 <= emits[0][2]['delay'].to_i && emits[0][2]['delay'] <= 4 )

    assert_equal 'delay.info', emits[1][0]
    assert_equal time, emits[1][1]
    assert_equal ['delay'], emits[1][2].keys
    assert ( 3 <= emits[1][2]['delay'].to_i && emits[1][2]['delay'] <= 4 )
  end

  def test_emit2
    d1 = create_driver(CONFIG2, 'whatever')
    time = Time.now.to_i - 3
    d1.run do
      d1.emit({'foo' => 'bar', 'baz' => 'boo'}, time)
      d1.emit({'foo' => 'bar', 'baz' => 'boo'}, time)
    end
    emits = d1.emits
    assert_equal 2, emits.length

    assert_equal 'fixed.whatever', emits[0][0]
    assert_equal time, emits[0][1]
    assert_equal ['delayinfo'], emits[0][2].keys
    assert ( 3 <= emits[0][2]['delayinfo'].to_i && emits[0][2]['delayinfo'] <= 4 )

    assert_equal 'fixed.whatever', emits[1][0]
    assert_equal time, emits[1][1]
    assert_equal ['delayinfo'], emits[1][2].keys
    assert ( 3 <= emits[1][2]['delayinfo'].to_i && emits[1][2]['delayinfo'] <= 4 )
  end

  def test_emit3
    d1 = create_driver(CONFIG3, 'before.whatever')
    time = Time.now.to_i - 3
    d1.run do
      d1.emit({'foo' => 'bar', 'baz' => 'boo'}, time)
      d1.emit({'foo' => 'bar', 'baz' => 'boo'}, time)
    end
    emits = d1.emits
    assert_equal 2, emits.length

    assert_equal 'after.whatever', emits[0][0]
    assert_equal time, emits[0][1]
    assert_equal ['baz', 'delay', 'foo'], emits[0][2].keys.sort
    assert ( 3 <= emits[0][2]['delay'].to_i && emits[0][2]['delay'] <= 4 )

    assert_equal 'after.whatever', emits[1][0]
    assert_equal time, emits[1][1]
    assert_equal ['baz', 'delay', 'foo'], emits[0][2].keys.sort
    assert ( 3 <= emits[1][2]['delay'].to_i && emits[1][2]['delay'] <= 4 )
  end
end
