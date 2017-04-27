Dockerfile for building an image of ICAP enabled Antivirus server that is based on c-icap, clamav and Alpine Linux. 

As this is for **testing, researching and demonstration purposes only**, the clamav antivirus database does not contain any valid virus signatures, thus it will not detect any viruses. Again for the same purpose one may want to simulate a file being blocked by the antivirus engine. For that a custom antivirus signature is added that will recognize a particular and well known good file as a virus. That file is putty.exe. So if you want to test/demonstrate a file blocked by ICAP just transfer your putty.exe to the server.

**Freshclam** is also available to download actual antivirus definition files in case they are needed. 

## Build Instructions

- Get all needed files either by downloading the repository as a zip file:

  https://github.com/nkapashi/c_icapClamav/archive/master.zip

- Or alternatively:

  ```
  git clone https://github.com/nkapashi/c_icapClamav.git
  ```

- Navigate the the directory containing the Dockerfile and issue the following command:

```
docker build -t {imageName} .

Example: docker build -t icap .
```

Note: the '.' specifies the path to the Dockerfile. Docker and the container will need to have access to the Internet in order to download the needed packages.

The Dockerfile does most of the commands in a single run so the number of image layers is kept to a minimum.

## Usage

Start the container:

docker run --name icap -it icap

Note: depending on your Docker setup you may need to forward port **1344**.

Example:

docker run -p my_Ip_address:1344 --name icap -it icap

After all services are started the container will give a shell access. All scan activity is under the /var/log/c-icap/access.log.

