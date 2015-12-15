Docker with prometheus service, setup to get metrics from itself and specified consul services.

Consul endpoint is set via env variable CONSUL_ADDR. Consul services are set via env variable CONSUL_SERVICES:

`prom-node,http-balancer,something`.

By default, CONSUL_SERVICES is `prom-node`, and CONSUL_ADDR is "127.0.0.1:8500".
