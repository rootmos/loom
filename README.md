# loom
[![Build Status](https://travis-ci.org/rootmos/loom.svg?branch=master)](https://travis-ci.org/rootmos/loom)

Run a local development [Arweave](https://www.arweave.org/) blockchain
with faucets and on-demand mining.

## Usage

## API
* `POST /loom/mine` triggers the mining of a new block
  (TODO: block until a new block is actually mined)
* `POST /loom/faucet`
  - Request:
    `{"beneficiary": "tQYrTlkGy6voW2sIFVnRspzV1ELl2uNueICftPyplY8", "quantity": 1000000000000}`
  - Response:
    `{"tx_id": "P7wXSetOmrlKpQCm_koGYa8pzRhULunmwANG63aVaTg"}`
* `GET /loom/faucet` returns a list of faucets the loom is using
* `POST /loom/stop` stops the loom and the Arweave node
* `/arweave/...` proxy requests to the [Arweave HTTP interface](https://github.com/ArweaveTeam/arweave/blob/master/http_iface_docs.md)
