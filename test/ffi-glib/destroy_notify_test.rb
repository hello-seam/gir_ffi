# frozen_string_literal: true

require "gir_ffi_test_helper"

describe GLib::DestroyNotify do
  describe ".default" do
    it "removes the passed-in key from the callback store" do
      dummy_proc = "some-callback"
      GirFFI::CallbackBase.store_callback dummy_proc
      _(GirFFI::CallbackBase::CALLBACKS[dummy_proc]).must_equal dummy_proc

      user_data = GirFFI::ArgHelper.store dummy_proc
      GLib::DestroyNotify.default.call user_data

      _(GirFFI::CallbackBase::CALLBACKS[dummy_proc]).must_be_nil
    end
  end
end
