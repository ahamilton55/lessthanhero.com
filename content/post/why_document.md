---
title: "Why document"
date: 2020-10-11T15:45:00-07:00
tags: ["documentation"]
featured_image: ""
description: ""
draft: false
---

I've often heard statements like, "Why would I need to create internal documentation? The code tells you everything you need to know." when pushing better documentation practices inside of a group I'm working with. It's true that the code tells us what it's doing but, like the earlier statement, it doesn't tell you why the code is doing what it does and context is very important.

Without understanding the reasoning behind past decisions, we risk similar mistakes similar to those we've made in the past. So, it's important documentation doesn't simply explain what something is going to do but also contain informaion around why the software was built to fuction as it does.

## Understanding why, means you understand

"If you want to see if you know something, teach it" is about checking your own understanding of something by being able to clearly explain it to others. It describes the fact that even if you think you understand something, if you can't easily explain it to someone else then maybe you don't know it as well as you thought. We are able to learn more about our gaps in knowledge of a subject and can better reinforce our understanding.

Just having the facts or tools for something doesn't necessarily mean that it is understood. You can copy down and memorize a large number of math equations but if you don't understand why you would use that equation and why it's providing you the answer that it does, you don't actually know math. So, by describing why something is being done how it is, we are able to get a better understanding for ourselves about why the information is important and may even be able to improve it.

## Documentation isn't only about what

When we document something we're trying to tell others a story. Unfortunately, we tend to forget this when doing technical documentation. Instead, we focus so much on the specifics of what we're doing that we don't provide enough information about why we're doing it. Documentation is about keeping a record for the history of something and involves more than just the what is of something.

In software, there is a lot of information about what we're doing. The code we write is the manifestation of what we want to happen. The tests we write make sure that what is happening is the correct thing that we want to happen. We store history in version control systems that mainly describes what we tried to accomplish with a given commit.

In documentation we miss the why and it is just as important if not more important than what has been done. Instead of understanding why we've made the decisions we have to solve a problem, we write down our code, make sure it compiles and ship if off to production. This is okay for smaller features, but for larger architectural pieces of a system it's important to document the reasons around *why* we made our decisions and how we're going to accomplish it.

## Different types of documentation

There are different types of documentation that we generally gloss over when working on software.

### Code comments

Many people don't like code comments. There seems to be a belief that good code will tell everything that the reader needs to know about it. This is definitely true about what the code is doing but it leave out an important piece of information, why is the code doing what it is the ways it's being done.

There are many edge cases that are worked out inside of code that might not be obvious. As time goes on, group knowledge will begin to wain on certain aspects of a codebase and edge cases will become more obscure. As the code is updated, we lose the reasoning for why something might have be done in a less direct way and decide to change it. A quick code comment about why something was done how it was can save people time and reduce the possibility of a bug being introduced to the code.

Understanding why can also save an engineer valuable time while working through a problem. It can reduce the time an engineer needs to wait to completely understand a portion of the code and move on to the next problem. It's also important to remember that your future self might not have the same contextual information, so by add a little comment to a ticky piece of code could save yourself a lot of time, too.

So, next itme you do do something that doesn't make sense to you right away, think about adding a quick note around that code that describes *why* it was done that way.

### Commit messages

Commit messages are usually seen as a dumping ground for random information while working on a problem. Commit messages like "fixed typo" or "added a another variable" really aren't helpful to the future view that these commits are created for.

I'm a fan of trying to produce a clean history of commits in the end for myself and the other engineers I'm working with. It can be helpful and easy to create a ton of small commits as I'm working through a problem but in the end I want to make it easier to package up and explain my work.

So, I'm a fan of rebasing my commits in a smaller number of commits (generally one, but a few is fine) that better define what I was working on. In the message I try to explain what has happened but I also try to leave informaion on why I decided to do what I did. This way, when looking through the commit history for a project it's easier to understand what a commit does insteading of having to wade through a ton of little fixes to figure out what was actually happening.

### Design documents

Design documents describe the details for why a service is being designed. It should contain information for how different major versions of a service were designed and what was the intended usecase for these services. It should be possible to see all of the different versions for a design document through the history of the document.

An important part of creating design documents is the discussion that happens about it. To save context around the "why" of a service, it is important to keep as much discussions as possible attached to the document. This doesn't mean that the document needs to grow and grow but that hopefully a set of comments that point to specific parts of the document can be saved and view later. Comments should survive with the document so that the reasoning behind different decisions for how the service will function can be view by thos engineers that were unable to be apart of the original discussion.

If a wiki like Atlassian's Confluence is used then commenting is built-in. A GitHub or GitLab repo where design documents are stored, any updates should occur inside of a pull request and keeps track of the discussion around the initial version along with any updates in the future. The important piece is that a future user is able to find the context around the information or design of a service.

### Testing

Testing is another place when we can describe why something is being done. This can easily be done with comments inside of testing code. Why did we need to create this test? Why are we running the test how we are? Any information that you can add around the given reason for a test being added can definitely be helfpul.

## Out of date documents

One issue with documenation is that it can get out of date. This can be a problem but I don't think that it is as big of a problem when the code is avaialble to the user as well. In the same way that ancient texts are discovered and used to provide us with a view into why a group of people did certain things, an old engineering document contains information for why the software is built to act as it does.

An old document contains plenty of information such as the original author, co-authors that have updated it, comments around different aspects of the document to provide context around decision making, etc. We're able to utilize this information to create a larger understanding of the software that we're working with.

## It's about others, including your future self

Unfortunately, no one can see into the future with perfect clarity so we'll never know what we'll need. Instead we should try to provide ourselves with enough bread crumbs to be able to retrace our steps when needed.

The purpose of documenting why isn't to document everything all the time. It's about thinking through what you're doing and determining how much you needed to think about it now and whether or not you'll need (or want to do) that much thinking in the future. Unfortunately, we lose information over time so it's important to try and help out ourselves and others with information as possible. Leave enough context so that understanding can be picked up along with the other context around the description (i.e. design documents, code, tests, etc).

In the end, there will be fewer, if any, times that you'll regret writing down that little piece of information but it will probably save you or someone else a ton of time in the future.
