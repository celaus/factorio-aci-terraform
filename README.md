# A Terraform Script for Running a Factorio Server on Azure

This uses [Azure Container Instances](https://azure.microsoft.com/en-us/services/container-instances/) to create and run a server of the game [Factorio](https://factorio.com), based on the Docker image [factoriotools/factorio](https://hub.docker.com/r/factoriotools/factorio/). Additionally, there is a small management API included to start/stop the server.

The default is an instance with 2 cores and 4 gb memory, which costs about 83 € a month if it runs the entire time (+ a few cents for the storage). 

Included in this template are:
- ACI instance
- Azure Storage Account and file share for game state/settings/...
- A resource group
- An [Azure function to start/stop and check on the container](https://github.com/celaus/fn-manage-aci)
- A contributor role assignment for the function to the container instances. i.e. the function will have contributor permissions on your ACI

## Authentication 

To run this terraform script, you need an Azure subscription and the Azure CLI. Once you have that, and export an environment variable `TF_VAR_tenantid` and `TF_VAR_subid` to pass these values into the Terraform provider. 

[This guide](https://www.terraform.io/docs/providers/azurerm/guides/azure_cli.html) explains what's going on.

The provided Functions can be looked at [here](https://github.com/celaus/fn-manage-aci). The terraform template deploys a release (probably the latest, check [main.tf](main.tf)) from there as functions with a function-level authentication. In order to call the functions get the host key from the Function app via the [Azure Portal](https://portal.azure.com) or any other way you prefer. 

## Set up and Run

Use your favorite terminal, `cd` into the directory that contains the `main.tf` file and run these commands:

~~~bash
$ terraform init
Initializing the backend...

Initializing provider plugins...
- Checking for available provider plugins...
- Downloading plugin for provider "azurerm" (hashicorp/azurerm) 2.2.0...

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
$ terraform apply
 terraform apply

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_container_group.gameserv will be created
  + resource "azurerm_container_group" "gameserv" {
      + dns_name_label      = "safespacefactorio"
      + fqdn                = (known after apply)
      + id                  = (known after apply)
      + ip_address          = (known after apply)
      + ip_address_type     = "public"
      + location            = "westeurope"
      + name                = "factorio-gameserver"
      + os_type             = "Linux"
      + resource_group_name = "factorio"
      + restart_policy      = "Always"

      + container {
          + commands = (known after apply)
          + cpu      = 2
          + image    = "factoriotools/factorio"
          + memory   = 4
          + name     = "factoriogame"
[...]

Plan: 4 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

azurerm_resource_group.main: Creating...
[...]
azurerm_container_group.gameserv: Creation complete after 1m8s
~~~

... and you should be good to go. Check the deployment in the [portal](https://portal.azure.com) and while you are there you can get the keys for the function app. The handlers are all `GET` so use a browser to call `https://<dns_label>-ctrl.azurewebsites.net/api/status?code=<host key from the Azure function App>`. Instead of `/api/status` you can also call `/api/start` or `/api/stop` for the respective actions. 

## Configure Factorio

Use the [Azure Storage Exporer](https://azure.microsoft.com/en-us/features/storage-explorer/) to connect to the file share and edit the JSON files you find there.

# License

MIT