require 'gir_ffi/builders/argument_builder'
require 'gir_ffi/return_value_info'
require 'gir_ffi/error_argument_info'
require 'gir_ffi/builders/return_value_builder'
require 'gir_ffi/builders/error_argument_builder'
require 'gir_ffi/builders/null_argument_builder'
require 'gir_ffi/variable_name_generator'

module GirFFI
  module Builders
    # Implements the creation of a Ruby function definition out of a GIR
    # IFunctionInfo.
    class FunctionBuilder
      def initialize info
        @info = info
        vargen = GirFFI::VariableNameGenerator.new
        @argument_builders = @info.args.map {|arg| ArgumentBuilder.new vargen, arg }
        @return_value_builder = ReturnValueBuilder.new(vargen,
                                                       ReturnValueInfo.new(@info.return_type, @info.skip_return?),
                                                       @info.constructor?)
        @errarg = error_argument vargen
        @argument_builder_collection = ArgumentBuilderCollection.new(@return_value_builder,
                                                                     @argument_builders)
      end

      def generate
        code = "def #{qualified_method_name} #{method_arguments.join(', ')}"
        method_lines.each { |line| code << "\n  #{line}" }
        code << "\nend\n"
      end

      private

      def qualified_method_name
        "#{@info.method? ? '' : "self."}#{@info.safe_name}"
      end

      def lib_module_name
        "#{@info.safe_namespace}::Lib"
      end

      def error_argument vargen
        if @info.throws?
          ErrorArgumentBuilder.new vargen, ErrorArgumentInfo.new
        else
          NullArgumentBuilder.new
        end
      end

      def method_lines
        preparation + function_call + post_processing + return_statement
      end

      def return_statement
        if @argument_builder_collection.has_return_values?
          ["return #{@argument_builder_collection.return_value_names.join(', ')}"]
        else
          []
        end
      end

      def function_call
        ["#{capture}#{lib_module_name}.#{@info.symbol} #{function_call_arguments.join(', ')}"]
      end

      def method_arguments
        @argument_builders.map(&:method_argument_name).compact
      end

      def function_call_arguments
        ca = @argument_builders.map(&:callarg)
        ca << @errarg.callarg
        ca.unshift "self" if @info.method?
        ca.compact
      end

      def preparation
        pr = @argument_builders.map(&:pre_conversion)
        pr << @errarg.pre
        pr.flatten
      end

      def capture
        if has_capture?
          "#{@return_value_builder.capture_variable_name} = "
        else
          ""
        end
      end

      def post_processing
        # FIXME: Sorting knows too much about internals of ArgumentBuilder.
        args = @argument_builders.sort_by {|arg| arg.type_info.array_length}

        result = args.map {|arg| arg.post_conversion}.flatten
        result += @errarg.post
        result + @return_value_builder.post_conversion
      end

      def has_capture?
        @return_value_builder.is_relevant?
      end
    end
  end
end
