# Nexus 3 as Docker Registry

Sonatype provides documentation and blog posts for configuring Nexus 3 as a Docker registry. Some of the blog post references appear at the end. Here is their help documenation:

- <https://help.sonatype.com/repomanager3/private-registry-for-docker>
  
  This is Sonatype's most complete guidance on using Nexus 3 as a Docker registry. However, I found it hard to follow without a better understanding of the expected end-behavior resulting from following their configuration guidance. Also, the configuration doesn't address running all components (including Nexus) from a Docker container. The solution I document here is fully containerized and uses encrypted connections to a reverse proxy to front access to Nexus 3. This approach simplifies SSL/TLS configuration to Nexus 3 and potentially other endpoints behind the proxy.

## Suggested Approach

1. Ensure you have the Docker daemon running locally. If you're using Docker for Windows, ensure that it is configured to run Linux containers.
2. Read the Overview section.
3. Read the Working Example section and carefully work through the relatively brief setup.
4. Read and try the steps in the Testing the Working Example section to interact with a Nexus hosted Docker registry.

## Overview

If you aren't familiar with things like a Docker registry, Docker images or Docker containers, please visit <https://docs.docker.com/> to learn more about Docker. That will help you get the most out of this post.

Many organizations want to have insight into what docker images are made available to their development or operations groups in a managed Docker registry. An internal registry hosted in Nexus 3 satisfies that requirement. Nexus uses the concept of repositories as storage endpoints for artifacts, such as JAR files. Repositories also serve as the model for storing Docker images.

### Workflow

The general workflow in a CI/CD pipeline is that a development team would continue to push compiled artifacts, like JAR or WAR files into a Nexus repository, the maven2 (hosted) repository type upon the succesful completion of a build. Later in the same pipeline, the orchestrator, Jenkins for example, would retrieve an image from a Nexus repository, docker (group) repository type and then deploy a compiled artifact into the Docker image in order to create a new Docker image. That new Docker image would then be pushed back to a Nexus repository, docker (hosted) repository type. Further down in the pipeline, Jenkins would then pull the new Docker image containing the compiled artifact and deploy the image as a running Docker container into an environment, such as Dev, QA or Prod.

The third repository type used for Docker is docker (proxy). It's to this repository that any missing base images can be retrieved. The docker (proxy) can be configured to connect to Docker hub or perhaps some other docker registry, such as Amazon ECR (Elastic Container Registry) endpoint instead. The use of the hosted, group and proxy repository types are a common pattern in Nexus for all Nexus repository types or recipes, as it's called in Nexus.

### Docker Client Interaction

There are two Docker client related issues around interfacing with Nexus:

- context-path
- encryption

#### Context-path

Well documented in Sonatype help is the fact that Docker doesn't use a context-path to push images to a Docker registry. This means that you can't push images to Nexus using the context-path part of the request and expect the image to appear in a specific repository that maps to that path context. For details on this issue, see the SSL and Repository Connector Configuration section at <https://help.sonatype.com/repomanager3/private-registry-for-docker/ssl-and-repository-connector-configuration>. The solution is to have a unique IP port assigned to the repository. I'll demonstrate that in the working example.

#### Encryption

By default, the Docker client expects that it will communicate with an endpoint over an encrypted connection (SSL) via HTTPS. Either Nexus 3 can be configured to serve content via HTTPS or you can configure a reverse proxy that accepts encrypted requests from a Docker client and then forwards the request to Nexus 3 unencrypted via HTTP. Either way, some endpoint has to be configured to use HTTPS and most reverse proxy's are easier to configure for HTTPS than Nexus is. However, either approach will work. In my example, I use a reverse proxy to handle the HTTPS request from a Docker client and route it to Nexus via HTTP.

### Containers Everywhere

In the working example, there are three actors, the Docker client, an nginx reverse proxy and a Nexus 3 endpoint. The reverse proxy and Nexus 3 endpoint are running in Docker containers. While on the surface, this might sound more complicated, it provides portability and scaling options that are harder to support in a VM or on metal.

