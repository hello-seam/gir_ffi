require 'gir_ffi/builders/return_value_builder'

module GirFFI
  module Builders
    # TODO: Make CallbackArgumentBuilder accept argument name
    # TODO: Fix name of #post method
    class CallbackArgumentBuilder < BaseArgumentBuilder
      def needs_outgoing_parameter_conversion?
        specialized_type_tag == :enum || super
      end

      def post
        if has_conversion?
          [ "#{retname} = #{post_conversion}" ]
        else
          []
        end
      end

      def inarg
        nil
      end

      def retval
        super if is_relevant?
      end

      def is_relevant?
        !is_void_return_value? && !arginfo.skip?
      end

      def retname
        @retname ||= if has_conversion?
                       @var_gen.new_var
                     else
                       callarg
                     end
      end

      private

      def has_conversion?
        is_closure || needs_outgoing_parameter_conversion?
      end

      def post_conversion
        if is_closure
          "GirFFI::ArgHelper::OBJECT_STORE[#{callarg}.address]"
        else
          outgoing_conversion callarg
        end
      end

      def is_void_return_value?
        specialized_type_tag == :void && !type_info.pointer?
      end
    end
  end
end
