# Terraform
1. Edit "providers.tf" and set your GCP project ID for the "bucket" attribute.
2. Edit "terraform.tfvars" and set your GCP Project ID for the "project" attribute
3. Create a GCP service account for your GCP Project and export/download the key as json. Upload the JSON file as a Github secret at the repository settings. Make sure to name the secret "GOOGLE_CREDENTIALS" and save it.
4. Call your terraform resources or modules at main.tf
5. Github Action will take care about your terraform deployment.

test