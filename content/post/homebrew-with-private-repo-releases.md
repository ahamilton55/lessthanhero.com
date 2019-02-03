+++
date = "2019-02-02T13:30:00+07:00"
draft = false
title = "Homebrew with Private Repo Release Downloads"
slug = "homebrew-with-private-repo-releases"
tags = ["homebrew","brew","osx","go","golang","github","ruby"]
image = "images/tools.jpg"
comments = false	# set false to hide Disqus
share = true	# set false to hide share buttons
menu= ""		# set "main" to add this content to the main menu
author = ""
+++

Custom tooling is very helpful in any software engineering group. Making the lives of others inside of your organization easier by automating common and shared problems can help everyone get more work done. But, providing these tools to our internal users is not always easy. Especially when a we fix bugs or add new features, internal users might not know that there is a new version available to download.

The Go programming language allows us to easily build a cross-platform binary that can be installed by users without requiring addtional software such as making sure the correct runtime or dependencies are installed. So to make the tools easier for our users, we will focus on utilizing the Go programming language in this example.

In a predominately Mac OS X enviornment, Homebrew is an easy and effective tool that can help us with these problems. Homebrew makes it easy for us to pull down public software and keep it up to date on our computers.  Many companies usually have software hosted from a private resource such as an internal Git server or they may rely on private repositories on GitHub. We want to be able to use the Homebrew system to distribute our tools while also continuing to work with our organization and what it requires to be private.

By default, Homebrew expects the tools that it installs to either be in a publicly downloadable location or to be built on the local machine. We can fix this by running a web server that is publically accessible to our users but that would require our users to be located on site or have a VPN setup and running. Though this is not difficult and usually standard, we want to try and make the delivery of our tools to be painless for both the developers and the users.

We can have Homebrew build our tool locally on the user's computer but this can lead to some problems. First, we should build our tools with proper software development practices and do Cotinuous Integration (CI) and Continuous Delivery (CD). Building the tool on every person's computer breaks the concept of CD because we no longer are using the binary that we tested as part of the CI process. Though unlikely, there can be problems that occur when we need to rebuild the tool such as a missing dependency due to a third-party repository is having issues. Assuming that the user needs this tool at 2am in the morning because the site is down and the tool is required to fix it.

#### Custom Downloader for Homebrew

To accomplish this task we'll need to create a custom downloader for Homebrew. This downloader will do the heavy lifting to tell Homebrew how to download our tool from the releases section of our private GitHub repository.

We'd add the following information to a file called `custom_download_strategy.rb` to the root of our company's Homebrew Tap:

```ruby
require "download_strategy"

# GitHubPrivateRepositoryDownloadStrategy downloads contents from GitHub
# Private Repository. To use it, add
# `:using => :github_private_repo` to the URL section of
# your formula. This download strategy uses GitHub access tokens (in the
# environment variables `HOMEBREW_GITHUB_API_TOKEN`) to sign the request.  This
# strategy is suitable for corporate use just like S3DownloadStrategy, because
# it lets you use a private GitHub repository for internal distribution.  It
# works with public one, but in that case simply use CurlDownloadStrategy.
class CustomGitHubPrivateRepositoryDownloadStrategy < CurlDownloadStrategy
  require "utils/formatter"
  require "utils/github"

  def initialize(url, name, version, **meta)
    super
    parse_url_pattern
    set_github_token
  end

  def parse_url_pattern
    unless match = url.match(%r{https://github.com/([^/]+)/([^/]+)/(\S+)})
      raise CurlDownloadStrategyError, "Invalid url pattern for GitHub Repository."
    end

    _, @owner, @repo, @filepath = *match
  end

  def download_url
    "https://github.com/#{@owner}/#{@repo}/#{@filepath}"
  end

  private

  def _fetch(url:, resolved_url:)
    curl_download download_url, "--header", "Authorization: token #{@github_token}", to: temporary_path
  end

  def set_github_token
    @github_token = ENV["HOMEBREW_GITHUB_API_TOKEN"]
    unless @github_token
      raise CurlDownloadStrategyError, "Environmental variable HOMEBREW_GITHUB_API_TOKEN is required."
    end

    validate_github_repository_access!
  end

  def validate_github_repository_access!
    # Test access to the repository
    GitHub.repository(@owner, @repo)
  rescue GitHub::HTTPNotFoundError
    # We only handle HTTPNotFoundError here,
    # becase AuthenticationFailedError is handled within util/github.
    message = <<~EOS
      HOMEBREW_GITHUB_API_TOKEN can not access the repository: #{@owner}/#{@repo}
      This token may not have permission to access the repository or the url of formula may be incorrect.
    EOS
    raise CurlDownloadStrategyError, message
  end
end

# GitHubPrivateRepositoryReleaseDownloadStrategy downloads tarballs from GitHub
# Release assets. To use it, add `:using => :github_private_release` to the URL section
# of your formula. This download strategy uses GitHub access tokens (in the
# environment variables HOMEBREW_GITHUB_API_TOKEN) to sign the request.
class CustomGitHubPrivateRepositoryReleaseDownloadStrategy < CustomGitHubPrivateRepositoryDownloadStrategy
  require 'net/http'

  def initialize(url, name, version, **meta)
    super
  end

  def parse_url_pattern
    url_pattern = %r{https://github.com/([^/]+)/([^/]+)/releases/download/([^/]+)/(\S+)}
    unless @url =~ url_pattern
      raise CurlDownloadStrategyError, "Invalid url pattern for GitHub Release."
    end

    _, @owner, @repo, @tag, @filename = *@url.match(url_pattern)
  end

  def download_url
    #"https://#{@github_token}@api.github.com/repos/#{@owner}/#{@repo}/releases/assets/#{asset_id}"
    #blah = curl_output "--header", "Accept: application/octet-stream", "--header", "Authorization: token #{@github_token}", "-I"
    uri = URI("https://api.github.com/repos/#{@owner}/#{@repo}/releases/assets/#{asset_id}")
    req = Net::HTTP::Get.new(uri)
    req['Accept'] = 'application/octet-stream'
    req['Authorization'] = "token #{@github_token}"

    res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      http.request(req)
    end

    res['location']
  end

  private

  def _fetch(url:, resolved_url:)
    # HTTP request header `Accept: application/octet-stream` is required.
    # Without this, the GitHub API will respond with metadata, not binary.
    curl_download download_url, "--header", "Accept: application/octet-stream", to: temporary_path
  end

  def asset_id
    @asset_id ||= resolve_asset_id
  end

  def resolve_asset_id
    release_metadata = fetch_release_metadata
    assets = release_metadata["assets"].select { |a| a["name"] == @filename }
    raise CurlDownloadStrategyError, "Asset file not found." if assets.empty?

    assets.first["id"]
  end

  def fetch_release_metadata
    release_url = "https://api.github.com/repos/#{@owner}/#{@repo}/releases/tags/#{@tag}"
    GitHub.open_api(release_url)
  end
end
```

