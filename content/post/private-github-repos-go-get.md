+++
author = "Andrew Hamilton"
comments = false
date = "2017-05-23T10:54:24+02:00"
draft = false
image = "images/locks.jpg"
menu = ""
share = true
slug = "private-github-repos-go-get"
tags = ["go","golang","github"]
title = "Private GitHub repos and go get"

+++

Go is currently my favorite language to write services and tools in and we're starting to use it at my company. As with most companies, the majority of the code we write is currently kept private and we've decided to use GitHub as our host.

Since we're using Go, we would like to keep the standard workflow of pulling in dependencies using `go get` but with private GitHub repos this doesn't automatically work. After searching, I came across this [Gist](https://gist.github.com/shurcooL/6927554) which details a couple options that are available. Below are the steps required to get `go get` to function properly including when using the `-u` option.

Note that this method only works if you have a single GitHub account. If you are using multiple GitHub accounts then you will need to do this for the account most likely to access private GitHub repos.

I am not sure if this method works with git clients other than the CLI and that is my primary way of working with git.

#### GitHub setup
In the following steps will we create a new "personal access token" that will give us access to our repositories.

1. Go to GitHub and access your profile's settings.
1. Click on "Personal access tokens".
1. Click on "Generate new token". If prompted, authenticate yourself to move on to the next step.
1. Setup your token using the following steps:
    * Give the token a description or name such as `go-get-token`. 
    * Click on "repo" to give this token access to read from and write to the repos accessible by your account. (Check out "[About scopes for OAuth Apps](https://developer.github.com/apps/building-integrations/setting-up-and-registering-oauth-apps/about-scopes-for-oauth-apps/)" to learn more about the permissions granted to this token)
    * Click "Generate token"
1. Copy the access token as we'll use it in the next steps. If you use a password manager or some other type of encrypted storage system you could also paste it there to share across systems but it's easy to create a new token and is probably more secure.

#### Git setup
Now that we have a personal access token we can setup our global git configuration to allow us to access private GitHub repositories. You only need to do the following once and it will continue to work.

1. If you haven't used the git crendential store you'll need to set it up:

    ```
    $ git config --global credential.helper store
    ```

1. Now we'll add a configuration line to require git to use our token when accessing repos on GitHub over https:

    ```
    $ echo "https://${GITHUB_TOKEN}:x-oauth-basic@github.com" >> ~/.git-credentials
    ```

    You need to substitute `${GITHUB_TOKEN}` with the token you created in the above section. This will add `https://${GITHUB_TOKEN}:x-oauth-basic@github.com` to a file in your home directory called `.git-credentials`. The `.git-credentials` file should only have permissions to be read and written by your local user.

Once you've completed this you should be able to run `go get <github_private_repo>` and have the repo successfully added to your `$GOPATH`.

*Post photo (CC BY 2.0) by [Alan Levine](https://www.flickr.com/photos/cogdog/16349247587/in/photolist-qUJaH6-9h1Uu8-fnsp8E-kp6GK-28zxWE-b8nFez-7kjrEy-3P59Aa-5pnQVi-yq54w-8d6yWJ-AM9MA-CZBRW-uBhTu-yGbni-ErN4a-byKF2z-33j2f5-dc6QwU-EHcEtg-bZwvsm-2MyHme-e9A1BF-eXCp6S-dNLa5-gCfXUB-U4N5g1-keBeGe-uVVq8L-57xzB3-HSPRud-H5p681-6vSQRb-bxtbQo-a5CyPe-paoFxa-7dNNZf-bLnTb6-rWDZvU-5g8bEN-e9FFz9-oFDjTz-oSTVeh-JJqwGu-oHn2E1-4aBNLa-SnfbV8-GQVr-6JQpfc-kHosNS)*