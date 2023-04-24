REGION=europe-west1
ZONE=$REGION-b

# Private Service Connect with automatic DNS configuration

## Producer Setup
gcloud compute networks create producer-vpc --subnet-mode=custom

gcloud compute networks subnets create gce-subnet --range=172.16.20.0/28 --network=producer-vpc --region=$REGION

gcloud compute networks subnets create load-balancer-subnet --range=172.16.10.0/28 --network=producer-vpc

# reserve an IP address for the internal load balancer

# The purpose of the address resource is not applicable to external addresses.
# PURPOSE must be one of:
# - VPC_PEERING,
# - SHARED_LOADBALANCER_VIP,
# - GCE_ENDPOINT,
# - IPSEC_INTERCONNECT,
# - PRIVATE_SERVICE_CONNECT.

gcloud compute addresses create lb-ip \
    --subnet=load-balancer-subnet \
    --purpose=GCE_ENDPOINT \
    --region=$REGION


# Create the regional proxy subnets
#  PURPOSE must be one of:
#  - PRIVATE : Regular user created or automatically created subnet.
#  - INTERNAL_HTTPS_LOAD_BALANCER : Reserved for Internal HTTP(S) Load Balancing.
#  - REGIONAL_MANAGED_PROXY : Reserved for Regional HTTP(S) Load Balancing.
#  - PRIVATE_SERVICE_CONNECT : Reserved for Private Service Connect Internal Load Balancing.

# This role is required when the purpose is set to REGIONAL_MANAGED_PROXY or INTERNAL_HTTPS_LOAD_BALANCER. ROLE must be
# ACTIVE : The ACTIVE subnet that is currently used.
# BACKUP : The BACKUP subnet that could be promoted to ACTIVE.

gcloud compute networks subnets create proxy-subnet-europe-west \
  --purpose=REGIONAL_MANAGED_PROXY \
  --role=ACTIVE \
  --region=$REGION \
  --network=producer-vpc \
  --range=172.16.0.0/23

# Create the Private Service Connect NAT subnet

gcloud compute networks subnets create psc-nat-subnet \
    --network producer-vpc \
    --region $REGION \
    --range 100.100.10.0/24 \
    --purpose PRIVATE_SERVICE_CONNECT


## Firewall Rules
# Configure firewall rules to allow traffic between the Private Service Connect NAT subnet and the ILB proxy only subnet.

gcloud compute firewall-rules create allow-to-ingress-nat-subnet \
  --direction=INGRESS \
  --priority=1000 \
  --network=producer-vpc \
  --action=ALLOW --rules=all \
  --source-ranges=100.100.10.0/24

# Create the firewall rule to allow the Google Cloud health checks to reach the producer service (backend service) on TCP port 80.
gcloud compute firewall-rules create fw-allow-health-check \
    --network=producer-vpc \
    --action=allow \
    --direction=ingress \
    --source-ranges=130.211.0.0/22,35.191.0.0/16 \
    --rules=tcp:80

# Create an ingress allow firewall rule for the proxy-only subnet to allow the load balancer to communicate with backend instances on TCP port 80.
gcloud compute firewall-rules create fw-allow-proxy-only-subnet \
    --network=producer-vpc \
    --action=allow \
    --direction=ingress \
    --source-ranges=172.16.0.0/23 \
    --rules=tcp:80

# Cloud NAT is used in the codelab for software package installation since the VM instance does not have an external IP address.

gcloud compute routers create cloud-router-for-nat --network producer-vpc --region $REGION

gcloud compute routers nats create cloud-nat-us-central1 --router=cloud-router-for-nat --auto-allocate-nat-external-ips --nat-all-subnet-ip-ranges --region $REGION


## Create unmanaged instance group
gcloud compute instances create app-server-1 \
    --machine-type=e2-micro \
    --image-family debian-10 \
    --no-address \
    --image-project debian-cloud \
    --zone $ZONE \
    --subnet=gce-subnet \
    --metadata startup-script="#! /bin/bash
    sudo apt-get update
    sudo apt-get install apache2 -y
    sudo service apache2 restart
    echo 'Welcome to App-Server-1' | tee /var/www/html/index.html
    EOF"


gcloud compute instance-groups unmanaged create psc-instance-group --zone=$ZONE

gcloud compute instance-groups unmanaged set-named-ports psc-instance-group --zone=$ZONE --named-ports=http:80

gcloud compute instance-groups unmanaged add-instances psc-instance-group --zone=$ZONE --instances=app-server-1
````

## Configure the load balancer
gcloud compute health-checks create http http-health-check \
    --region=$REGION \
    --use-serving-port

gcloud compute backend-services create l7-ilb-backend-service \
      --load-balancing-scheme=INTERNAL_MANAGED \
      --protocol=HTTP \
      --health-checks=http-health-check \
      --health-checks-region=$REGION \
      --region=$REGION

gcloud compute backend-services add-backend l7-ilb-backend-service \
  --balancing-mode=UTILIZATION \
  --instance-group=psc-instance-group \
  --instance-group-zone=$ZONE \
  --region=$REGION

gcloud compute url-maps create l7-ilb-map \
    --default-service l7-ilb-backend-service \
    --region=$REGION

gcloud compute target-http-proxies create l7-ilb-proxy\
    --url-map=l7-ilb-map \
    --url-map-region=$REGION \
    --region=$REGION

 gcloud compute forwarding-rules create l7-ilb-forwarding-rule \
      --load-balancing-scheme=INTERNAL_MANAGED \
      --network=producer-vpc \
      --subnet=load-balancer-subnet \
      --address=lb-ip \
      --ports=80 \
      --region=$REGION \
      --target-http-proxy=l7-ilb-proxy \
      --target-http-proxy-region=$REGION

##  Create the Private Service Connect service attachment


# Create the service attachment
gcloud compute service-attachments create published-service \
  --region=$REGION \
  --producer-forwarding-rule=l7-ilb-forwarding-rule \
  --connection-preference=ACCEPT_AUTOMATIC \
  --nat-subnets=psc-nat-subnet \
  --domain-names=psc.euw1.gcp.abdennebi.com.


