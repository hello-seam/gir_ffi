# frozen_string_literal: true

module GirFFI
  module InfoExt
    # Extensions for GObjectIntrospection::IFunctionInfo needed by GirFFI
    module IFunctionInfo
      def argument_ffi_types
        super.tap do |types|
          types.unshift :pointer if method?
          types << :pointer if throws?
        end
      end

      def return_ffi_type
        return_type.to_ffi_type
      end
    end
  end
end

GObjectIntrospection::IFunctionInfo.include GirFFI::InfoExt::IFunctionInfo
