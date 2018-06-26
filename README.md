# AHOD-HPC
Azure Resource Manager Templates for Ad-Hoc On-Demand HPC clusters

<table>
<tr>
<td align="center">
Deploy cluster to an New VNET with Managed Disk
<br><br>
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fhirtanak%2FAHOD-HPC%2Fmaster%2Fazuredeploy_manageddisk.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png" />
</a>
</td>
<td align="center">
Deploy cluster to an New VNET with Managed Disk, HeadNode DS4_V2 with Premium Disk
<br><br>
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fhirtanak%2FAHOD-HPC%2Fmaster%2Fazuredeploy_manageddisk2.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png" />
</a>
</td></tr>
<tr>
<td align="center">
Deploy cluster to an New VNET with Managed Disk 20171011
<br><br>
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fhirtanak%2FAHOD-HPC%2Fmaster%2Fazuredeploy_manageddisk3.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png" />
</a>
</td>
<td align="center">
Deploy cluster to an New VNET with Managed Disk 20180405
<br><br>
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fhirtanak%2FAHOD-HPC%2Fmaster%2Fazuredeploy_manageddisk4.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png" />
</a>
</td></tr>
</table>

<br></br>
<b>Quickstart</b>

	1) Deploy ARM Template
		a. Click on the link above
		b. Select HPC available region
		c. Select vm size (H16m/H16mr or A8/A9) and quantity (make sure to have quota for it)
		d. Name, less than 10 characters
		e. License server IP, use default if in MSFT
		f. Benchmark model
	2) Wait for deployment (may be long if a larger model)
	3) Logon to machine IP listed in portal
	4) Navigate to /mnt/resource

<b>Architecture</b>

<img src="https://github.com/tanewill/5clickTemplates/blob/master/images/hpc_vmss_architecture.png"  align="middle" width="395" height="274"  alt="hpc_vmss_architecture" border="1"/> <br></br>
This template is designed to assist in the assessment of the ANSYS Fluent CFD package in the Microsoft Azure environment. It automatically downloads and configures Fluent. In addition it authenticates all of the nodes on the cluster and creates a common share directory to be used for each of the nodes. A Virtual Machine Jumpbox is created and a Virtual Machine Scale Set (VMSS) of the same type of machine is created. The VMSS enables easy scaling and quick deployment of the cluster. The Jumpbox serves as the head node. A network card is attached to the Jumpbox and placed in a Virtual Network. The Jumpbox and VMSS reside in the same virtual network. A public IP is assigned to the network with port 22 open. The Jumpbox can be accessed with the following command:

<code>ssh {username}@{vm-private-ip-address}</code>

Four Storage Accounts are created for the VMSS and one for the Jumpbox. An NFS file share is created from the head node's OS disk and shared with all of the VMSS nodes. This NFS share is located at /mnt/nfsshare/ No other file sharing or server is used. The Jumpbox and each of the nodes in the VMSS also have a data disk mounted at /mnt/resource/ that provides local storage space.

<b>Monitoring</b>
<br></br>
By default Ganglia is installed on the Jumbpox and all of the compute nodes. You can access this monitor by opening a web browser and navigating to the ip address of the Jumpbox /ganglia. For example
<code>http://11.22.33.44/ganglia</code>

Here you will find the health and status of all of the nodes in the cluster.

<b>Software Configuration</b>

A number of packages are installed during deployment in order to support the NFS share and the tools that are used to create the authentication. During the authentication phase of the deployment, files named <u>nodenames.txt</u> and <u>nodeips.txt</u> are placed in ~/bin. These are files that contain the names and ip addresses of all of the nodes in the VMSS a copy of the <u>nodenames.txt</u> is placed in <u>/mnt/resource/hosts</u>. Each of these nodes should be accesible with the following command:

<code>ssh {username}@{vm-private-ip-address}</code>

<b>Licensing</b>

The licensing is based on your license scheme and contract.

<b>Known Issues</b>

1. The Jumpbox takes the name given in the vmssName parameter and appends a 'jb' for its hostname. It is a known bug that Fluent will not properly communicate with the license server if the hostname is longer than 12 characters. The vmssName parameter is limited to 10 characters for that reason. 
2. H-Series VMs are only available in the South Central region, A8 and A9 VMs are only available in East US, North Central US, South Central US, West US, North Europe, West Europe, and Japan East.
