# Cloud Armor Demo

This demo creates one unmanaged instance group having two VMs exposing an HTTP server. The unmanaged group servers the traffic behind an HTTP Load Balancer.

The load balancer is protected by Google Cloud Armor security policy. The security policy have two example rules : one for "rate limiting" and an other for blocking an IP range.