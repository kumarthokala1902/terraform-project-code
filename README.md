OLake Terraform Deployment:

This Terraform setup spins up an AWS EC2 instance, installs Kubernetes (Minikube), and deploys the OLake application using Helm — all in one go.

I. Prerequisites:

    - AWS account + IAM user with EC2/S3 permissions.
    - SSH key pair created in AWS (name given as ssh_key_name).
    - Terraform v1.5+.
    - kubernetes and Helm

II. Setup Instructions:

1. Choosen the cloud provider as an aws
2. Create main.tf file, output.tf, variables.tf and proividers.tf  variables.tf, helm_values.tf, cloud-init.yaml
3. Without doing the hard code values and to secure the sencitive info i used the terraform concept to pass var values (ami_id, ssh_key_name, tfstate_bucket).

4. on main.tf 

data "aws_vpc" "default" {
  default = true
}

- Fetches the default AWS VPC & Subnets Automatically detects and uses your default VPC.

5. data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

- this dynamically looks up whatever default subnet AWS provides in your region.

6. Creates a Security Group:

    - Opens ports:
    - 22 → SSH access
    - 8000 → OLake UI access

7. Launches an EC2 Instance:

   - Uses the AMI and instance type you specify in Terraform variables.
   - Attaches your SSH key for secure login. (ssh -i key ubuntu@<public_ip>)
   - Runs a cloud-init.yaml script to install required dependencies (like Docker, Minikube, etc.).

8. helm_values.tf file:
  
  - This YAML config enables an NGINX ingress so you can access the OLake UI through  olake.local.
  - It exposes the app’s UI service on port 8000 within the cluster using ClusterIP.
  - It also sets up persistent storage (10Gi) so data isn’t lost when pods restart.

9. cloud_init.yaml file:

  - Your user_data (cloud-init) must install Docker, kubectl, minikube, helm and start minikube. Example minimal cloud-init.yaml
 
10. output.tf file:

  - It will outputs the instance-id and the instance-public-ip address at he bottom of the "terraform apply"



III. Steup Commands Sequence:

  1. terraform validate (pre configure the syntax)

  2. terraform init  -reconfigure -backend-config="bucket=terraform-state-olake"  -backend-config="key=firstKey"   -backend-config="region=us-east-1"

  3. terraform plan (a dry run of the code)

  4. terraform apply -auto-approve

  5. ssh -i key ubuntu@<public_ip>

  6. to Ensure the  /home/ubuntu/.kube/config exists Run:

      - minikube status
      - kubectl get nodes
      - kubectl get pods -A

  7. OLake deploy verification:

    - helm repo add olake https://datazip-inc.github.io/olake-helm
    - helm repo update
    - helm install olake olake/olake -f helm_values.yaml --set persistence.storageClass=standard

  8. Check Pods:

    - kubectl get pods -A | grep olake
    - kubectl get svc -A | grep olake

  9. Ensure Minikube ingress addon is enabled (cloud-init did that).

    - kubectl get ingress -A
    - minikube ip    # running locally; also we can use VM public IP

  10. open <VM_PUBLIC_IP> olake.local or http://olake.local

  11. UI olake will access through the web browser

  login -> admin/password

  12. terminated all the create servies by single terraform command

    - terraform destroy
    

  
                                      
                                      