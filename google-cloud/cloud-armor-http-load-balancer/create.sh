export PROJECT_ID=$(gcloud config get-value project)

# Enable APIs
gcloud services enable compute.googleapis.com
gcloud services enable logging.googleapis.com        
gcloud services enable monitoring.googleapis.com

# Create VMs

gcloud compute instances create vm-1-b1 \
    --image-family debian-11 \
    --image-project debian-cloud \
    --tags http-lb \
    --zone us-central1-b \
    --metadata startup-script="#! /bin/bash
      sudo apt-get update
      sudo apt-get install apache2 -y
      sudo service apache2 restart
      echo '<html><body><h1>This is VM1-b1 in central1-b</h1></body></html>' | tee /var/www/html/index.html
      EOF"

gcloud compute instances create vm-1-b2 \
    --image-family debian-11 \
    --image-project debian-cloud \
    --tags http-lb \
    --zone us-central1-b \
    --metadata startup-script="#! /bin/bash
      sudo apt-get update
      sudo apt-get install apache2 -y
      sudo service apache2 restart
      echo '<html><body><h1>This is VM1-b2 in central1-b</h1></body></html>' | tee /var/www/html/index.html
      EOF"

# Create Unmanaged Instance Group

gcloud compute instance-groups unmanaged create vm-ig1  --zone us-central1-b

gcloud compute instance-groups set-named-ports vm-ig1 --named-ports http:80 --zone us-central1-b

gcloud compute instance-groups unmanaged add-instances vm-ig1 --instances vm-1-b1,vm-1-b2 --zone us-central1-b

# Create Load Balancer components

## Create Health Check

gcloud compute health-checks create http http-health-check --port 80

## Create Backend Services

gcloud compute backend-services create http-backend-service  --global-health-checks --global --protocol HTTP --health-checks http-health-check  --timeout 5m --port-name http

## Add the instance group to the backend service

gcloud compute backend-services add-backend http-backend-service --global --instance-group  vm-ig1 --instance-group-zone us-central1-b --balancing-mode UTILIZATION --max-utilization 0.8

## Create URL Map

gcloud compute url-maps create http-backend-service-url-map --default-service http-backend-service


## Create Proxy

gcloud compute target-http-proxies create default-http-backend-service-proxy --url-map http-backend-service-url-map

## Create Forwarding Rules

gcloud compute forwarding-rules create default-http-backend-service-proxy-forwarding-rule --target-http-proxy default-http-backend-service-proxy --ports 80 --global


## Create a Firewall Rule

gcloud compute firewall-rules create allow-http-lb-and-health \
   --source-ranges 130.211.0.0/22,35.191.0.0/16 \
   --target-tags http-lb \
   --allow tcp:80

# Cloud Armor Security Policy

## Create Security Policy
gcloud compute security-policies create rate-limit-and-deny-http --description "policy for http proxy rate limiting and IP deny"

## Create Source IP Range Blocking Rule
gcloud compute security-policies rules create 1000 --action deny --security-policy rate-limit-and-deny-http --description "deny test-server1" --src-ip-ranges  "enter-test-server-1ip-here"


## Create Rate Limit Rule
gcloud compute security-policies rules create 3000 --security-policy=rate-limit-and-deny-http --expression="true"  --action=rate-based-ban  --rate-limit-threshold-count=5 --rate-limit-threshold-interval-sec=60  --ban-duration-sec=300  --conform-action=allow  --exceed-action=deny-404  --enforce-on-key=IP

## Attach policy to TCP Proxy backend service:
gcloud compute backend-services update http-backend-service --security-policy rate-limit-and-deny-http --global

## enable logging
gcloud compute backend-services update http-backend-service --enable-logging --logging-sample-rate=1 --global

# Test

LB_IP=$(gcloud compute forwarding-rules describe default-http-backend-service-proxy-forwarding-rule  --global --format="value(IPAddress)")

curl $LB_IP