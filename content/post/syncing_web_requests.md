---
title: "Syncing_web_requests"
date: 2020-10-11T15:54:33-07:00
tags: ["go","testing","services"]
featured_image: ""
description: ""
draft: true
---

Let's assume that we're running a set of integration tests for a code base and that we need some resources for these test. The tests will also run in parallel to help speed up the execution of these the total test run. A web service was built with Go that is able to take in a request for a specific resource type and return a resource that the test can use for its run. We can also assume that we will want a distinct resource for each test but each resource does not need to be physically distinct (e.g. one database host can share many unique databases). The resources will be run on Kubernetes so that it's easier to spin up and spin down resources for each test or to keep some available for fast test runs.

So the problem here is that we'll have many different requests and we'll want to group all of the tests for a CI job onto the same physical resource so that it's easier to clean up that resource once it's done.

