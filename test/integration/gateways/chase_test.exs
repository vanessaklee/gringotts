defmodule Gringotts.Integration.Gateways.ChaseTest do
  # Integration tests for the Chase 
  #
  # Note that your tests SHOULD NOT directly call the Chase, but
  # all calls must be via Gringotts' public API as defined in `lib`gringotts.ex`

  use ExUnit.Case, async: true
  alias Gringotts.Gateways.Chase

  @moduletag :integration

  setup_all do
    Application.put_env(:gringotts, Gringotts.Gateways.Chase,
      [ 
        username: "your_secret_username",
        password: "your_secret_password",
        industry_type: "your_secret_industry_type",
        merchant_id: "your_secret_merchant_id",
        terminal_id: "your_secret_terminal_id"
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
