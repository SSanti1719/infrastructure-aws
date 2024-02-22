
# Terraform description

Terraform is utilized to orchestrate the creation of AWS infrastructure to support the operational needs of various solution components. This involves provisioning an S3 bucket to store files in zip format, which are subsequently deployed to different EC2 instances.

# Preconditions
1. **Install terraform.**

2. **AWS Account Creation:**
   If you haven't already, sign up for an AWS account at [AWS Official Website](https://aws.amazon.com/). Once you have created your account, you'll obtain an Access Key ID and Secret Access Key.

3. **Obtaining Access Key ID and Secret Access Key:**
   - Log in to your AWS Management Console.
   - Navigate to the IAM (Identity and Access Management) dashboard.
   - Select "Users" from the sidebar and choose the user whose credentials you want to use or create a new user.
   - Under the "Security credentials" tab, you can generate a new set of access keys by clicking on the "Create access key" button.

4. **Configuring Environment Variables:**
   - Once you have your Access Key ID and Secret Access Key, set them as environment variables.
   - Open your terminal or command prompt.
   - Use the following commands to set the environment variables:
     ```
     export AWS_ACCESS_KEY_ID=your-access-key-id
     export AWS_SECRET_ACCESS_KEY=your-secret-access-key
     ```
     Replace `your-access-key-id` and `your-secret-access-key` with your actual credentials.

5. **Verifying Configuration:**
   - To verify that the environment variables are properly set, you can run the following command in your terminal:
     ```
     echo $AWS_ACCESS_KEY_ID
     echo $AWS_SECRET_ACCESS_KEY
     ```
     This should output your Access Key ID and Secret Access Key respectively.

6. **Configuration:** Configure the 'general-variables' file to parameterize the variables according to their configuration in AWS.

7. **Configure the files to upload:** Within the 'src' folder, there is a requirement for 4 initial files responsible for uploading to the infrastructure, which will include api.zip, data.zip, indexer.zip, and zincsearch.zip. 

## Run project

Run project with terraform

```bash
ssh-keygen -f rsa -b 2048 -f key.pem -N ""
terraform fmt
terraform init
terraform validate
terraform apply
terraform show
terraform destroy
```

## Run projects locally and load terraform

To execute all components locally, you can use the following script in PowerShell with administrator privileges:

```powershell
local-test-ps1
```

To automate the loading of ZIP files for projects and execute Terraform, you can utilize the following script:

```powershell
pre-terraform.ps1
```
    