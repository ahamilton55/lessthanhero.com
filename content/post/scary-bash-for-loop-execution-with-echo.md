+++
author = "Andrew Hamilton"
comments = false	# set false to hide Disqus
date = "2019-02-07T21:55:00-08:00"
draft = false
image = "images/loops.jpg"
menu = ""		# set "main" to add this content to the main menu
share = true	# set false to hide share buttons
slug = "scary-bash-for-loop-execution-with-echo"
tags = ["bash","tips"]
title = "Running Scary BASH for Loops with echo"
+++

There are times when we need to do the same thing, over many different pieces of informatin but the action is scary. Scary actions include doing something like deleting a set of resources. We'd want to make sure that we are doing what we need to while trying to do it as safely as possible.

So, in our example let's say that we have a tool that will creates a new Kubernetes namespace along with a set of resources. Let's say that we have discovered this tool hasn't been cleaning up and we need to remove a few different namespaces that have been created. Let's say that all of the namespaces created with this tool are structured as "dm-XXXXX-&lt;verb&gt;-&lt;noun&gt;". So, if we want to look for all of these we can look these up with the following:

```bash
kubectl get ns --no-headers | grep -e "^dm-\d+-*" | awk '{print $1}' >/tmp/namespaces.txt
```

We can then open up the `/tmp/namespaces.txt` file and remove the namespaces that we don't want to delete. Alternatively, we could use a a different command to determine these namespaces but it all just depends on what you need to do to get the information required.

When we finally have this information, we'll need to run the following commands to clean up the namespaces:

```bash
kubectl -n $ns delete all --all
kubectl delete ns $ns
```

The first command will delete everything inside of the namespace and the second one will actually delete the namespace. This is a somewhat scary procedure because what if we end up deleting something from production or another important environment? To be safe, we'll generate what we want to do with a simple for loop for every command we want to complete:

```bash
for ns in $(cat /tmp/namespaces.txt}; do \
    echo "kubectl -n $ns delete all --all"; \
    echo "kubectl delete ns $ns; \
done
```

Our for loop will go through the different namespaces, line-by-line and print out all of the commands that need to be executed. We will be able to look through all of the commands that we will be executing to make sure that we are doing everything that we expect. When we are sure that everything looks as expected and safe, we can bring up the last loop we executed and add the following to the end:

```bash
for ns in $(cat /tmp/namespaces.txt}; do \
    echo "kubectl -n $ns delete all --all"; \
    echo "kubectl delete ns $ns; \
done | bash -x
```

The lines will still be printed but the "pipe" will send those lines directly to the `bash` enterpreter to be executed. The `-x` flag will cause the `bash` command to print out every command as it is being executed that will make it easier for you to track the execution of the task.

Another way we can do this is to redirect the output to a file and then execute that file using bash directly. It is up to you based on what you'll be comfortable with.

As a note, if this is something that you will want to do often you should probably figure out a more thorough way to do it. This is helpful for quick or one-off commands that you need to do. This is also "single threaded" because only one command is executed at a time and it can take a little while to complete.

<a style="background-color:black;color:white;text-decoration:none;padding:4px 6px;font-family:-apple-system, BlinkMacSystemFont, &quot;San Francisco&quot;, &quot;Helvetica Neue&quot;, Helvetica, Ubuntu, Roboto, Noto, &quot;Segoe UI&quot;, Arial, sans-serif;font-size:12px;font-weight:bold;line-height:1.2;display:inline-block;border-radius:3px" href="https://unsplash.com/@priscilladupreez?utm_medium=referral&amp;utm_campaign=photographer-credit&amp;utm_content=creditBadge" target="_blank" rel="noopener noreferrer" title="Download free do whatever you want high-resolution photos from Priscilla Du Preez"><span style="display:inline-block;padding:2px 3px"><svg xmlns="http://www.w3.org/2000/svg" style="height:12px;width:auto;position:relative;vertical-align:middle;top:-2px;fill:white" viewBox="0 0 32 32"><title>unsplash-logo</title><path d="M10 9V0h12v9H10zm12 5h10v18H0V14h10v9h12v-9z"></path></svg></span><span style="display:inline-block;padding:2px 3px">Priscilla Du Preez</span></a>