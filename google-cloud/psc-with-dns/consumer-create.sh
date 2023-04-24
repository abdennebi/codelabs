
REGION=europe-west1
ZONE=$REGION-b
PROJECT_ID=

gcloud services enable dns.googleapis.com
gcloud services enable servicedirectory.googleapis.com

# Create the consumer VPC network


gcloud compute networks create consumer-vpc --subnet-mode=custom

## create the subnet for the test instance.
gcloud compute networks subnets create db1-subnet --range=10.20.0.0/28 --network=consumer-vpc --region=$REGION

##  create a subnet for the consumer endpoint.
gcloud compute networks subnets create consumer-ep-subnet  --range=10.10.0.0/28 --network=consumer-vpc --region=$REGION

# Create the consumer endpoint (forwarding rule)

## create the static IP Address that will be used for the consumer endpoint.

gcloud compute addresses create psc-consumer-ip-1 --region=$REGION --subnet=consumer-ep-subnet --addresses 10.10.0.10

## create the consumer endpoint.
gcloud compute forwarding-rules create endpoint \
  --region=$REGION \
  --network=consumer-vpc \
  --address=psc-consumer-ip-1 \
  --target-service-attachment=projects/$PROJECT_ID/regions/$REGION/serviceAttachments/published-service

gcloud compute instances create db1 \
    --zone=$ZONE \
    --image-family=debian-10 \
    --image-project=debian-cloud \
    --subnet=db1-subnet \
    --no-address


gcloud compute firewall-rules create ssh-iap-consumer \
    --network consumer-vpc \
    --allow tcp:22 \
    --source-ranges=35.235.240.0/20

gcloud compute ssh db1 --zone=$ZONE  --tunnel-through-iap
