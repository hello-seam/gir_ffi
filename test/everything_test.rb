require File.expand_path('test_helper.rb', File.dirname(__FILE__))
require 'gir_ffi'

# Tests generated methods and functions in the Everything namespace.
class EverythingTest < Test::Unit::TestCase
  def ref_count object
    GObject::Object::Struct.new(object.to_ptr)[:ref_count]
  end

  def is_floating? object
    (GObject::Object::Struct.new(object.to_ptr)[:qdata].address & 2) == 2
  end

  context "The generated Everything module" do
    setup do
      GirFFI.setup :Everything
    end

    context "the Everything::TestBoxed class" do
      should "create an instance using #new" do
	tb = Everything::TestBoxed.new
	assert_instance_of Everything::TestBoxed, tb
      end

      should "create an instance using #new_alternative_constructor1" do
	tb = Everything::TestBoxed.new_alternative_constructor1 1
	assert_instance_of Everything::TestBoxed, tb
	assert_equal 1, tb[:some_int8]
      end

      should "create an instance using #new_alternative_constructor2" do
	tb = Everything::TestBoxed.new_alternative_constructor2 1, 2
	assert_instance_of Everything::TestBoxed, tb
	assert_equal 1 + 2, tb[:some_int8]
      end

      should "create an instance using #new_alternative_constructor3" do
	tb = Everything::TestBoxed.new_alternative_constructor3 "54"
	assert_instance_of Everything::TestBoxed, tb
	assert_equal 54, tb[:some_int8]
      end

      should "have non-zero positive result for #get_gtype" do
	assert Everything::TestBoxed.get_gtype > 0
      end

      context "an instance" do
	setup do
	  @tb = Everything::TestBoxed.new_alternative_constructor1 123
	end

	should "have a working equals method" do
	  tb2 = Everything::TestBoxed.new_alternative_constructor2 120, 3
	  assert_equal true, @tb.equals(tb2)
	end

	context "its copy method" do
	  setup do
	    @tb2 = @tb.copy
	  end

	  should "return an instance of TestBoxed" do
	    assert_instance_of Everything::TestBoxed, @tb2
	  end

	  should "copy fields" do
	    assert_equal 123, @tb2[:some_int8]
	  end

	  should "create a true copy" do
	    @tb[:some_int8] = 89
	    assert_equal 123, @tb2[:some_int8]
	  end
	end
      end
    end

    context "the Everything::TestEnum type" do
      should "be of type FFI::Enum" do
	assert_instance_of FFI::Enum, Everything::TestEnum
      end
    end

    # TestFlags

    context "the Everything::TestFloating class" do
      context "an instance" do
	setup do
	  @o = Everything::TestFloating.new
	end

	should "have a reference count of 1" do
	  assert_equal 1, ref_count(@o)
	end

	should "have been sunk" do
	  assert !is_floating?(@o)
	end
      end
    end

    context "the Everything::TestObj class" do
      should "create an instance using #new_from_file" do
	o = Everything::TestObj.new_from_file("foo")
	assert_instance_of Everything::TestObj, o
      end

      should "create an instance using #new_callback" do
	o = Everything::TestObj.new_callback Proc.new { }, nil, nil
	assert_instance_of Everything::TestObj, o
      end

      should "have a working #static_method" do
	rv = Everything::TestObj.static_method 623
	assert_equal 623.0, rv
      end

      should "have a working #static_method_callback" do
	a = 1
	Everything::TestObj.static_method_callback Proc.new { a = 2 }
	assert_equal 2, a
      end

      context "an instance" do
	setup do
	  @o = Everything::TestObj.new_from_file("foo")
	end

	should "have a reference count of 1" do
	  assert_equal 1, ref_count(@o)
	end

	should "not float" do
	  assert !is_floating?(@o)
	end

	should "have a working (virtual) #matrix method" do
	  rv = @o.matrix "bar"
	  assert_equal 42, rv
	end

	should "have a working #set_bare method" do
	  obj = Everything::TestObj.new_from_file("bar")
	  rv = @o.set_bare obj
	  # TODO: What is the correct value to retrieve from the fields?
	  assert_equal obj.to_ptr, @o[:bare]
	end

	should "have a working #instance_method method" do
	  rv = @o.instance_method
	  assert_equal(-1, rv)
	end

	should "have a working #torture_signature_0 method" do
	  y, z, q = @o.torture_signature_0(-21, "hello", 13)
	  assert_equal [-21, 2 * -21, "hello".length + 13],
	    [y, z, q]
	end

	context "its #torture_signature_1 method" do
	  should "work for m even" do
	    ret, y, z, q = @o.torture_signature_1(-21, "hello", 12)
	    assert_equal [true, -21, 2 * -21, "hello".length + 12],
	      [ret, y, z, q]
	  end

	  should "throw an exception for m odd" do
	    assert_raises RuntimeError do
	      @o.torture_signature_1(-21, "hello", 11)
	    end
	  end
	end

	should "have a working #instance_method_callback method" do
	  a = 1
	  @o.instance_method_callback Proc.new { a = 2 }
	  assert_equal 2, a
	end

	should "not respond to #static_method" do
	  assert_raises(NoMethodError) { @o.static_method 1 }
	end
      end
    end

    context "the Everything::TestSimpleBoxedA class" do
      should "create an instance using #new" do
	obj = Everything::TestSimpleBoxedA.new
	assert_instance_of Everything::TestSimpleBoxedA, obj
      end

      context "an instance" do
	setup do
	  @obj = Everything::TestSimpleBoxedA.new
	  @obj[:some_int] = 4236
	  @obj[:some_int8] = 36
	  @obj[:some_double] = 23.53
	  @obj[:some_enum] = :value2
	end

	context "its equals method" do
	  setup do
	    @ob2 = Everything::TestSimpleBoxedA.new
	    @ob2[:some_int] = 4236
	    @ob2[:some_int8] = 36
	    @ob2[:some_double] = 23.53
	    @ob2[:some_enum] = :value2
	  end

	  should "return true if values are the same" do
	    assert_equal true, @obj.equals(@ob2)
	  end

	  should "return true if enum values differ" do
	    @ob2[:some_enum] = :value3
	    assert_equal true, @obj.equals(@ob2)
	  end

	  should "return false if other values differ" do
	    @ob2[:some_int] = 1
	    assert_equal false, @obj.equals(@ob2)
	  end
	end

	context "its copy method" do
	  setup do
	    @ob2 = @obj.copy
	  end

	  should "return an instance of TestSimpleBoxedA" do
	    assert_instance_of Everything::TestSimpleBoxedA, @ob2
	  end

	  should "copy fields" do
	    assert_equal 4236, @ob2[:some_int]
	    assert_equal 36, @ob2[:some_int8]
	    assert_equal 23.53, @ob2[:some_double]
	    assert_equal :value2, @ob2[:some_enum]
	  end

	  should "create a true copy" do
	    @obj[:some_int8] = 89
	    assert_equal 36, @ob2[:some_int8]
	  end
	end
      end
    end

    context "the Everything::TestStructA class" do
      context "an instance" do
	should "have a working clone method" do
	  a = Everything::TestStructA.new
	  a[:some_int] = 2556
	  a[:some_int8] = -10
	  a[:some_double] = 1.03455e20
	  a[:some_enum] = :value2

	  b = a.clone

	  assert_equal 2556, b[:some_int]
	  assert_equal(-10, b[:some_int8])
	  assert_equal 1.03455e20, b[:some_double]
	  assert_equal :value2, b[:some_enum]
	end
      end
    end

    # TestStructB
    # TestStructC
    # TestSubObj

    context "the Everything::TestWi8021x class" do
      should "create an instance using #new" do
	o = Everything::TestWi8021x.new
	assert_instance_of Everything::TestWi8021x, o
      end

      should "have a working #static_method" do
	assert_equal(-84, Everything::TestWi8021x.static_method(-42))
      end

      context "an instance" do
	setup do
	  @obj = Everything::TestWi8021x.new
	end

	should "set its boolean struct member with #set_testbool" do
	  @obj.set_testbool true
	  assert_equal 1, @obj[:testbool]
	  @obj.set_testbool false
	  assert_equal 0, @obj[:testbool]
	end

	should "get its boolean struct member with #get_testbool" do
	  @obj[:testbool] = 0
	  assert_equal false, @obj.get_testbool
	  @obj[:testbool] = 1
	  assert_equal true, @obj.get_testbool
	end

	should "get its boolean struct member with #get_property" do
	  @obj[:testbool] = 1
	  gv = GObject::Value.new
	  gv.init GObject.type_from_name "gboolean"
	  @obj.get_property "testbool", gv
	  assert_equal true, gv.get_boolean
	end
      end
    end

    # set_abort_on_error

    context "test_array_fixed_size_int_in" do
      should "return the correct result" do
	assert_equal 5 + 4 + 3 + 2 + 1, Everything.test_array_fixed_size_int_in([5, 4, 3, 2, 1])
      end

      should "raise an error when called with the wrong number of arguments" do
	assert_raises ArgumentError do
	  Everything.test_array_fixed_size_int_in [2]
	end
      end
    end

    should "have correct test_array_fixed_size_int_out" do
      assert_equal [0, 1, 2, 3, 4], Everything.test_array_fixed_size_int_out
    end

    should "have correct test_array_fixed_size_int_return" do
      assert_equal [0, 1, 2, 3, 4], Everything.test_array_fixed_size_int_return
    end

    should "have correct test_array_gint16_in" do
      assert_equal 5 + 4 + 3, Everything.test_array_gint16_in([5, 4, 3])
    end

    should "have correct test_array_gint32_in" do
      assert_equal 5 + 4 + 3, Everything.test_array_gint32_in([5, 4, 3])
    end

    should "have correct test_array_gint64_in" do
      assert_equal 5 + 4 + 3, Everything.test_array_gint64_in([5, 4, 3])
    end

    should "have correct test_array_gint8_in" do
      assert_equal 5 + 4 + 3, Everything.test_array_gint8_in([5, 4, 3])
    end

    should "have correct test_array_gtype_in" do
      t1 = GObject.type_from_name "gboolean"
      t2 = GObject.type_from_name "gint64"
      assert_equal "[gboolean,gint64,]", Everything.test_array_gtype_in([t1, t2])
    end

    should "have correct test_array_int_full_out" do
      assert_equal [0, 1, 2, 3, 4], Everything.test_array_int_full_out
    end

    should "have correct test_array_int_in" do
      assert_equal 5 + 4 + 3, Everything.test_array_int_in([5, 4, 3])
    end

    should "have correct test_array_int_in_take" do
      assert_equal 5 + 4 + 3, Everything.test_array_int_in_take([5, 4, 3])
    end

    should "have correct test_array_int_inout" do
      assert_equal [3, 4], Everything.test_array_int_inout([5, 2, 3])
    end

    should "have correct test_array_int_none_out" do
      assert_equal [1, 2, 3, 4, 5], Everything.test_array_int_none_out
    end

    should "have correct test_array_int_null_in" do
      assert_nothing_raised { Everything.test_array_int_null_in nil }
    end

    should "have correct test_array_int_null_out" do
      assert_equal nil, Everything.test_array_int_null_out
    end

    should "have correct test_array_int_out" do
      assert_equal [0, 1, 2, 3, 4], Everything.test_array_int_out
    end

    should "have correct test_async_ready_callback"

    should "have correct test_boolean" do
      assert_equal false, Everything.test_boolean(false)
      assert_equal true, Everything.test_boolean(true)
    end

    should "have correct test_boolean_false" do
      assert_equal false, Everything.test_boolean(false)
    end

    should "have correct test_boolean_true" do
      assert_equal true, Everything.test_boolean(true)
    end

    should "have correct test_cairo_context_full_return"
    should "have correct test_cairo_context_none_in"
    should "have correct test_cairo_surface_full_out"
    should "have correct test_cairo_surface_full_return"
    should "have correct test_cairo_surface_none_in"
    should "have correct test_cairo_surface_none_return"

    should "have correct test_callback" do
      result = Everything.test_callback Proc.new { 5 }
      assert_equal 5, result
    end

    context "the test_callback_user_data function" do
      should "return the callbacks return value" do
	result = Everything.test_callback_user_data Proc.new {|u| 5 }, nil
	assert_equal 5, result
      end

      should "handle boolean user_data" do
	a = false
	result = Everything.test_callback_user_data Proc.new {|u|
	  a = u
	  5
	}, true
	assert_equal true, a
      end
    end

    should "have correct test_gtype" do
      result = Everything.test_gtype 23
      assert_equal 23, result
    end

    should "have correct test_size" do
      assert_equal 2354, Everything.test_size(2354)
    end

    should "have correct test_value_return" do
      result = Everything.test_value_return 3423
      assert_equal 3423, result.get_int
    end

  end

end
