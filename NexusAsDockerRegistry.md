# Nexus 3 as Docker Registry

Sonatype has provided documentation and some blog posts for configuring Nexus 3 as a Docker registry. Some of the blog post references appear at the end. Here is their help documenation:

- https://help.sonatype.com/repomanager3/private-registry-for-docker
  
  This is the most complete guidance on using Nexus 3 as a Docker registry. However, I found it hard to follow without a better understanding of the expected end-behavior resulting from following their configuration guidance.

## Suggested Approach

1. Read the Overview section.
2. Get the working example.
3. Review the Aspects of Setup section.

## Overview

If you aren't familiar with things like a Docker registry, Docker images or Docker containers, please visit <https://docs.docker.com/> to learn more about Docker. That will help you get the most out of this post.

The general idea is that SWA should have some control or at least be able to monitor what docker images are made available or are being used in a Docker registry. An internal registry hosted in Nexus 3 satisfies that requirement. Nexus uses the concept of repositories as storage endpoints for artifacts, such as JAR files. Repositories also serve as the model for storing Docker images.

### Workflow

The general workflow in a CI/CD pipeline is that a development team would continue to push compiled artifacts, like JAR or WAR files into a Nexus repository, the maven2 (hosted) repository type upon the succesful completion of a build. Later in the same pipeline, the orchestrator, Jenkins in this case, would retrieve an image from a Nexus repository, docker (group) repository type and then deploy a compiled artifact into the Docker image in order to create a new Docker image. That new Docker image would then be pushed back to a Nexus repository, docker (hosted) repository type. Further down in the pipeline, Jenkins would then pull the new Docker image containing the compiled artifact and deploy the image as a running Docker container into an environment, such as Dev, iTest, QA, Prod.

The third repository type used for Docker is docker (proxy). It's to this repository that any missing base images can be retrieved. The docker (proxy) can be configured to connect to Docker hub or perhaps SWA will prefer to proxy their Amazon ECR (elastic container repository) endpoint instead. The use of the hosted, group and proxy repository types are a common pattern in Nexus for all Nexus repository types or recipes, as it's called in Nexus.

### Docker Client Interaction

There are two Docker client related issues around interfacing with Nexus:

- context-path
- encryption

#### Context-path

Well documented in Sonatype help is the fact that Docker doesn't use a context-path to push images to a Docker registry. This means that you can't push images to Nexus using the context-path part of the request and expect the image to appear in a specific repository that maps to that path context. For details on this issue, see the SSL and Repository Connector Configuration section at <https://help.sonatype.com/repomanager3/private-registry-for-docker/ssl-and-repository-connector-configuration>. The solution is to have a unique IP port assigned to the repository. I'll demonstrate that in the working example.

#### Encryption

By default, the Docker client expects that it will communicate with an endpoint over an encrypted connection (SSL) via HTTPS. Either Nexus 3 can be configured to serve content via HTTPS or you can configure a reverse proxy that accepts encrypted requests from a Docker client and then forwards the request to Nexus 3 unencrypted via HTTP. Either way, some endpoint has to be configured to use HTTPS and most reverse proxy's are easier to configure for HTTPS than Nexus is. However, either approach will work. In my example, I use a reverse proxy to handle the HTTPS request from a Docker client and route it Nexus via HTTP.

### Containers Everywhere

In the working example, there are three actors, the Docker client, an nginx reverse proxy and a Nexus 3 endpoint. The reverse proxy and Nexus 3 endpoint are running in Docker containers. While on the surface, this might sound more complicated, it provides portability and scaling options that are harder to support in a VM or on metal.

## Working Example

I have created a toolchain demo in my public github repository. There is nothing in this repository specific to SWA. However, the open source tools used in this repo are the ones recommended by SWA APT.

### First Step: Pulling and Composing Images and Running Containers

After cloning the toolchain demo, you will render two containers, one for nginx and one for Nexus.

1. Using git, clone: https://github.com/ewilansky/toolchain_demo.git

2. Change to the root directory of the solution (the directory containingdocker-compose.yml)

3. Matrialize containers for nginx and Nexus 3:

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

4. Verify that nginx is functional:

    ```console
    $ docker exec -it nginx service nginx status

    [ ok ] nginx is running.
    ```

5. Verify that Nexus is functional by browsing to http://localhost:8088

6. Logon to Nexus with the default Nexus credentials (user: admin, password: admin123)

7. At the command line with the Docker client, you can also verify that both containers (nginx and Nexus are running):

   ```console
   $ docker ps

   CONTAINER ID        IMAGE                    COMMAND                    PORTS                                                    NAMES
   23a9c341169f        ahl.nginx:v1             "nginx -g 'daemon of…"     0.0.0.0:443->443/tcp, 80/tcp, 0.0.0.0:18443->18443/tcp   nginx
   9bb2a5820c1c        sonatype/nexus3:latest   "sh -c ${SONATYPE_DI…"     0.0.0.0:8088->8081/tcp                                   nexus
   ```

   some columns are omitted for clarity

   nginx is listening on ports 443 and 18443, both configured as encrypted (SSL) endpoints. Port 80 appears in docker ps, but isn't used and doesn't send traffic to Nexus.

### Second Step: Create Nexus Repositories to Serve as Docker Registries

In Nexus, you will create three repositories for the Docker registry: docker (hosted), docker (proxy), and docker (group). This follows the guidance provided by Sonatype and aligns the repositories to the nginx reverse proxy.

1. If you're not already signed-into Nexus from an earlier step, make sure you logon using Nexus default credentials (user: admin, password: admin123).

2. From the cog in the top navigation bar, go to Server administration and configuration.

3. Click repositories, then click Create repository.

4. Select the docker (hosted) recipe.

   This is the repository that will recieve images that you push from the Docker client into Nexus.

5. 

### Testing the Working Example

login to docker Nexus registry:

`docker login mac.my`

push to docker (hosted) repository:

`docker push mac.my/tibcobe5.5hotfix`

search the registry for an image starting with tibcobe:

`docker search mac.my/tibcobe*`

pull from docker (group) repository:

`docker pull mac.my/tibcobe5.5hotfix:v1`

pull through docker (proxy) repository via docker (group):

`docker pull mac.my:18443/ubuntu:latest`

## Aspects of Setup


### Additional References

- https://blog.sonatype.com/using-nexus-3-as-your-repository-part-3-docker-images

  Describes how to use Nexus 3 as a Docker registry. It's not bad, but a bit out of date and requires that the Docker client send data to Nexus 3 unencrypted (over HTTP)

- https://blog.sonatype.com/maxences-technical-corner

  Describes how to run Nexus 3 as a Docker container over SSL. However, it uses a self-signed certificate so it won't be trusted by default. Also, the SSL configuration probably won't be persisted when the container is deleted. The SSL configuration should either be in a Docker mounted volume or be copied over in a Dockerfile on image creation.