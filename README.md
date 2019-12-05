# loom
[![Build Status](https://travis-ci.org/rootmos/loom.svg?branch=master)](https://travis-ci.org/rootmos/loom)
[![Docker Pulls](https://img.shields.io/docker/pulls/rootmos/loom)](https://hub.docker.com/r/rootmos/loom)

Run a local development [Arweave](https://www.arweave.org/) blockchain
with faucets and on-demand mining.

## Usage
Images are available on the [Docker Hub](https://hub.docker.com/r/rootmos/loom):
```shell
docker pull rootmos/loom
docker run --rm --publish 8000:8000 rootmos/loom
```

## API
* `POST /loom/mine` triggers the mining of a new block
  - Responds with the mined block
* `GET /loom/wait/:tx_id` waits for the transaction to get mined
  - Responds with the transaction
* `POST /loom/faucet`
  - Example request:
    `{"beneficiary": "tQYrTlkGy6voW2sIFVnRspzV1ELl2uNueICftPyplY8", "quantity": 1000000000000}`
  - Example response:
    `{"tx_id": "P7wXSetOmrlKpQCm_koGYa8pzRhULunmwANG63aVaTg"}`
* `GET /loom/faucet` returns a list of faucets the loom is using
* `POST /loom/stop` stops the loom and the Arweave node
* `/arweave/...` proxy requests to the [Arweave HTTP interface](https://github.com/ArweaveTeam/arweave/blob/master/http_iface_docs.md)
