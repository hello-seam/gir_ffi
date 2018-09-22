# frozen_string_literal: true

require 'ffi-gobject_introspection/i_base_info'
require 'ffi-gobject_introspection/i_type_info'
require 'ffi-gobject_introspection/i_arg_info'

module GObjectIntrospection
  # Wraps a GICallableInfo struct; represents a callable, either
  # IFunctionInfo, ICallbackInfo or IVFuncInfo.
  class ICallableInfo < IBaseInfo
    def return_type
      ITypeInfo.wrap Lib.g_callable_info_get_return_type(self)
    end

    def caller_owns
      Lib.g_callable_info_get_caller_owns self
    end

    def may_return_null?
      Lib.g_callable_info_may_return_null self
    end

    def can_throw_gerror?
      Lib.g_callable_info_can_throw_gerror self
    end

    def n_args
      Lib.g_callable_info_get_n_args self
    end

    def arg(index)
      IArgInfo.wrap Lib.g_callable_info_get_arg(self, index)
    end
    ##
    build_array_method :args

    def skip_return?
      Lib.g_callable_info_skip_return self
    end

    def instance_ownership_transfer
      Lib.g_callable_info_get_instance_ownership_transfer self
    end
  end
end
