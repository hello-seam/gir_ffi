require 'gir_ffi/builders/base_argument_builder'
require 'gir_ffi/builders/c_to_ruby_convertor'
require 'gir_ffi/builders/closure_convertor'
require 'gir_ffi/builders/null_convertor'

module GirFFI
  module Builders
    class CallbackArgumentBuilder < BaseArgumentBuilder
      def method_argument_name
        @method_argument_name ||= name || new_variable
      end

      def pre_converted_name
        @pre_converted_name ||= new_variable
      end

      def call_argument_name
        if direction == :in
          pre_converted_name unless array_arg
        end
      end

      def capture_variable_name
        if direction == :out
          @capture_variable_name ||= new_variable
        end
      end

      def pre_conversion
        case direction
        when :in
          [ "#{pre_converted_name} = #{pre_convertor.conversion}" ]
        when :out
          [ "#{pre_converted_name} = #{out_parameter_preparation}" ]
        end
      end

      def post_conversion
        if direction == :out
          [ "#{pre_converted_name}.set_value #{capture_variable_name}" ]
        else
          []
        end
      end

      private

      def pre_convertor
        @pre_convertor ||= if is_closure
                             ClosureConvertor.new(method_argument_name)
                           elsif type_info.needs_conversion_for_callbacks?
                             CToRubyConvertor.new(type_info,
                                                  method_argument_name,
                                                  length_argument_name)
                           else
                             NullConvertor.new(method_argument_name)
                           end
      end

      def out_parameter_preparation
        type_spec = type_info.tag_or_class
        # We theoretically have to do the allocation. Since caller_allocates is
        # false by default, we must also check that the type is a pointer. For
        # example, gint8* will always be allocate by the caller. For callbacks,
        # this is not us.
        # TODO: Refactor
        if !@arginfo.caller_allocates? && type_info.pointer?
          case specialized_type_tag
          when :zero_terminated
            # FIXME: Do something!
            "GirFFI::InOutPointer.new(#{type_spec.inspect}, #{method_argument_name})"
          when :object
            "GirFFI::InOutPointer.new(#{type_spec.inspect}, #{method_argument_name})"
          when :gint8
            "GirFFI::InOutPointer.new(#{type_spec[1].inspect})" +
              ".tap { |ptr| #{method_argument_name}.put_pointer 0, ptr }"
          else
            raise "Don't know what to do about #{specialized_type_tag}"
          end
        else
          "GirFFI::InOutPointer.new(#{type_spec.inspect}, #{method_argument_name})"
        end
      end

      def length_argument_name
        length_arg && length_arg.pre_converted_name
      end

      def is_void_return_value?
        specialized_type_tag == :void && !type_info.pointer?
      end
    end
  end
end
