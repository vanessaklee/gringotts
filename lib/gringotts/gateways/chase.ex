defmodule Gringotts.Gateways.Chase do
  @moduledoc """
  [Chase][home] gateway implementation.
  
  ## Supported Chase Complex Type options

  > Update Token: <AccountUpdater>
  > Purchase/Refund: <NewOrder>
  > Token: <Profile>

  ## Registering your Chase account at `Gringotts`

  > Here's how the secrets map to the required configuration parameters for Chase:
  > 
  > | Config parameter | Chase secret   |
  > | -------          | ----           |
  > | `:username`     | **Username**  |
  > | `:password`     | **Password**  |
  > | `:industry_type`     | **IndustryType**  |
  > | `:merchant_id`     | **MerchantId**  |
  > | `:terminal_id`     | **TerminalId**  |
  > | ':bin'     | **Bin**     |
  
  > Your Application config **must include the `[:username, :password, :industry_type, :merchant_id, :terminal_id]` field(s)** and would look
  > something like this:
  > 
  >     config :gringotts, Gringotts.Gateways.Chase,
  >         username: "your_secret_username"
  >         password: "your_secret_password"
  >         industry_type: "your_secret_industry_type"
  >         merchant_id: "your_secret_merchant_id"
  >         terminal_id: "your_secret_terminal_id"
  >         bin: "your_secrent_bin"

  ### Definition of Terms

  - Industry Type: The Industry Type for your merchant account can be found by logging into your Orbital Virtual Terminal and viewing the setup for your merchant ID (MID). Alternatively, you can also contact your Chase Orbital Account Executive or Orbital support to determine which default Industry Type is set up for your MID(s).  
  - Merchant ID: The merchant ID (MID) is the merchant account number assigned to you by Chase Orbital. If you have more than one Merchant ID number, you can set up multiple gateway configurations for each Merchant ID number.
  - Terminal ID: Merchant Terminal ID assigned by Chase. All Salem Terminal IDs at present must be ‘001’. PNS Terminal ID’s can be from ‘001’ – ‘999’. Most are ‘001’.
  - Bin: Transaction Routing Definition Assigned by Chase Paymentech, i.e. Salem is 000001 & PNS is 000002 
  
  ## Process Flow for Chase
  If the credit card sent on a purchase is an American Express card, authorization is not required. For all other card types, authorization must be completed before purchase.
  
  1. Amex
     - purchase
  2. All other card types
     - authorization
        - success
          - purchase
            - success
              - succes response
        - error
          - report error
    - error
      - report error
  
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

  @url "https://orbitalvar1.chasepaymentech.com"
  # @url "https://orbital1.chasepaymentech.com"

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
    params = build_transaction(amount, card, opts, "Payment")

    :post
    |> commit("transactions", params, headers)
    |> respond()
  end

  # Returns formatted credit card expiry date from a `Gringotts.Creditcard`
  defp expiry_date(card) do
    expiry_date = card.month * 100 + card.year
    |> Integer.to_string()
    |> String.pad_leading(4, "0")
  end


  defp build_transaction(amount, card, opts, type) do
    {currency, value, _} = Money.to_integer(amount)
    config = Application.get_env(:gringotts, Gringotts.Gateways.Chase)
    message_type = "AC"
    terminal_id = "001"
    currency_code = 840
    currency_exponent = 2
    # AccountNum = credit card number (card.number)
    # CardSecVal = cvv2
    # Order Number = time <> resv_id

    card_sec_val_ind = case card.brand do
        "Visa" -> 1
        "Discover" -> 1
        _ -> 9
    end

    "<Request>
        <NewOrder> 
          <OrbitalConnectionUsername>" <> config[:username] <> "</OrbitalConnectionUsername> 
          <OrbitalConnectionPassword>" <> config[:passowrd] <> "</OrbitalConnectionPassword> 
          <IndustryType>" <> config[:industry_type] <> "</IndustryType>
          <MessageType>" <> message_type <> "</MessageType>
          <BIN>" <> config[:bin] <> "</BIN>
          <MerchantID>" <> config[:merchant_id] <> "</MerchantID>
          <TerminalID>" <> terminal_id <> "</TerminalID>
          <CardBrand></CardBrand>
          <AccountNum>" <> card.number <> "</AccountNum>
          <Exp>" <> expiry_date(card) <> "</Exp>
          <CurrencyCode>" <> currency_code <> "</CurrencyCode> 
          <CurrencyExponent>" <> currency_exponent <> "</CurrencyExponent>
          " <> card_sec_val_ind <> "
          <CardSecVal>" <> card.verification_code <> "</CardSecVal>
          <AVSzip>" <> opts[:zip] <> "</AVSzip>
          <AVSaddress1>" <> opts[:address1] <> "</AVSaddress1>
          <AVSaddress2>" <> opts[:address1] <> "</AVSaddress2>
          <AVScity>" <> opts[:city] <> "</AVScity>
          <AVSstate>" <> opts[:state] <> "</AVSstate>
          <AVSphoneNum></AVSphoneNum> 
          <AVSname>" <> CreditCard.full_name(card) <> "</AVSname>
          <AVScountryCode>" <> opts[:country] <> "</AVScountryCode>
          <OrderID>" <> opts[:order_number] <> "</OrderID>
          <Amount>" <> value <> "</Amount>
        </NewOrder> 
      </Request>"
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
  defp commit(:post, endpoint, params, headers) do
    HTTPoison.post(@url <> endpoint, params, headers)
  end

  defp commit(:get, endpoint, headers) do
    HTTPoison.get(@url <> endpoint, headers)
  end

  defp headers() do
    [
      {"Content-type", "application/PTI60"},
      {"MIME-Version", "1.1"},
      {"Content-transfer-encoding", "text"},
      {"Request-number", "1"},
      {"Document-type", "Request"},
    ]
  end

  # Parses Chase's response and returns a `Gringotts.Response` struct
  # in a `:ok`, `:error` tuple.
  # defp respond(chase.ex_response)
  defp respond({:ok, %{status_code: 200, body: body}}), do: "something"
  defp respond({:ok, %{status_code: status_code, body: body}}), do: "something"
  defp respond({:error, %HTTPoison.Error{} = error}), do: "something"
end