Homebrew previously had this functionality built-in but it has since been deprecated. The majoirty of this code came from the deprecated code in the Homebrew project for example [here](https://github.com/Homebrew/brew/blob/335be35acf805a2853a6fe92b06d9a643616f463/Library/Homebrew/download_strategy.rb#L535).

The main updates from the original was fixing how the `download_url` method finds correctly finds the artifact URL. Here we start off by using the URL provided by the Formula file that easily follows a templated form. We do a HTTP GET request against that URL and collect the results of that request. We inspect the HTTP Headers one named "location" that points to the finally locatation where the artifact can be downloaded. We finally return the discovered URL and use the built-in Homebrew curl downloader to download the file for Homebrew to install.

#### Add the Downloader to the Formula

The directory structure for our tap would look like the following:

```
our-homebrew-tap/
|-- custom_download_strategy.rb
|-- Formula/
    |--- some-tool.rb
```

Here is an example of a Homebrew Formula that is able to access a private tool from a private GitHub repository. In this example, a zipped tarball (.tar.gz) has been created for our tool and that was uploaded to the "Releases" section of a repository called `some-tool`. The forumula was automatically created using the [goreleaser](https://goreleaser.com/) tool.

```ruby
require_relative "../custom_download_strategy.rb"

class SomeTool < Formula
  desc "An example tool"
  homepage ""
  url "https://github.com/some-org/some-tool/releases/download/v0.0.1/some-tool_0.0.1_Darwin_x86_64.tar.gz", :using => CustomGitHubPrivateRepositoryReleaseDownloadStrategy
  version "0.0.1"
  sha256 "c19ccd90a300fd178835b2b6df7ad07ead2ca099457e121904f05173d4e2d55c"

  def install
    bin.install "some-tool"
  end
end
```

Our custom download strategy is pulled in by the first line, the `require_relative` statement. The file referred to by the `require_relative` statement is located in the parent directory as stated by the use of the `../` relative path prefix. As part of the `url` field in our Formual, we added the option `:using => CustomGitHubPrivateRepositoryReleaseDownloadStrategy` which tells Homebrew that it should use a downloader called `CustomGitHubPrivateRepositoryReleaseDownloadStrategy`. Here this points to one of the downloaders in our `custom_download_strategy.rb` file but it can be used to access any of the different downloaders that Homebrew provides.

You should now be able to perform a `brew update` and see your new tool available but you won't be able to install the tool yet because you have not provided Homebrew with an API key.

#### Provide Homebrew with a GitHub Personal Access Token

A GitHub personal access token allows you to work with the GitHub API in various ways to make automated access easier through different tools. I've discussed this before in my post [Private GitHub repos and go get](/post/private-github-repos-go-get/) that describes how to work in a Go environment using private repositories.

You will need a personal access token that has access to the repositories that your user is able to access. If you don't already have one available, you can find instructions [here](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/).

Once you have your token, you will need to set an environment variable in your shell that can be used by Homebrew when completing tasks with GitHub. The environment variable must be named `HOMEBREW_GITHUB_API_TOKEN` and provided the value of your personal access token. You should setup your shell to automatically set this value upon creating by adding `export HOMEBREW_GITHUB_API_TOKEN=...` to the startup file for your shell.\

Once you've added this to your shell, you can install your tool and continue to get updates as development on the tool continues.

---
Header image by <a style="background-color:black;color:white;text-decoration:none;padding:4px 6px;font-family:-apple-system, BlinkMacSystemFont, &quot;San Francisco&quot;, &quot;Helvetica Neue&quot;, Helvetica, Ubuntu, Roboto, Noto, &quot;Segoe UI&quot;, Arial, sans-serif;font-size:12px;font-weight:bold;line-height:1.2;display:inline-block;border-radius:3px" href="https://unsplash.com/@carlevarino?utm_medium=referral&amp;utm_campaign=photographer-credit&amp;utm_content=creditBadge" target="_blank" rel="noopener noreferrer" title="Download free do whatever you want high-resolution photos from Cesar Carlevarino Aragon"><span style="display:inline-block;padding:2px 3px"><svg xmlns="http://www.w3.org/2000/svg" style="height:12px;width:auto;position:relative;vertical-align:middle;top:-2px;fill:white" viewBox="0 0 32 32"><title>unsplash-logo</title><path d="M10 9V0h12v9H10zm12 5h10v18H0V14h10v9h12v-9z"></path></svg></span><span style="display:inline-block;padding:2px 3px">Cesar Carlevarino Aragon</span></a>