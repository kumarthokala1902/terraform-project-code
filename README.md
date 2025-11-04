# terraform-project-code
Prereqs:
- AWS account + IAM user with EC2/S3 permissions.
- SSH key pair created in AWS (name given as ssh_key_name).
- Terraform v1.5+.

Steps:
1. Edit variables.tf or pass -var values (ami_id, ssh_key_name, tfstate_bucket).
2. terraform init
3. terraform apply -auto-approve
4. ssh ubuntu@<public_ip>
5. (Optional) cd /home/ubuntu && terraform apply -auto-approve to install Helm release via Helm provider on VM.
6. Access OLake UI: http://<VM_PUBLIC_IP>:8000 (login admin/password)