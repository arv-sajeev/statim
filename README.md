# Statim 

## Introduction 

Statim is lightweight static site generator tool, meant for a linux user. Unlike templating tools like 
jekyll and gatsby the other numerous tools out there, statim uses only tools already available in the linux 
ecosystem, and you can get running with minimum dependencies. While easy to use, statim provides very less 
functionality and error checking and assumes that the user organizes his/her directory structure as prescribed.

Statim is more or less a single bash script that organizes the files to make a website and only works on a sunny day scenario.
You can initialize a project using templates provided or designed by you as per the format prescribed. Your posts can be written in markdown 
and tagged while creation, these are then built and organized in to html files.

Almost all the work you do using statim will be through the command line, a basic knowledge of linux style commands is assumed.


## Installation

Download the git repo and run the `install.sh` script in the directory, it will just add statim's working directory into you .rc files
so you can use the statim command from anywhere in your command line. In addition to this it will download the pandoc tool which is used to
convert between different document types. Statim uses pandoc to convert your posts written in html to html pages.

## Working with statim 

You can work with statim using the following simple commands with appropriate options.

### Initializing a statim project

Using the `statim init` command you can initialize a statim project repository
* you can provide the destination to set up the project using the `-d` option 
* without destination provided the current directory is default
* you can provide a name for your project as an argument
* without project name `my_blog` is default

### Making a new post

Use the `statim new` command to set up a new post
* you have use this command within your project repo or provide a valid destination using `-d`
* statim requires you to have a unique name for each post as name is to identify each post
* you can specify multiple tags using the `-t` option followed by a list of space separated tags bound by double quotes

### Building your project

Use the `statim build` command in your project directory to build a project.
* you have use this command within your project repo or provide a valid destination using `-d`
* the build command clears the entire previous build and replaces it with the new build

### Committing your project

The statim tools is mainly meant for those who plan on hosting their static sites on gh-pages,
this command lets you commit to a repository you have added as remote. 
* for the first time it will ask you to supply the url of the remote repo
* the current build gets committed and is pushed to the remote repo

## Directory structure

The root directory in the project contains
* index.html - the landing page 
* archive.html - an archive of all posts till now
* src - the directory where the user is expected to place all posts
* build - the directory to which the build post pages are added, as well as tags
* assets - this directory stores assets like images used throughout the site, css and html templates etc.

As a user you are expected to only interact with the contents of the src directory, the post directories created using the 
statim new command are setup here, with the name of the post supplied. Only create directories within src using the statim new command.
Within the each post directory you can have an img directory to place your images and write your posts in github style markdown. Don't change 
the names of any files here.


## Credit
Statim uses the following tools 
- pandoc - for md to html conversion and syntax highlighting of code
- perl   - for its powerful text processing capabilities
- w3.css - css templates provided by w3 schools




