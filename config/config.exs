# This file is responsible for configuring your application
# and its dependencies. The Mix.Config module provides functions
# to aid in doing so.
use Mix.Config

# Note this file is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project.

# Sample configuration:
#
#     config :my_dep,
#       key: :value,
#       limit: 42

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"

# CHASE

# Test Credentials
config :gringotts, Gringotts.Gateways.Chase,
    username: "INTERLINE22",
    password: "TRAVELPA55",
    industry_type: "MO",
    merchant_id: "your_secret_merchant_id",
    terminal_id: "001",
    bin: "000002"

# Production Credentials
# config :gringotts, Gringotts.Gateways.Chase,
#     username: "INTVAC564741",
#     password: "jQkF33L5r3BZ",
#     industry_type: "MO",
#     merchant_id: "your_secret_merchant_id",
#     terminal_id: "001",
#     bin: "000002"
