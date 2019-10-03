# frozen_string_literal: true

require 'gir_ffi_test_helper'

GirFFI.setup :GIMarshallingTests

describe GirFFI::Core do
  it 'sets up cairo as Cairo' do
    GirFFI.setup :cairo
    assert Object.const_defined?(:Cairo)
  end

  it 'sets up xlib, which has no shared library' do
    gir = GObjectIntrospection::IRepository.default
    gir.require 'xlib'
    assert_nil gir.shared_library('xlib'), 'Precondition for test failed'
    GirFFI.setup :xlib
  end

  it 'sets up dependencies' do
    save_module :GObject
    save_module :Regress
    GirFFI.setup :Regress
    assert Object.const_defined?(:GObject)
    restore_module :Regress
    restore_module :GObject
  end

  describe '.setup' do
    it 'passes the desired version down to the module builder' do
      expect(GirFFI::Builder).to receive(:build_module).with('Regress', '0.1')
      GirFFI.setup :Regress, '0.1'
    end
  end

  describe '::define_type' do
    describe 'without a block' do
      before do
        @klass = Class.new GIMarshallingTests::OverridesObject
        Object.const_set "DerivedA#{Sequence.next}", @klass
        @gtype = GirFFI.define_type @klass
      end

      it 'returns a GType for the derived class' do
        parent_gtype = GIMarshallingTests::OverridesObject.gtype
        _(@gtype).wont_equal parent_gtype
        _(GObject.type_name(@gtype)).must_equal @klass.name
      end

      it 'makes #gtype on the registered class return the new GType' do
        _(@klass.gtype).must_equal @gtype
      end

      it 'registers a type with the same size as the parent' do
        q = GObject.type_query @gtype
        _(q.instance_size).must_equal GIMarshallingTests::OverridesObject::Struct.size
      end

      it 'creates a struct class for the derived class with just one member' do
        _(@klass::Struct.members).must_equal [:parent]
      end

      it 'allows the new class to be instantiated' do
        obj = @klass.new
        type = GObject.type_from_instance obj
        _(type).must_equal @gtype
      end
    end

    describe 'with a block with a call to #install_property' do
      before do
        @klass = Class.new GIMarshallingTests::OverridesObject
        Object.const_set "DerivedB#{Sequence.next}", @klass
        @gtype = GirFFI.define_type @klass do |info|
          info.install_property GObject.param_spec_int('foo', 'foo bar',
                                                       'The Foo Bar Property',
                                                       10, 20, 15,
                                                       3)
        end
      end

      it 'registers a type that is bigger than the parent' do
        q = GObject.type_query @gtype
        _(q.instance_size).must_be :>, GIMarshallingTests::OverridesObject::Struct.size
      end

      it 'gives the types Struct the fields :parent and :foo' do
        _(@klass::Struct.members).must_equal [:parent, :foo]
      end

      it 'creates accessor functions for the property' do
        obj = @klass.new
        obj.foo = 13
        _(obj.foo).must_equal 13
      end
    end
  end
end
