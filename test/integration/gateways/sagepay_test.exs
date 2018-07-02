defmodule Gringotts.Integration.Gateways.SagepayTest do
  # Integration tests for the Sagepay 
  #
  # Note that your tests SHOULD NOT directly call the Sagepay, but
  # all calls must be via Gringotts' public API as defined in `lib`gringotts.ex`

  use ExUnit.Case, async: true
  alias Gringotts.Gateways.Sagepay

  @moduletag :integration

  setup_all do
    Application.put_env(:gringotts, Gringotts.Gateways.Sagepay,
      [ 
        account_type: "your_secret_account_type",
        vendor: "your_secret_vendor",
        vendor_tx_code: "your_secret_vendor_tx_code"
      ]
    )
  end
  
  # Group the test cases by public api

  describe "purchase" do
  end

  describe "authorize" do
  end

  describe "capture" do 
  end

  describe "void" do
  end

  describe "refund" do
  end

  describe "environment setup" do
  end
end
