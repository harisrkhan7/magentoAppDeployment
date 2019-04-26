# Program running instructions

Prerequisites:-
1. Terraform must be installed on the jump host.
2. Alicloud Account with programmatic access to a user role. In order to get programmatic access, you will need to create a key pair and save the **access_key** and **secret_key** for later use. 
3. Magento Marketplace Account with programmatic access. In order to get programmatic access, you will need to create a key pair and save the **private_key** and **public_key** for later use. 


Follow the steps below in order to run this program:-
1. Clone the git repository in the jump host.  
2. Create a **rsa-key pair** with **private** and **public** files named **autoscalingKey** and **autoscalingKey.pub** respectively in the repository directory. 
3. Copy the Alicloud and Magento keys in the file named terraform.tfvars. 
4. Use **terraform init** to initialise terraform in the directory.
5. Use **terraform plan** to generate a plan for the to be created resources. 
6. Use **terraform apply** to create the infrastructure.

Note:-
Variables can either be stored in a file named **terraform.tfvars** or can be supplied at runtime. You will be prompted for the variables if the file is not present.