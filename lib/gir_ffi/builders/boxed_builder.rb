require 'gir_ffi/builders/registered_type_builder'
require 'gir_ffi/builders/with_layout'

module GirFFI
  module Builders
    # Implements the creation of a class representing boxed types.
    class BoxedBuilder < RegisteredTypeBuilder
      include WithLayout

      private

      def setup_class
        setup_layout
        setup_constants
        stub_methods
        setup_field_accessors
      end
    end
  end
end