+++
date = "2017-07-04T10:20:00-07:00"
draft = true
title = "Tracking Build and Deploy Workflow with Docker Tags"
slug = "tracking-build-and-deploy-workflow-with-docker-tags"
tags = ["docker","workflow","tags","continuous-integration","continuous-deployment","build","deploy","devops"]
image = ""
comments = false	# set false to hide Disqus
share = true	# set false to hide share buttons
menu= ""		# set "main" to add this content to the main menu
author = "Andrew Hamilton"
+++

One of the main tenents of Continuous Integration / Continuous Delivery is the concept of a deploy artifact. It's stated in the book [*Continuous Delivery*](https://www.amazon.com/dp/0321601912?tag=contindelive-20) by Humble and Farley that a build artifiact should be created once and use through all steps such as test, stage and production. In order to do this properly, we need to be able to track the different stages that a given artifact has move through to be able to properly promote and deploy properly vetted code.

The common way to track this is through an external database or other service. One nice piece of a Docker container is the concept of tags. With tags, we are able to keep information about the different steps a container has be through in the same place as the artifact. With tags we also make sure that we don't need to keep multiple copies of a given artifact as tags are just pointers to containers so we reduce the amount of storage required.

Unfortunately, there is no easy way to tag a container in a remote registry so tagging is a multi-step process. You must go through the following to tag an image or a remove repository:

1. Pull down the image to your local machine
    ```
     $ docker pull <image>:<old_tag>
    ```
1. Tag the container with the new tag
    ```
     $ docker tag <image>:<old_tag> <image>:<new_tag>
    ```
1. Push the new tag to the repo
    ```
     $ docker push <image>:<new_tag>
    ```

