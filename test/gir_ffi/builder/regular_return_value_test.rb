require 'gir_ffi_test_helper'

describe GirFFI::Builder::RegularReturnValue do
  let(:type_info) { Object.new }
  let(:var_gen) { GirFFI::VariableNameGenerator.new }
  let(:for_constructor) { "irrelevant" }
  let(:builder) { GirFFI::Builder::RegularReturnValue.new(var_gen,
                                                          type_info,
                                                          for_constructor) }

  before do
    stub(type_info).interface_type_name { 'Bar::Foo' }
  end

  describe "for :gint32" do
    before do
      stub(type_info).flattened_tag { :gint32 }
    end

    it "has no statements in #post" do
      builder.post.must_equal []
    end

    it "returns the result of the c function directly" do
      builder.callarg.must_equal "_v1"
      builder.retval.must_equal "_v1"
    end
  end

  describe "for :struct" do
    before do
      stub(type_info).flattened_tag { :struct }
    end

    it "wraps the result in #post" do
      builder.callarg.must_equal "_v1"
      builder.post.must_equal [ "_v2 = Bar::Foo.wrap(_v1)" ]
    end

    it "returns the wrapped result" do
      builder.callarg.must_equal "_v1"
      builder.retval.must_equal "_v2"
    end
  end

  describe "for :union" do
    before do
      stub(type_info).flattened_tag { :union }
    end

    it "wraps the result in #post" do
      builder.callarg.must_equal "_v1"
      builder.post.must_equal [ "_v2 = Bar::Foo.wrap(_v1)" ]
    end

    it "returns the wrapped result" do
      builder.callarg.must_equal "_v1"
      builder.retval.must_equal "_v2"
    end
  end

  describe "for :interface" do
    before do
      stub(type_info).flattened_tag { :interface }
    end

    describe "when the method is not a constructor" do
      let(:for_constructor) { false }

      it "wraps the result in #post" do
        builder.callarg.must_equal "_v1"
        builder.post.must_equal [ "_v2 = Bar::Foo.wrap(_v1)" ]
      end

      it "returns the wrapped result" do
        builder.callarg.must_equal "_v1"
        builder.retval.must_equal "_v2"
      end
    end

    describe "when the method is a constructor" do
      let(:for_constructor) { true }

      it "wraps the result in #post" do
        builder.callarg.must_equal "_v1"
        builder.post.must_equal [ "_v2 = self.constructor_wrap(_v1)" ]
      end

      it "returns the wrapped result" do
        builder.callarg.must_equal "_v1"
        builder.retval.must_equal "_v2"
      end
    end
  end

  describe "for :object" do
    before do
      stub(type_info).flattened_tag { :object }
    end

    describe "when the method is not a constructor" do
      let(:for_constructor) { false }

      it "wraps the result in #post" do
        builder.callarg.must_equal "_v1"
        builder.post.must_equal [ "_v2 = Bar::Foo.wrap(_v1)" ]
      end

      it "returns the wrapped result" do
        builder.callarg.must_equal "_v1"
        builder.retval.must_equal "_v2"
      end
    end

    describe "when the method is a constructor" do
      let(:for_constructor) { true }

      it "wraps the result in #post" do
        builder.callarg.must_equal "_v1"
        builder.post.must_equal [ "_v2 = self.constructor_wrap(_v1)" ]
      end

      it "returns the wrapped result" do
        builder.callarg.must_equal "_v1"
        builder.retval.must_equal "_v2"
      end
    end
  end

  describe "for :strv" do
    before do
      stub(type_info).flattened_tag { :strv }
    end

    it "wraps the result in #post" do
      builder.callarg.must_equal "_v1"
      builder.post.must_equal [ "_v2 = GLib::Strv.wrap(_v1)" ]
    end

    it "returns the wrapped result" do
      builder.callarg.must_equal "_v1"
      builder.retval.must_equal "_v2"
    end
  end

  describe "for :zero_terminated" do
    before do
      stub(type_info).flattened_tag { :zero_terminated }
    end

    it "wraps the result in #post" do
      builder.callarg.must_equal "_v1"
      # FIXME: This is almost certainly wrong, but matches original behavior.
      builder.post.must_equal [ "_v2 = GirFFI::InPointer.wrap(_v1)" ]
    end

    it "returns the wrapped result" do
      builder.callarg.must_equal "_v1"
      builder.retval.must_equal "_v2"
    end
  end

  describe "for :byte_array" do
    before do
      stub(type_info).flattened_tag { :byte_array }
    end

    it "wraps the result in #post" do
      builder.callarg.must_equal "_v1"
      builder.post.must_equal [ "_v2 = GLib::ByteArray.wrap(_v1)" ]
    end

    it "returns the wrapped result" do
      builder.callarg.must_equal "_v1"
      builder.retval.must_equal "_v2"
    end
  end

  describe "for :ptr_array" do
    before do
      stub(type_info).flattened_tag { :ptr_array }
    end

    it "wraps the result in #post" do
      builder.callarg.must_equal "_v1"
      builder.post.must_equal [ "_v2 = GLib::PtrArray.wrap(_v1)" ]
    end

    it "returns the wrapped result" do
      builder.callarg.must_equal "_v1"
      builder.retval.must_equal "_v2"
    end
  end

  describe "for :glist" do
    before do
      stub(type_info).flattened_tag { :glist }
      stub(type_info).element_type { :foo }
    end

    it "wraps the result in #post" do
      builder.callarg.must_equal "_v1"
      builder.post.must_equal [ "_v2 = GLib::List.wrap(:foo, _v1)" ]
    end

    it "returns the wrapped result" do
      builder.callarg.must_equal "_v1"
      builder.retval.must_equal "_v2"
    end
  end

  describe "for :gslist" do
    before do
      stub(type_info).flattened_tag { :gslist }
      stub(type_info).element_type { :foo }
    end

    it "wraps the result in #post" do
      builder.callarg.must_equal "_v1"
      builder.post.must_equal [ "_v2 = GLib::SList.wrap(:foo, _v1)" ]
    end

    it "returns the wrapped result" do
      builder.callarg.must_equal "_v1"
      builder.retval.must_equal "_v2"
    end
  end

  describe "for :ghash" do
    before do
      stub(type_info).flattened_tag { :ghash }
      stub(type_info).element_type { [:foo, :bar] }
    end

    it "wraps the result in #post" do
      builder.callarg.must_equal "_v1"
      builder.post.must_equal [ "_v2 = GLib::HashTable.wrap([:foo, :bar], _v1)" ]
    end

    it "returns the wrapped result" do
      builder.callarg.must_equal "_v1"
      builder.retval.must_equal "_v2"
    end
  end

  describe "for :array" do
    before do
      stub(type_info).flattened_tag { :array }
      stub(type_info).element_type { :foo }
    end

    it "wraps the result in #post" do
      builder.callarg.must_equal "_v1"
      builder.post.must_equal [ "_v2 = GLib::Array.wrap(:foo, _v1)" ]
    end

    it "returns the wrapped result" do
      builder.callarg.must_equal "_v1"
      builder.retval.must_equal "_v2"
    end
  end

  describe "for :c" do
    describe "with fixed size" do
      before do
        stub(type_info).flattened_tag { :c }
        stub(type_info).subtype_tag_or_class_name { ":foo" }
        stub(type_info).array_fixed_size { 3 }
      end

      it "converts the result in #post" do
        builder.callarg.must_equal "_v1"
        builder.post.must_equal [ "_v2 = GirFFI::ArgHelper.ptr_to_typed_array :foo, _v1, 3" ]
      end

      it "returns the wrapped result" do
        builder.callarg.must_equal "_v1"
        builder.retval.must_equal "_v2"
      end
    end

    describe "with separate size parameter" do
      let(:length_argument) { Object.new }
      before do
        stub(type_info).flattened_tag { :c }
        stub(type_info).subtype_tag_or_class_name { ":foo" }
        stub(type_info).array_fixed_size { -1 }

        stub(length_argument).retname { "bar" }
        builder.length_arg = length_argument
      end

      it "converts the result in #post" do
        builder.callarg.must_equal "_v1"
        builder.post.must_equal [ "_v2 = GirFFI::ArgHelper.ptr_to_typed_array :foo, _v1, bar" ]
      end

      it "returns the wrapped result" do
        builder.callarg.must_equal "_v1"
        builder.retval.must_equal "_v2"
      end
    end
  end

  describe "for :utf8" do
    before do
      stub(type_info).flattened_tag { :utf8 }
    end

    it "converts the result in #post" do
      builder.callarg.must_equal "_v1"
      builder.post.must_equal [ "_v2 = GirFFI::ArgHelper.ptr_to_utf8(_v1)" ]
    end

    it "returns the converted result" do
      builder.callarg.must_equal "_v1"
      builder.retval.must_equal "_v2"
    end
  end

  describe "for :void pointer" do
    before do
      stub(type_info).flattened_tag { :void }
      stub(type_info).pointer? { true }
    end

    it "has no statements in #post" do
      builder.post.must_equal []
    end

    it "returns the result of the c function directly" do
      builder.callarg.must_equal "_v1"
      builder.retval.must_equal "_v1"
    end
  end

  describe "for :void" do
    before do
      stub(type_info).flattened_tag { :void }
      stub(type_info).pointer? { false }
    end

    it "has no statements in #post" do
      builder.post.must_equal []
    end

    it "does not capture the result of the c function" do
      builder.cvar.must_be_nil
    end

    it "returns nothing" do
      builder.retval.must_be_nil
    end
  end
end