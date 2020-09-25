+++
author = "Andrew Hamilton"
comments = false	# set false to hide Disqus
date = "2020-09-24T14:12:58-07:00"
draft = false
image = ""
menu = "main"		# set "main" to add this content to the main menu
share = true	# set false to hide share buttons
slug = ""
tags = ["sre","health", "operations"]
title = "Health Endpoints"
+++

The health endpoint is a vital, yet often overlooked piece of a service. It is usually seen as a simple endpoint that doesn't provide much value to the overall operation of a service. But, health endpoints can be expanded upon and provide valuable information to the user in an easy to read or machine friendly manner.

Kubernetes environment extended health checking for many people by introducing multiple health checks to the world for services. We are now able to look at different parts of a service and react to them for different reasons as required.

The two checks are as follows:

* liveness
* readiness

We will discuss these two types of checks ans see how these types of endpoints become useful in a non-Kubernetes, AWS environment.

## What is a Health Endpoint?

Every service should have a dedicated health endpoint that consists of a bunch of HTTP paths that provide back different pieces of information about the service. At a basic level, the health endpoint should provide a success and failure signal on a single endpoint.

As the service grows it should include additional information including if the service is running and if the service is healthy and will accept work. More information can be added such as a profiling endpoint to provide information from the running process on request.

Ideally, this endpoint could be shared across all services as a library or package so that we have a consistent way of seeing what is happening with the service. It should be easy to setup and run the endpoint for every service that is running.

The health endpoint should eventaully be separated from the other endpoints (API endpoints) of your application as it becomes more complex. It should also be placed on a separate port so that it doesn't interfeer with other traffic and requires inside access to gather the informatin. With more advanced polling services, authentication could also be added and used when accessing sensitive endpoints.

### What is a poller?

A poller is a service that is watching the health endpoint for your service and making a decision based on the response. An example of a poller is an AWS AutoScaling Group (ASG) health check, a AWS Target Group health check, the Kubernetes pod probes, etc.

Pollers generally hit an HTTP endpoint for a service but can also perform other actions such as checking if a port is open, checking a file or executing a script.

It is referenced as a poller because it generally checks the health information on an interval (i.e. every x seconds) and keeps track of the results. A poller is usually give a set of criteria such as "the service is healthy if it has returned success n times in a row" or "the service is unhealthy if failure is returned m times in a row".

The poller will generally work on an interval. The interval is how often, generally in seconds, the poller should access the endpoint to look for a result.

A timeout is generally provided to the poller that tells it how long it hsould wait for a request to be returned by the service. Generally the timeout should not be very long as the health endpoint shouldn't have a lot of work to do to return a result.

Success and failure counts are provided to the poller to tell it how many requests of each type are required to mark the service as either healthy or unhealthy, respectively.

### What about GRPC?

A health endpoint should be easy to access and understand by humans as well as by machines. Having a HTTP endpoint makes it easy to integrate with any type of polling mechism that is around today. HTTP also makes it easier for users to access the endpoint during an incident without requiring additional tooling. Ease of use and access to the endpoint should always be a priority.

So, it is suggested that your health endpoint stay as HTTP no matter what your service is doing to access its work.

### What about executing a script?

Kubernetes has the option of using a script as the health check probe for the service. This can be helpful for legacy services that you can't update easily but should be a last resort. An HTTP endpoint can become quite helpful and powerful and provide additional useful information to other users and services of the system beyond the basic probes by Kubernetes.

## Basic Endpoints

There are two basic routes that you should have on your services health endpoint.

* liveness
* readiness

Where you actually put these routes is up to you but it should be consistent on all of the services inside of your environment for easy of use.

### Are you still alive?

A "liveness" check tells the poller whether the service is up or down. It does not tell the poller whether the service is healthy or if it is ready to work.

