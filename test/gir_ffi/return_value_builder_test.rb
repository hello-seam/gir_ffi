require 'gir_ffi_test_helper'

describe GirFFI::ReturnValueBuilder do
  let(:type_info) { Object.new }
  let(:var_gen) { GirFFI::VariableNameGenerator.new }
  let(:for_constructor) { false }
  let(:skip) { false }
  let(:builder) { GirFFI::ReturnValueBuilder.new(var_gen,
                                                 type_info,
                                                 for_constructor,
                                                 skip) }
  let(:conversion_arguments) { [] }

  before do
    stub(type_info).interface_type_name { 'Bar::Foo' }
    stub(type_info).extra_conversion_arguments { conversion_arguments }
    stub(type_info).flattened_tag { flattened_tag }
  end

  describe "for :gint32" do
    let(:flattened_tag) { :gint32 }

    it "has no statements in #post" do
      builder.post.must_equal []
    end

    it "returns the result of the c function directly" do
      builder.callarg.must_equal "_v1"
      builder.retval.must_equal "_v1"
    end
  end

  describe "for :struct" do
    let(:flattened_tag) { :struct }

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
    let(:flattened_tag) { :union }

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
    let(:flattened_tag) { :interface }

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
    let(:flattened_tag) { :object }

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
    let(:flattened_tag) { :strv }

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
    let(:conversion_arguments) { [:foo] }
    let(:flattened_tag) { :zero_terminated }

    it "wraps the result in #post" do
      builder.callarg.must_equal "_v1"
      builder.post.must_equal [ "_v2 = GirFFI::ZeroTerminated.wrap(:foo, _v1)" ]
    end

    it "returns the wrapped result" do
      builder.callarg.must_equal "_v1"
      builder.retval.must_equal "_v2"
    end
  end

  describe "for :byte_array" do
    let(:flattened_tag) { :byte_array }

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
    let(:conversion_arguments) { [:foo] }
    let(:flattened_tag) { :ptr_array }

    it "wraps the result in #post" do
      builder.callarg.must_equal "_v1"
      builder.post.must_equal [ "_v2 = GLib::PtrArray.wrap(:foo, _v1)" ]
    end

    it "returns the wrapped result" do
      builder.callarg.must_equal "_v1"
      builder.retval.must_equal "_v2"
    end
  end

  describe "for :glist" do
    let(:conversion_arguments) { [:foo] }
    let(:flattened_tag) { :glist }

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
    let(:conversion_arguments) { [:foo] }
    let(:flattened_tag) { :gslist }

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
    let(:conversion_arguments) { [[:foo, :bar]] }
    let(:flattened_tag) { :ghash }

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
    let(:conversion_arguments) { [:foo] }
    let(:flattened_tag) { :array }

    it "wraps the result in #post" do
      builder.callarg.must_equal "_v1"
      builder.post.must_equal [ "_v2 = GLib::Array.wrap(:foo, _v1)" ]
    end

    it "returns the wrapped result" do
      builder.callarg.must_equal "_v1"
      builder.retval.must_equal "_v2"
    end
  end

  describe "for :error" do
    let(:flattened_tag) { :error }

    it "wraps the result in #post" do
      builder.callarg.must_equal "_v1"
      builder.post.must_equal [ "_v2 = GLib::Error.wrap(_v1)" ]
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
        builder.post.must_equal [ "_v2 = GLib::SizedArray.wrap(:foo, 3, _v1)" ]
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
        builder.post.must_equal [ "_v2 = GLib::SizedArray.wrap(:foo, bar, _v1)" ]
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
      builder.post.must_equal [ "_v2 = _v1.to_utf8" ]
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

    it "marks itself as irrelevant" do
      builder.is_relevant?.must_equal false
    end

    it "returns nothing" do
      builder.retval.must_be_nil
    end
  end

  describe "for a skipped return value" do
    let(:skip) { true }

    before do
      stub(type_info).flattened_tag { :uint32 }
      stub(type_info).pointer? { false }
    end

    it "has no statements in #post" do
      builder.post.must_equal []
    end

    it "marks itself as irrelevant" do
      builder.is_relevant?.must_equal false
    end

    it "returns nothing" do
      builder.retval.must_be_nil
    end
  end
end
