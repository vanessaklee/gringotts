defmodule Gringotts.Gateways.Chase do
  @moduledoc """
  [Chase][home] gateway implementation.

  ## Instructions!
  
  ***This is an example `moduledoc`, and suggests some items that should be
  documented in here.***

  The quotation boxes like the one below will guide you in writing excellent
  documentation for your gateway. All our gateways are documented in this manner
  and we aim to keep our docs as consistent with each other as possible.
  **Please read them and do as they suggest**. Feel free to add or skip sections
  though.

  If you'd like to make edits to the template docs, they exist at
  `templates/gateway.eex`. We encourage you to make corrections and open a PR
  and tag it with the label `template`.

  ***Actual docs begin below this line!***
  
  --------------------------------------------------------------------------------

  > List features that have been implemented, and what "actions" they map to as
  > per the Chase gateway docs.
  > A table suits really well for this.

  ## Optional or extra parameters

  Most `Gringotts` API calls accept an optional `Keyword` list `opts` to supply
  optional arguments for transactions with the gateway.
  
  > List all available (ie, those that will be supported by this module) keys, a
  > description of their function/role and whether they have been implemented
  > and tested.
  > A table suits really well for this.

  ## Registering your Chase account at `Gringotts`

  Explain how to make an account with the gateway and show how to put the
  `required_keys` (like authentication info) to the configuration.
  
  > Here's how the secrets map to the required configuration parameters for Chase:
  > 
  > | Config parameter | Chase secret   |
  > | -------          | ----           |
  > | `:username`     | **Username**  |
  > | `:password`     | **Password**  |
  > | `:industry_type`     | **IndustryType**  |
  > | `:merchant_id`     | **MerchantId**  |
  > | `:terminal_id`     | **TerminalId**  |
  
  > Your Application config **must include the `[:username, :password, :industry_type, :merchant_id, :terminal_id]` field(s)** and would look
  > something like this:
  > 
  >     config :gringotts, Gringotts.Gateways.Chase,
  >         username: "your_secret_username"
  >         password: "your_secret_password"
  >         industry_type: "your_secret_industry_type"
  >         merchant_id: "your_secret_merchant_id"
  >         terminal_id: "your_secret_terminal_id"
  
  
  ## Scope of this module

  > It's unlikely that your first iteration will support all features of the
  > gateway, so list down those items that are missing.

  ## Supported currencies and countries

  > It's enough if you just add a link to the gateway's docs or FAQ that provide
  > info about this.

  ## Following the examples

  1. First, set up a sample application and configure it to work with Chase.
  - You could do that from scratch by following our [Getting Started][gs] guide.
      - To save you time, we recommend [cloning our example
      repo][example] that gives you a pre-configured sample app ready-to-go.
          + You could use the same config or update it the with your "secrets"
          as described [above](#module-registering-your-monei-account-at-Chase).

  2. Run an `iex` session with `iex -S mix` and add some variable bindings and
  aliases to it (to save some time):
  ```
  iex> alias Gringotts.{Response, CreditCard, Gateways.Chase}
  iex> card = %CreditCard{first_name: "Jo",
                          last_name: "Doe",
                          number: "4200000000000000",
                          year: 2099, month: 12,
                          verification_code: "123", brand: "VISA"}
  ```

  > Add any other frequently used bindings up here.

  We'll be using these in the examples below.

  [gs]: https://github.com/aviabird/gringotts/wiki/
  [home]: https://www.chasepaymentech.com/payment_gateway.html
  [example]: https://github.com/aviabird/gringotts_example
  """

  # The Base module has the (abstract) public API, and some utility
  # implementations.  
  use Gringotts.Gateways.Base

  # The Adapter module provides the `validate_config/1`
  # Add the keys that must be present in the Application config in the
  # `required_config` list
  use Gringotts.Adapter, required_config: [:username, :password, :industry_type, :merchant_id, :terminal_id]
  
  import Poison, only: [decode: 1]

  alias Gringotts.{Money,
                   CreditCard,
                   Response}

  @doc """
  Performs a (pre) Authorize operation.

  The authorization validates the `card` details with the banking network,
  places a hold on the transaction `amount` in the customer’s issuing bank.

  > ** You could perhaps:**
  > 1. describe what are the important fields in the Response struct
  > 2. mention what a merchant can do with these important fields (ex:
  > `capture/3`, etc.)
  
  ## Note

  > If there's anything noteworthy about this operation, it comes here.

  ## Example

  > A barebones example using the bindings you've suggested in the `moduledoc`.
  """
  @spec authorize(Money.t(), CreditCard.t(), keyword) :: {:ok | :error, Response}
  def authorize(amount, card = %CreditCard{}, opts) do
    # commit(args, ...)
  end

  @doc """
  Captures a pre-authorized `amount`.

  `amount` is transferred to the merchant account by Chase used in the
  pre-authorization referenced by `payment_id`.

  ## Note

  > If there's anything noteworthy about this operation, it comes here.
  > For example, does the gateway support partial, multiple captures?

  ## Example

  > A barebones example using the bindings you've suggested in the `moduledoc`.
  """
  @spec capture(String.t(), Money.t, keyword) :: {:ok | :error, Response}
  def capture(payment_id, amount, opts) do
    # commit(args, ...)
  end

  @doc """
  Transfers `amount` from the customer to the merchant.

  Chase attempts to process a purchase on behalf of the customer, by
  debiting `amount` from the customer's account by charging the customer's
  `card`.

  ## Note

  > If there's anything noteworthy about this operation, it comes here.

  ## Example

  > A barebones example using the bindings you've suggested in the `moduledoc`.
  """
  @spec purchase(Money.t, CreditCard.t(), keyword) :: {:ok | :error, Response}
  def purchase(amount, card = %CreditCard{}, opts) do
    # commit(args, ...)
  end

  @doc """
  Voids the referenced payment.

  This method attempts a reversal of a previous transaction referenced by
  `payment_id`.

  > As a consequence, the customer will never see any booking on his statement.

  ## Note

  > Which transactions can be voided?
  > Is there a limited time window within which a void can be perfomed?

  ## Example

  > A barebones example using the bindings you've suggested in the `moduledoc`.
  """
  @spec void(String.t(), keyword) :: {:ok | :error, Response}
  def void(payment_id, opts) do
    # commit(args, ...)
  end

  @doc """
  Refunds the `amount` to the customer's account with reference to a prior transfer.

  > Refunds are allowed on which kinds of "prior" transactions?

  ## Note

  > The end customer will usually see two bookings/records on his statement. Is
  > that true for Chase?
  > Is there a limited time window within which a void can be perfomed?

  ## Example

  > A barebones example using the bindings you've suggested in the `moduledoc`.
  """
  @spec refund(Money.t, String.t(), keyword) :: {:ok | :error, Response}
  def refund(amount, payment_id, opts) do
    # commit(args, ...)
  end

  @doc """
  Stores the payment-source data for later use.

  > This usually enable "One Click" and/or "Recurring Payments"

  ## Note

  > If there's anything noteworthy about this operation, it comes here.

  ## Example

  > A barebones example using the bindings you've suggested in the `moduledoc`.
  """
  @spec store(CreditCard.t(), keyword) :: {:ok | :error, Response}
  def store(%CreditCard{} = card, opts) do
    # commit(args, ...)
  end

  @doc """
  Removes card or payment info that was previously `store/2`d

  Deletes previously stored payment-source data.

  ## Note

  > If there's anything noteworthy about this operation, it comes here.

  ## Example

  > A barebones example using the bindings you've suggested in the `moduledoc`.
  """
  @spec unstore(String.t(), keyword) :: {:ok | :error, Response}
  def unstore(registration_id, opts) do
    # commit(args, ...)
  end

  ###############################################################################
  #                                PRIVATE METHODS                              #
  ###############################################################################
  
  # Makes the request to Chase's network.
  # For consistency with other gateway implementations, make your (final)
  # network request in here, and parse it using another private method called
  # `respond`.
  defp commit(_) do
    # resp = HTTPoison.request(args, ...)
    # respond(resp, ...)
  end

  # Parses Chase's response and returns a `Gringotts.Response` struct
  # in a `:ok`, `:error` tuple.
  defp respond(chase.ex_response)
  defp respond({:ok, %{status_code: 200, body: body}}), do: "something"
  defp respond({:ok, %{status_code: status_code, body: body}}), do: "something"
  defp respond({:error, %HTTPoison.Error{} = error}), do: "something"
end