## Working Example

I have created a toolchain demo in my public github repository. There is nothing in this repository specific to a company. However, the open source tools used in this repo are commonly used by many organizations.

### Important Certificate Warning and Prerequisites

You can either use your own certificates (including self-signed certs) if you're familiar with creating your own or you can use the ones I've provided. I generated all of these certificates, including the private key using OpenSSL. This certificate chain and key aren't used for anything but local development. Do not consider using these certificates in anything but your local development environment. Since the private key is anything but private, use it only for your local development environment. With that important warning in mind, here's how you use the included certificates and key.

1. Using git, clone: <https://github.com/ewilansky/toolchain_demo.git>

2. In the ./build_dev_nginx, you'll find a certificate (.pem file) and a key. You are likely to run into SSL errors when you start the site in a later step because the root certificate I generated will not be in your Trusted Root Certification Authorities store in Windows or your login store in OS X. To avoid these errors, you must add the root certificate to one of these stores and fully trust it. If you are not comfortable doing this, I suggest you used self-signed certificates. It if helps at all, I created this certificate chain using OpenSSL from my local computer. As I mentioned earlier, it shouldn't be used for anything but local testing, but is otherwise inocuous.

3. Update your hosts file to include an alias for my.dev for your loopback address. Here's an example:

    `127.0.0.1 localhost my.dev`

    Later, you will be using my.dev to interact with Nexus.

### Pulling and Composing Images and Running Containers

After cloning the toolchain demo, you will render two containers, one for nginx and one for Nexus.

1. Change to the root directory of the solution (the directory containingdocker-compose.yml)

2. Matrialize containers for nginx and Nexus 3:

    ```console
    $ docker-compose up -d nginx nexus

    Creating network "toolchain_demo_tc-net" with the default driver
    Creating nginx ... done
    Creating nexus ... done
    ```

    In the background, this is what's happening:

    - docker-compose calls the nginx dockerfile (in ./build_def_nginx) to pull nginx from Docker Hub
    - docker then copies the sample certificate chain, certificate key and nginx configuration file (nginx.conf) created for this demo (also in ./build_def_nginx)

   >IMPORTANT NOTE: I used openssl to create the certificates. You must trust all certificates in this chain or your browser will display a security warning. How you go about trusting the certificates varies from operating system to operating system. If you have any issues with trusting this certificate chain, another option you have is replacing the existing pem in the ./build_def_nginx with a certificate with a trusted root CA. You must also replace the private key in my.key. Be sure to keep the file names the same. Once done, you then must rebuild the image following the optional "build the image:" step appearing next.

    building/rebuilding the nginx image and restarting the nginx container (optional):

    ```console
    $ docker-compose up -d --build nginx

    Building nginx
    Step 1/4 : FROM nginx
    ---> f09fe80eb0e7
    Step 2/4 : COPY nginx.conf /etc/nginx/nginx.conf
    ---> Using cache
    ---> 3246208bb455
    Step 3/4 : COPY *.pem /etc/nginx/
    ---> Using cache
    ---> bcc885899ebc
    Step 4/4 : COPY *.key /etc/nginx/
    ---> Using cache
    ---> eee4e2e94436

    Successfully built eee4e2e94436
    Successfully tagged ahl.nginx:v1
    nginx is up-to-date

    ```

3. Verify that nginx is functional:

    ```console
    $ docker exec -it nginx service nginx status

    [ ok ] nginx is running.
    ```

4. Verify that Nexus is functional by browsing to <http://localhost:8088> then browse securely using <https://my.dev:18445>

5. Logon to Nexus with the default Nexus credentials (user: admin, password: admin123)

