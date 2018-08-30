defmodule Gringotts.Gateways.Sagepay do
    @moduledoc """
    [Sagepay][home] gateway implementation.

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
    > per the Sagepay gateway docs.
    > A table suits really well for this.

    ## Optional or extra parameters

    Most `Gringotts` API calls accept an optional `Keyword` list `opts` to supply
    optional arguments for transactions with the gateway.

    > List all available (ie, those that will be supported by this module) keys, a
    > description of their function/role and whether they have been implemented
    > and tested.
    > A table suits really well for this.

    ## Registering your Sagepay account at `Gringotts`

    Explain how to make an account with the gateway and show how to put the
    `required_keys` (like authentication info) to the configuration.

    > Here's how the secrets map to the required configuration parameters for Sagepay:
    > 
    > | Config parameter | Sagepay secret   |
    > | -------          | ----           |
    > | `:account_type`     | **AccountType**  |
    > | `:vendor`     | **Vendor**  |
    > | `:vendor_tx_code`     | **VendorTxCode**  |

    > Your Application config **must include the `[:account_type, :vendor, :vendor_tx_code]` field(s)** and would look
    > something like this:
    > 
    >     config :gringotts, Gringotts.Gateways.Sagepay,
    >         account_type: "your_secret_account_type"
    >         vendor: "your_secret_vendor"
    >         vendor_tx_code: "your_secret_vendor_tx_code"


    ## Scope of this module

    > It's unlikely that your first iteration will support all features of the
    > gateway, so list down those items that are missing.

    ## Supported currencies and countries

    > It's enough if you just add a link to the gateway's docs or FAQ that provide
    > info about this.

    ## Following the examples

    1. First, set up a sample application and configure it to work with Sagepay.
    - You could do that from scratch by following our [Getting Started][gs] guide.
      - To save you time, we recommend [cloning our example
      repo][example] that gives you a pre-configured sample app ready-to-go.
          + You could use the same config or update it the with your "secrets"
          as described [above](#module-registering-your-monei-account-at-Sagepay).

    2. Run an `iex` session with `iex -S mix` and add some variable bindings and
    aliases to it (to save some time):
    ```
    iex> alias Gringotts.{Response, CreditCard, Gateways.Sagepay}
    iex> card = %CreditCard{first_name: "Jo",
                          last_name: "Doe",
                          number: "4200000000000000",
                          year: 2099, month: 12,
                          verification_code: "123", brand: "VISA"}
    ```

    > Add any other frequently used bindings up here.

    We'll be using these in the examples below.

    [gs]: https://github.com/aviabird/gringotts/wiki/
    [home]: https://www.sagepay.co.uk/
    [example]: https://github.com/aviabird/gringotts_example
    """

    # The Base module has the (abstract) public API, and some utility
    # implementations.  
    use Gringotts.Gateways.Base

    # The Adapter module provides the `validate_config/1`
    # Add the keys that must be present in the Application config in the
    # `required_config` list
    use Gringotts.Adapter, required_config: [:account_type, :vendor, :vendor_tx_code]

    alias Gringotts.{Money, CreditCard, Response}

    @currency "GBP"

    @doc """
    Transfers `amount` from the customer to the merchant.

    Sagepay attempts to process a purchase on behalf of the customer, by
    debiting `amount` from the customer's account by charging the customer's
    `card`.

    ## Note

    > If there's anything noteworthy about this operation, it comes here.

    ## Example

    > A barebones example using the bindings you've suggested in the `moduledoc`.
    """
    @spec purchase(Money.t, CreditCard.t(), keyword) :: {:ok | :error, Response}
    def purchase(amount, card = %CreditCard{}, opts) do
        # VendorTxCode for SagePay - unique identifier; must be saved
        {:ok, dt} = DateTime.from_naive(NaiveDateTime.utc_now, "Etc/UTC")
        vendor_tx_code = opts[:resv_id] <> "-" <> Integer.to_string(DateTime.to_unix(dt))

        params = build_charge_transaction(amount, card, vendor_tx_code, opts)
        config = Application.get_env(:gringotts, Gringotts.Gateways.Sagepay)

        :post
        |> commit(config[:purchase_url] <> "?" <> params, params)
        |> respond(vendor_tx_code)
    end

    @doc """
    Refunds the `amount` to the customer's account with reference to a prior transfer.

    > Refunds are allowed on which kinds of "prior" transactions?

    ## Note

    > The end customer will usually see two bookings/records on his statement. Is
    > that true for Sagepay?
    > Is there a limited time window within which a void can be perfomed?

    ## Examples

    iex> alias Gringotts.{Response, CreditCard, Gateways.Sagepay}
    iex> amount = Money.new(42, :USD)
    iex> card = %CreditCard{first_name: "Harry",last_name: "Potter",number: "4200000000000000",year: 2099, month: 12,verification_code:  "123",brand: "VISA"}
    iex> resp = Sagepay.purchase(amount, card, %{resv_id: "10101010", comp_code: 1003, ip_address: "107.92.60.80", zip: "78757", address1: "123 Pine", address2: nil, city: "London", country: "GB", order_number: "123", issue_number: nil})
    iex> opts =  %{resv_id: "10101010", comp_code: 1003, auth: resp["TxAuthNo"], original_trans_id: resp["VPSTxId"]})
    iex> Sagepay.refund(amount, resp["VPSTxId"], opts)


    - auth: auth values sent in response to a preauth or charge with auth
            - corresponds to column `auth` in cc_collect
            - corresponds to xml field `TxAuthNo` returned by SagePay
            - ex: 245221
        - original_trans_id: gateway assigned id for referefence
            - corresponds to column `echo_ref` in cc_collect
                - saved as `substr($gateway_response['VPSTxId'],0,23)`
            - corresponds to xml field `VPSTxId` returned by SagePay
            - ex: {E18F7492-1FD6-4EF0-E78
        - original_gateway_trans_id: gateway assigned id for referefence
            - NOT CURRENTLY SENT WITH REFUND REQUESTS
            - corresponds to column `echo_ref` in cc_collect
                - saved as `substr($gateway_response['VPSTxId'],0,23)`
                - originally created by `time() . '-' . $resv_id;`
            - ex: {E18F7492-1FD6-4EF0-E78
        - original_trans_key: secondary security k/v pair
            - NOT CURRENTLY SENT WITH REFUND REQUESTS
            - not currently stored in cc_collect
            - corresponds to xml field `SecurityKey` returned by SagePay
    """
    @spec refund(Money.t, String.t(), keyword) :: {:ok | :error, Response}
    def refund(amount, payment_id, opts) do
        params = build_refund_transaction(amount, payment_id, opts)
        config = Application.get_env(:gringotts, Gringotts.Gateways.Sagepay)

        :post
        |> commit(config[:refund_url] <> "?" <> params, params)
        |> respond(opts[:vendor_tx_code])
    end

    @doc """
    Builds the xml to send with a gateway charge request
    """
    def build_charge_transaction(amount, card, vendor_tx_code, opts) do
        {_currency, value, _} = Money.to_integer(amount)
        config = Application.get_env(:gringotts, Gringotts.Gateways.Sagepay)

        apply_3d_secure = if is_nil(opts[:issue_number]) do
            "2"
        else 
            "0"
        end

        opts = if !Map.has_key?(opts, :state), do: Map.put(opts, :state, ""), else: opts
        opts = if !Map.has_key?(opts, :city), do: Map.put(opts, :city, ""), else: opts

        base = "TxType=PAYMENT" <>
            "&Vendor=" <> vendor(opts[:comp_code]) <>
            "&VendorTxCode=" <> vendor_tx_code <>
            "&Amount=" <> Integer.to_string(value) <>
            "&Currency=" <> @currency <> 
            "&Description=" <> opts[:resv_id] <>
            "&CardHolder=" <> CreditCard.full_name(card) <> 
            "&CardNumber=" <> card.number <>
            "&ExpiryDate=" <> expiry_date(card) <>
            "&CV2=" <> card.verification_code <>
            "&CardType=" <> card.brand <>
            "&BillingFirstnames=" <> CreditCard.full_name(card) <>
            "&BillingSurname=" <> card.last_name <>
            "&BillingAddress1=" <> opts[:address1] <>
            "&BillingCity=" <> opts[:city] <> 
            "&BillingState=" <> opts[:state] <>
            "&BillingPostCode=" <> opts[:zip] <>
            "&BillingCountry=" <> opts[:country] <>
            "&ClientIPAddress=" <> opts[:ip_address] <>
            "&GiftAidPayment=" <> "0" <>
            "&ApplyAVSCV2=" <> "0" <>
            "&Apply3DSecure=" <> apply_3d_secure <>
            "&AccountType=" <> config[:account_type] 

        xml = if opts[:issue_number] do
            base <> "&IssueNumber=" <> opts[:issue_number]
        else
            base
        end

        URI.encode(xml)
    end

    @doc """
    Builds the xml to send with a gateway refund request

    ## PARAMETERS

    - amount: Money amount to charge
    - card
    - opts
        - auth: auth values sent in response to a preauth or charge with auth
            - corresponds to column `auth` in cc_collect
            - corresponds to xml field `TxAuthNo` returned by SagePay
            - ex: 245221
        - original_trans_id: gateway assigned id for referefence
            - corresponds to column `echo_ref` in cc_collect
                - saved as `substr($gateway_response['VPSTxId'],0,23)`
            - corresponds to xml field `VPSTxId` returned by SagePay
            - ex: {E18F7492-1FD6-4EF0-E78
        - original_gateway_trans_id: gateway assigned id for referefence
            - NOT CURRENTLY SENT WITH REFUND REQUESTS
            - corresponds to column `echo_ref` in cc_collect
                - saved as `substr($gateway_response['VPSTxId'],0,23)`
                - originally created by `time() . '-' . $resv_id;`
            - corresponds to xml field `VPSTxId` returned by SagePay
            - ex: {E18F7492-1FD6-4EF0-E78
        - original_trans_key: secondary security k/v pair
            - NOT CURRENTLY SENT WITH REFUND REQUESTS
            - not currently stored in cc_collect
            - corresponds to xml field `SecurityKey` returned by SagePay
        
    ## Examples

    iex> alias Gringotts.{Response, CreditCard, Gateways.Sagepay}
    iex> card = %CreditCard{first_name: "Jo",last_name: "Doe",number: "4200000000000000",year: 2099, month: 12,verification_code: "123", brand: "VISA"}
    iex> opts =  %{resv_id: "1234567",ip_address: ip,zip: "78757",address1: "123 Pine",address2: nil,city: "Austin",state: "TX",country: "US",order_number: "123",issue_number: nil}
    iex> 
    iex> opts =  %{resv_id: "1234567",ip_address: ip,zip: "78757",address1: "123 Pine",address2: nil,city: "Austin",state: "TX",country: "US",order_number: "123",issue_number: nil}
    """
    def build_refund_transaction(amount, payment_id, opts) do
        {_currency, value, _} = Money.to_integer(amount)
        
        opts = if !Map.has_key?(opts, :original_gateway_trans_id), do: Map.put(opts, :original_gateway_trans_id, ""), else: opts
        opts = if !Map.has_key?(opts, :original_trans_key), do: Map.put(opts, :original_trans_key, ""), else: opts

        IO.inspect opts

        xml = "TxType=REFUND" <>
            "&Vendor=" <> vendor(opts[:comp_code]) <>
            "&Amount=" <> Integer.to_string(value) <>
            "&Currency=" <> @currency <> 
            "&Description=" <> opts[:resv_id] <>
            "&RelatedVPSTxId=" <> payment_id <>
            "&RelatedVendorTxCode=" <> opts[:original_gateway_trans_id] <>
            "&RelatedSecurityKey=" <> opts[:original_trans_key] <>
            "&RelatedTxAuthNo=" <> opts[:auth]

        URI.encode(xml)
    end

    ###############################################################################
    #                                PRIVATE METHODS                              #
    ###############################################################################

    # Makes the request to Sagepay's network.
    # For consistency with other gateway implementations, make your (final)
    # network request in here, and parse it using another private method called
    # `respond`.
    def commit(:post, url, params) do
        options = [ssl: [{:versions, [:'tlsv1.2']}]]
        HTTPoison.post(url, params, headers(), options)
    end

    def headers() do
        [
            {"Content-type", "application/json"},
            {"MIME-Version", "1.1"},
            {"Request-number", "1"},
            {"Document-type", "Request"},
        ]
    end

    # Parses Sagepay's response and returns a `Gringotts.Response` struct
    # in a `:ok`, `:error` tuple.
    # defp respond(sagepay.ex_response)
    def respond({:ok, %{status_code: 200, body: body}}, vendor_tx_code) do 
        mapped = map_body(body) 
        %{status: mapped["Status"], status_code: 200, status_detail: mapped["StatusDetail"], body: body, vpstxid: mapped["VPSTxId"], security_key: mapped["SecurityKey"], vendor_tx_code: vendor_tx_code}
    end
    def respond({:ok, %{status_code: status_code, body: body}}, vendor_tx_code) do 
        mapped = map_body(body)
        %{status: mapped["Status"], status_code: status_code, status_detail: mapped["StatusDetail"], body: body, vpstxid: mapped["VPSTxId"], security_key: mapped["SecurityKey"], vendor_tx_code: vendor_tx_code} 
    end
    def respond({:error, %HTTPoison.Error{} = error}) do 
        IO.inspect error
        error
    end

    def divide_key_value_pairs(value) do
        list = String.split(value,"=")
        key = List.first(list)
        val = List.last(list)
        Map.put(%{}, String.to_atom(key), val)
    end

    def map_body(body) do
        String.split(body, "\r\n")
            |> Enum.map(&divide_key_value_pairs/1)
            |> Enum.reduce(fn x, y -> Map.merge(x, y, fn _k, v1, v2 -> v2 ++ v1 end) end)
    end

    def vendor(comp_code) do
        case comp_code do
            1003 -> "traveltis"
            1006 -> "traveltis"
            1007 -> "touchdownholida"
            1008 -> "touchdownholida"
        end
    end

    # Returns formatted credit card expiry date from a `Gringotts.Creditcard`
    def expiry_date(card) do
        month = card.month
        |> Integer.to_string()
        |> String.pad_leading(2, "0")

        cardyear = card.year
        |> Integer.to_string()
        year = case String.length(cardyear) do
          4 -> String.slice(cardyear, 2..3)
          _ -> cardyear
        end

        month <> year
    end

end
