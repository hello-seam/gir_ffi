# frozen_string_literal: true
module GirFFI
  # Represents a null-terminated array.
  class ZeroTerminated
    include Enumerable

    attr_reader :element_type

    def initialize(elm_t, ptr)
      @element_type = elm_t
      @ptr = ptr
    end

    def to_ptr
      @ptr
    end

    def self.from(type, arg)
      new type, InPointer.from_array(type, arg)
    end

    def self.wrap(type, arg)
      new type, arg
    end

    def each
      return if @ptr.null?
      offset = 0
      while (val = read_value(offset))
        offset += ffi_type_size
        yield wrap_value(val)
      end
    end

    def ==(other)
      to_a == other.to_a
    end

    private

    def read_value(offset)
      val = fetch_value(offset)
      val unless val.zero?
    end

    def getter_method
      @getter_method ||= "get_#{ffi_type}"
    end

    def fetch_value(offset)
      case ffi_type
      when Module
        ffi_type.get_value_from_pointer(@ptr, offset)
      when Symbol
        @ptr.send(getter_method, offset)
      else
        raise NotImplementedError
      end
    end

    def wrap_value(val)
      case element_type
      when Array
        element_type.last.wrap val
      when Class
        element_type.wrap val
      else
        val
      end
    end

    def ffi_type
      @ffi_type ||= TypeMap.type_specification_to_ffi_type element_type
    end

    def ffi_type_size
      @ffi_type_size ||= FFI.type_size(ffi_type)
    end
  end
end