6. At the command line with the Docker client, you can also verify that both containers (nginx and Nexus are running):

   ```console
   $ docker ps

   CONTAINER ID        IMAGE                    COMMAND                    PORTS                                                    NAMES
   23a9c341169f        ahl.nginx:v1             "nginx -g 'daemon of…"     0.0.0.0:18445->18445/tcp, 80/tcp, 0.0.0.0:18446->18446/tcp   nginx
   9bb2a5820c1c        sonatype/nexus3:latest   "sh -c ${SONATYPE_DI…"     0.0.0.0:8088->8081/tcp                                   nexus
   ```

   some columns are omitted for clarity and not all exposed ports are shown for nginx.

   nginx is listening on ports 18445, 18446 and 18447, all configured as encrypted (SSL) endpoints. Port 80 appears in docker ps, but isn't used and doesn't send traffic to Nexus.

### Creating Nexus Repositories to Serve as Docker Registries

Three repositories serve Docker: docker (hosted), docker (proxy), and docker (group). This follows the guidance provided by Sonatype and aligns the repositories to the nginx reverse proxy. These repositories can be created manually or via scripting automation, as shown here. Bash scripts are provided. **TODO: create windows batch file equivalents.** Also, you must have cURL installed locally since the scripts interact with the Nexus RESTful API using cURL.

1. At the command line, navigate to the nexus_setup directory.

2. Run ./setup.sh

3. In a browser, navigate to https://my.dev:18445 and logon with the default credentials (user: admin, password: admin123)

4. Click the cog in the top navigation and review the three repositories that were created:

   - docker-internal - repository to serve as the Docker registry to host Docker images you push to Nexus

   - docker-proxy - repository to host images from some other Docker registry when the images are not available locally

   - docker-all - repository to pull and search for Docker images. This repository contains a reference to the other Docker repositories.

## Testing the Working Example

login to the docker (hosted) registry:

```console
$ docker login my.dev:18446

Username: admin
Password:
Login Succeeded
```

push to docker (hosted) repository:

```console
$ docker push my.dev:18446/tibcobe:v5.5

The push refers to repository [my.dev:18446/tibcobe]
691118773b39: Pushing [==============>             ]
4b7d93055d87: Pushed
663e8522d78b: Pushed
283fb404ea94: Pushed
bebe7ce6215a: Pushed

v5.5: digest: sha256:2c3146d4c8791...
```

search the registry for an image starting with tibco (some columns removed for brevity):

```console
$ docker search my.dev:18447/tibco*

NAME                               DESCRIPTION         STARS
my.dev:18447/tibcobe:v5.5                              0
```

pull from docker (group) repository:

```console
$ docker pull my.dev:18447/tibcobe:v5.5

v5.5: Pulling from tibcobe
...
Digest: sha256:2c3146d4c8791dbdc58a44af8dd410bba2ed711c628f78b52b01277b6cdcbe4a
Status: Downloaded newer image for my.dev:18447/tibcobe:v5.5
```

pull through docker (proxy) repository via docker (group):

```console
$ docker pull my.dev:18447/ubuntu:latest
atest: Pulling from ubuntu
...
Digest: sha256:be159ff0e12a38fd2208022484bee14412680727ec992680b66cdead1ba76d19
Status: Downloaded newer image for my.dev:18447/ubuntu:latest
```

### Additional References

- <https://blog.sonatype.com/running-the-nexus-platform-behind-nginx-using-docker>

  Excellent post on how to automate aspects of Nexus configuration, nginx reverse proxy and details on docker-compose (one part of a three-part series). I'm using the scripts Curtis Yanko provides here: <https://github.com/CMYanko/demo-iq-server/tree/master/nginx/nexus-repository> as a starting-point for auto-generating a set of Nexus repositories to serve as a Docker registry endpoint.

- <https://blog.sonatype.com/using-nexus-3-as-your-repository-part-3-docker-images>

  Describes how to use Nexus 3 as a Docker registry. It's not bad, but a bit out of date and requires that the Docker client send data to Nexus 3 unencrypted (over HTTP)

- <https://blog.sonatype.com/maxences-technical-corner>

  Describes how to run Nexus 3 as a Docker container over SSL. However, it uses a self-signed certificate so it won't be trusted by default. Also, the SSL configuration probably won't be persisted when the container is deleted. The SSL configuration should either be in a Docker mounted volume or be copied over in a Dockerfile on image creation.