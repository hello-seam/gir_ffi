# frozen_string_literal: true
require 'gir_ffi_test_helper'

describe GirFFI::InfoExt::IUnresolvedInfo do
  let(:klass) do
    Class.new do
      include GirFFI::InfoExt::IUnresolvedInfo
    end
  end

  let(:unresolved_info) { klass.new }

  describe '#to_ffi_type' do
    it 'returns the most generic type' do
      unresolved_info.to_ffi_type.must_equal :pointer
    end
  end
end