When the service starts, the health endpoint is initialized and started. The liveness endpoint should always be set to return a "successful" result as it is signifying that the service is up and running. When the service is no longer running it should timeout and fail, eventually causing the poller to take some action such as terminating the host and creating a new one.

The poller should be configured to have a short timeout for requests as the return should be easy and quick by this endpoint. The interval for the poller should be longer than the readiness probe. The number of successes and failures should be tweaked so that if needed, the service can be restarted without requiring the host to be recreated.

### We're ready to work

Readiness tells the poller whether the service is ready to begin working. It indirectly tells the poller that the service is up and running on the host but this is a lesser function of this endpoint.

When the health endpoint is intialized and started, the readiness value should default to unready. The service should then perform any needed tasks to setup the service and its dependencies. Once the service is ready to begin working, it should set the readiness endpoint to return success.

The poller should be configured to access this endpoint on a short interval with a few failures resulting in removing the service from produciton. there would probably also need to be a delay in when the poller begins to watch the service as it might take more time than the failure threshold allows for the service to become ready and not cause the service to enter a restart loop.

## What about AWS?

If the service isn't running on a Kubernetes cluster it might seem unnecessary to have both liveness and readiness endpoints. Both can still be helpful if the architecture of the service includes the widely used Autoscaling Group (ASG) and Target Group (TG)/Application Load Balancer (ALB) structure.

The liveness endpoint would be utilized by an ASG health check. The ASG would poll the endpoint periodically but at a larger interval than the readiness endpoint. It's polled this less often because a major event should occur before we remove the instance from the ASG due to this endpoint going away or reporting unhealthy. With proper setup, the readiness endpoint should report unhealthy and be removed from getting work before the instance is removed from service.

The readiness endpoint should be polled by the AWS Target Group that provides instances to the Application Load Balancer (ALB) for the service. The polling should happen more often at a shorter interval to help reduce the number of requests that are sent to an unhealth service and result in an error to the user (or ideally a slight delay as another request is attempt and successful with another instance of the service).

## Why Not Use a Single Endpoint?

A single endpoint could be used but having two endpoints allows for additional flexibility in how the local service can control the actions of the remote services that are watching it without requiring access to those components (i.e. API credentials).

### When failures can be helpful

There are times where we might want to fail a service on purpose such as to slowly deploy a new version of our service. With two endpoints, we are able to remove the instance from the LB without worrying about a long deploy causing the instance to terminate before the new version of the service can start up and be report as successful.

The steps for a deployment could look like the following:

1. A subset of instances are choosen that will run the new version of our service.
2. The version of the service is updated for the subset of instances in a central location.
3. The change is noticed and the service is terminated by the OS.
  a. The service catches the signal from the OS and begins the shutdown process for the service.
  b. The API endpoint should be finish in-flight requests as normal (up to a timeout period).
  c. The readiness health endpoint begins returning a failure status such as a HTTP 500 code. The liveness health endpoint continues to return a successful response because the service is still running.
  d. The instance is marked as unhealthy by the load balancer and stops getting requests.
  e. The service hits an internal timeout period or notices that it no longer has an in-flight requests and terminates.
4. The OS starts the service up with the newer version of the service.
  a. The service starts up and initializes the health endpoint.
  b. The liveness endpoint is actived and begins returning a healthy status.
  c. The services sets up its dependencies so that it is ready to take on work.
  d. The API endpoint for the service is started.
  e. The readiness endpoint is marked as successful to be picked back up by the load balancer.
5. The new version of the service is running behind the ALB and the process can be repeated with additional instances.

By being able to utilize both endpoints, we can deploy our software without errors on the client side while also making sure that we don't cause additional delay by creating a new set of instances. With a single endpoint, we would most likely cause our instances to become unhealthy and roll when we deploy to them as we'd hit the failure on the health at both pollers.

## Ending thoughts

Hopefully this provides a basic understanding of why a health endpoint is useful and how it can be used to better operate a service. There are additional possibilities that could be added that make the endpoint as needed.
