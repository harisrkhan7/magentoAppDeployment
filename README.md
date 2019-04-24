Prerequisites:-
1. Terraform must be installed on the jump host.

#Program running instructions
In order to run this program, follow the steps below:-
1. Create a **rsa-key pair** with **private** and **public** files named **autoscalingKey** and **autoscalingKey.pub** respectively. 
2. Create **access_key** and **secret_key** for your user role configured in **AliCloud Role and Access Management Console**. 
3. Create **public_key** and **private_key** pair for your Magento account.
4. Use terraform init to initilise the infrastructure.
5. Use terraform plan to verify the resources to be created.
6. Use terraform apply to create the infrastructure.

Note:-
Variables can either be stored in a file named **terraform.tfvars** or can be supplied at runtime. You will be prompted for the variables if the file is not present.