# HOWTO: create and upload images with Packer


## Initial setup

### Installing Packer

* Download Packer from: [https://www.packer.io/downloads.html](https://www.packer.io/downloads.html) ([0.7.5 release](https://dl.bintray.com/mitchellh/packer/packer_0.7.5_linux_386.zip)).	

* Extract the archive and update your PATH environment variable to include the Packer's directory.

* Verify the installation with:

    ```
	tai@Sydney:~$ packer version
	Packer v0.7.5
    ```

### Setup OpenStack

* Create a `credentials.sh` file with the content:

    ```
	export OS_NO_CACHE='yes'
	unset SERVICE_TOKEN SERVICE_ENDPOINT OS_TENANT_ID
	export OS_USERNAME='foo'
	export OS_PASSWORD='bar'
	export OS_TENANT_NAME='00000000000000000000000000099999' # fic2lab tenant
	export OS_AUTH_URL='http://cloud.example.org:8181/v2.0'
	export OS_AUTH_TOKEN_URL='http://cloud.example.org:8181/v2.0/tokens'
	export OS_AUTH_TOK=$(keystone token-get | awk 'NR==5 {print $4}')
	export OS_REGION_NAME='Lannion'

	echo ${OS_USERNAME} 'authenticated'
	nova credentials
	```

* Make the authentification:

    ```
	(env)tai@Sydney:~$ source credentials.sh 
	foo authenticated
	+------------------+---------------------------------+
	| User Credentials | Value                           |
	+------------------+---------------------------------+
	| id               | foo                             |
	| name             | foo                             |
	| roles            | [{"id": 301, "name": "Member"}] |
	| roles_links      | []                              |
	| username         | foo                             |
	+------------------+---------------------------------+
	+---------+-------------------------------------------------------------+
	| Token   | Value                                                       |
	+---------+-------------------------------------------------------------+
	| expires | 2015-07-09T15:16:07Z                                        |
	| id      | 9fe2ff9ee4384b1894a90878d3e92bab                            |
	| tenant  | {"enabled": true, "description": "Tenant from IDM", "name": |
	|         | "FIC2Lab", "id": "00000000000000000000000000099999"}        |
	+---------+-------------------------------------------------------------+
    ```	

* Verify the setup:

    ```
	(env)tai@Sydney:~$ nova flavor-list
	+----+------------+-----------+------+-----------+---------+-------+-------------+-----------+
	| ID | Name       | Memory_MB | Disk | Ephemeral | Swap_MB | VCPUs | RXTX_Factor | Is_Public |
	+----+------------+-----------+------+-----------+---------+-------+-------------+-----------+
	| 1  | m1.tiny    | 512       | 0    | 0         |         | 1     | 1.0         | True      |
	| 2  | m1.small   | 2048      | 20   | 0         |         | 1     | 1.0         | True      |
	| 3  | m1.medium  | 4096      | 40   | 0         |         | 2     | 1.0         | True      |
	| 4  | WITGeneric | 1024      | 5    | 0         |         | 1     | 1.0         | True      |
	| 5  | m1.small.2 | 2048      | 20   | 20        |         | 1     | 1.0         | True      |
	+----+------------+-----------+------+-----------+---------+-------+-------------+-----------+
    ```


## Create and upload an image with Packer

### On the SE's side

* Create a directory named after your SE.
* Inside the new directory, create an `install.sh` file with execution rights. This file must contain all the required steps to setup a SE on an Ubuntu 14.04:
    * Install dependencies.
	* Download SE's archive.
	* Install SE.
	* Setup an automatic boot process for the SE. **It mustn't directly start the SE, because this file will be launch only once during the image's creation.**

	If the `install.sh` requires local files, they will be present in the same temporary directory during the installation step.
	This temporary directory will only exist during the installation step so the `install.sh` script must save/move any persistent files.

#### Packer's pitfalls

The OpenStack Packer's provisioner don't support the `"shutdown_command"` field yet. So Packer will abrutly stop the instance when it reaches the end of the `install.sh` script.
	
#### Examples for `install.sh`

##### Simple downloadable `.war` artifact

This example shows how to setup a tomcat server with an application.
The application's `war` file is recovered through an url.
This example can be found in the `packer-sample` directory.


##### Simple local `.war` artifact

This example shows how to use a local file during the installation.
First the `packer-feedsync` directory must contain the following files:

```
(.env)tai@Sydney:~/fic2-poc-basic_packer_examples$ tree packer-feedsync/
packer-feedsync/
├── feedsync.war
├── install.sh
└── README.md

0 directories, 3 files
```

This example is stored inside the `packer-feedsync` directory.
Packer is configured to upload the `dir` directory's content into a temporary directory.
During the installation, the current directory is saved in the `D` variable and the `feedsync.war` file is moved to the corresponding tomcat directory.


### On Filab side

#### Initial setup

* Create a floating ip: `nova floating-ip-create`

* Inspect the `ubuntu_14.04_x86-generic.json` file and tweak the various fields:
    * "flavor": the type of machine running the SE.
	* "source_image": the Ubuntu 14.04 base image's id.
	* "networks": the local network's id where the instances will get their private ip.
	* "floating_ip": the previously created floating ip.
	* "security_groups": the security group bound with the SE.

#### Use Packer

* Choose a SE's directory.

* Remove the image in glance if it already exists: `nova image-delete`.

* Launch Packer: `packer build -var 'dir=packer-sample' ubuntu_14.04_x86-generic.json`.

#### Result

If no errors occur during the installation, then Packer create a new image on glance:

```
==> openstack: Creating the image: packer-feedsync
==> openstack: Image: 9b1f9d57-f87b-4587-9a18-08b94141a008
==> openstack: Waiting for image to become ready...
==> openstack: Terminating the source server...
==> openstack: Deleting temporary keypair...
Build 'openstack' finished.

==> Builds finished. The artifacts of successful builds are:
--> openstack: An image was created: 9b1f9d57-f87b-4587-9a18-08b94141a008
```

The image can be listed with:

```
(env)tai@Sydney:~/projects/Others/filab-packer-rtc/feedsync$ nova image-list 
+--------------------------------------+-------------------------------+--------+--------------------------------------+
| ID                                   | Name                          | Status | Server                               |
+--------------------------------------+-------------------------------+--------+--------------------------------------+
| 9b1f9d57-f87b-4587-9a18-08b94141a008 | packer-sample __1421253240    | ACTIVE | 9059e615-65c8-4c1f-b959-21ed2b4ecb31 |
+--------------------------------------+-------------------------------+--------+--------------------------------------+
```


