#! /bin/bash

#######################
## The usage display ##
#######################

usage()
{
	echo "Usage :: $0 [init|new|build] [options...]					" 
	echo
	echo "OPTIONS									"
	echo "		statim -h			Display usage info.		"	
	echo
	echo "SUBCOMMANDS								"
	echo "		statim ls								Display available templates	"
	echo "		statim init  [-d] <target-dir> [-t] <template-name> <blog-dir-name>	set up new blog directory.	"
	echo "		statim new   [-d] <path-to-project-dir> [-t] <tags in a string> <new-post-name>			create new blog post		"
	echo "		build									build and commit changes	"
	echo
	echo
}

########################
## Display templates  ##
########################

templates()
{
	local template_path=$statim_dir/templates
	echo "The available templates are:"
	echo
	echo "$(ls $template_path)"
	echo
}

##############################
## Directory setup for init ##
##############################

dirsetup()
{
	local dir_path=$1/$2
	echo "Initializing project at "$dir_path
	mkdir -p $dir_path/src
	mkdir $dir_path/src/.tags
	mkdir $dir_path/build
	mkdir $dir_path/assets
}


#########################
## File setup for init ##
#########################

filesetup()
{
	local dir_path=$1/$2
	echo $3"template provided"
	local template_path=$statim_dir/templates/$3
	echo "Initializing boilerplate files"
	echo "From template "$template_path
	cp -vR $template_path/css/ $dir_path/assets/css
	echo "css resources done"
	cp -vR $template_path/html/ $dir_path/assets/html
	echo "html resources done"
	cp -vR $template_path/img/ $dir_path/assets/img
	echo "img resources done"
	cp -vR $template_path/js/   $dir_path/assets/js
	echo "js resources done"
	cp -vR $template_path/html/index.html $dir_path/index.html
	cp -vR $template_path/html/archive.html $dir_path/archive.html
	echo "PROJ_NAME="$2 > $dir_path/meta.dat
	echo "TEMPLATE="$3 >> $dir_path/meta.dat
	echo "Enter your name and press [ENTER]  :: "
	read author
	echo "AUTHOR=\""$author"\"" >> $dir_path/meta.dat
	echo "POST_COUNT=0" >> $dir_path/meta.dat
	git init $dir_path
	cd $dir_path
	git add assets
	git add build
	git add index.html
	git add meta.dat
	echo "Init complete"
}

########################################
## Set up directory and meta for post ##
########################################

postsetup()
{
	local proj_dir=$1
	local post_name=$2
	source $proj_dir/meta.dat
	if [ -d $proj_dir/src/$post_name ]; then
		echo "Existing file name" 
		echo "Statim requires you to use unique filenames for each post"
		exit 1
	fi
	mkdir $proj_dir/src/$post_name
	mkdir $proj_dir/src/$post_name/img
	cp -v $statim_dir/templates/$TEMPLATE/example.md $proj_dir/src/$post_name/$post_name.md
	#cp -v $statim_dir/templates/$TEMPLATE/html/post.html $proj_dir/src/$post_name/$post_name.html
	gawk -i inplace 'BEGIN {FS="="}
	{ if ( $1 == "POST_COUNT" ) print "POST_COUNT="$2+1 
	else print $0
	}' $proj_dir/meta.dat
	echo "post directory setup complete"
	echo "POST_NAME="$post_name >> $proj_dir/src/$post_name/meta.dat
	echo "DATE="`date +"%b-%d-%Y"` >> $proj_dir/src/$post_name/meta.dat
	if [ -z $3 ];then 
		echo $post_name >> $proj_dir/src/.tags/untagged
		echo "TAGS=\"\"" >> $proj_dir/src/$post_name/meta.dat
	else 
		echo "TAGS=\""$tag_string"\"" >> $proj_dir/src/$post_name/meta.dat
		for tag in $tag_string
		do
			if [ -f $proj_dir/src/.tags/$tag ];then
				echo $post_name >> $proj_dir/src/.tags/$tag
			else
				echo $post_name > $proj_dir/src/.tags/$tag
			fi
		done
	fi
	echo 
	echo "Write a one liner description for your post"
	read desc
	echo "DESC=\""$desc"\"" >> $proj_dir/src/$post_name/meta.dat
	echo "post setup complete"
	echo "post directory and meta.dat entry setup complete"
}

###########################################################
## Build all the posts in src and populate the build dir ##
###########################################################

buildall()
{
	local proj_dir=$1
	source $proj_dir/meta.dat
	cd $proj_dir

	if [ -z "$(ls -A ./build)" ];
	then 
		echo "First build"
		mkdir ./build/tags
	else
		git rm -rf ./build
		git rm -rf ./build/tags
	fi

	i=2
	
	## Build each post
	for post in $(ls -t src)
	do
		next_post=$(ls -t src | awk "NR==$i")
		buildpost $proj_dir $post $next_post
		i=$(($i+1))
	done

	## Build index and archive pages
	buildarchive
	buildindex

	## Build tag directory structure and tag pages
	for tag in $(ls -t ./src/.tags)
	do 
		buildtag $tag
	done

	echo "##### BUILD COMPLETE #####"
}

###################################################
## Build archive page using details of each post ## 
###################################################
buildarchive()
{
	echo "building archive page"
	all_posts=""
	k=1
	for post in $(ls -t src)
	do 
		source ./src/$post/meta.dat
		echo " creating archive entry"$post
		post_element=$(perl -s -p -e's/STATIMPOSTNAME/$name/g,s/STATIMPOSTDATE/$date/g,s/STATIMPOSTNUMBER/$num/g,s/STATIMPOSTDES/$des/g,s/STATIMPOSTTAGLIST/$tags/g' -- -name="$POST_NAME" -date="$DATE" -num="$k" -des="$DESC" -tags="$TAGS" ./assets/html/post-link.html)
		all_posts=$all_posts$post_element
		k=$(($k+1))
	done
	git rm -f archive.html
	archive_page=$(perl -s -p -e's/STATIMPOSTSGRID/$to/g' -- -to="$all_posts" ./assets/html/archive.html)
	echo $archive_page > archive.html
	git add ./archive.html
	echo "archive page build complete"
}

###########################################################
## Build index page with index template and recent posts ##
###########################################################
buildindex()
{
	###########################################
	# Populate the recent posts in front page #
	###########################################
	echo "building index page"
	recent_posts=""
	j=1
	for post in $(ls -t src | head -9)
	do
		source $proj_dir/src/$post/meta.dat
		echo "	creating index entry "$post
		post_element=$(perl -s -p -e's/STATIMPOSTNAME/$name/g,s/STATIMPOSTDATE/$date/g,s/STATIMPOSTNUMBER/$num/g,s/STATIMPOSTDES/$des/g,s/STATIMPOSTTAGLIST/$tags/g' -- -name="$POST_NAME" -date="$DATE" -num="$j" -des="$DESC" -tags="$TAGS" ./assets/html/post-link.html)
		recent_posts=$recent_posts$post_element
		j=$(($j+1))
	done
	########################
	# Fill up the tag list #
	########################
	echo "filling tag list"
	tagstring=""
	for tag in $(ls -t ./src/.tags )
	do 
			tag_element=$(perl -s -p -e's/STATIMTAGNAME/$to/g' -- -to="$tag" ./assets/html/index-tag-link.html)
			tagstring=$tagstring$tag_element
	done
	git rm -f index.html
	index_page=$(perl -s -p -e's/STATIMPOSTSGRID/$to/g,s/STATIMPOSTTAGLINKS/$tags/g' -- -to="$recent_posts" -tags="$tagstring" ./assets/html/index.html)
	echo $index_page > ./index.html
	git add ./index.html
	echo "index page build complete"

}

###################################################################
## Build the tag page for given tag with links and desc of posts ##
###################################################################
buildtag()
{
	local tag=$1
	all_posts=""
	k=1
	for post in $(cat ./src/.tags/$tag)
	do
		source ./src/$post/meta.dat
		echo " creating archive entry"$post
		post_element=$(perl -s -p -e's/STATIMPOSTNAME/$name/g,s/STATIMPOSTDATE/$date/g,s/STATIMPOSTNUMBER/$num/g,s/STATIMPOSTDES/$des/g,s/STATIMPOSTTAGLIST/$tags/g' -- -name="$POST_NAME" -date="$DATE" -num="$k" -des="$DESC" -tags="$TAGS" ./assets/html/post-tag-link.html)
		all_posts=$all_posts$post_element
		k=$(($k+1))
	done
	archive_page=$(perl -s -p -e's/STATIMPOSTSGRID/$to/g,s/STATIMTAGNAME/$tag/g' -- -to="$all_posts" -tag="$tag" ./assets/html/tag-index.html)
	echo $archive_page > ./build/tags/$tag.html
	git add ./build/tags/$tag.html
	echo "tag build complete"
}

##########################################################################
## Build a single post md to html conversion with pandoc and templating ##
##########################################################################
buildpost()
{
	local proj_dir=$1
	local post_name=$2
	local next_post=$3
	post_dir="src/"$post_name
	echo "Building post in project :: "$proj_dir" post :: "$post_dir
	source $post_dir/meta.dat
	# Convert post content from md to html
	html_content=$(pandoc -t html $post_dir/$post_name.md)

	# Generate html for tags
	tagstring=""
	for tag in $TAGS
	do 
			tag_element=$(perl -s -p -e's/STATIMTAGNAME/$to/g' -- -to="$tag" ./assets/html/tag-link.html)
			tagstring=$tagstring$tag_element
	done

	# Generate next post link
	if [ -z $next_post ]
	then
		next_post_link="../../index.html"	
		next_post="HOME"
	else
		next_post_link="../../build/"$next_post"/$next_post.html"	
	fi
	next_link=$(perl -s -p -e's/STATIMNEXTLINK/$link/g,s/STATIMNEXTNAME/$name/g' -- -link="$next_post_link" -name="$next_post" ./assets/html/next-post.html)
	echo "built next link for :: "$post_name " :: "$next_post

	
	
	# Use perl regex to fill up our template with generated content
	built_page=$(perl -s -p -e's/STATIMTITLE/$title/g,s/STATIMPOSTCONTENT/$content/g,s/STATIMPOSTTAGLINKS/$tags/g,s/STATIMNEXT/$next/g' -- -title="$post_name" -content="$html_content" -tags="$tagstring" -next="$next_link" ./assets/html/post.html)	
	mkdir build/$post_name
	echo $built_page > ./build/$post_name/$post_name.html
	cp -r $post_dir/img ./build/$post_name/img
	git add ./build/$post_name
	echo "built post :: "$post_name
}


#################################
## Processing args and options ##
#################################

## default options and paths

statim_dir=$(dirname "$0")
proj_name="my-blog"
dest="."
template="w3-template"

OPTIND=1
while getopts "h:" opt; do
	case ${opt} in
		h )
			usage
			exit 0
			;;
		\? )
			echo "Invalid option -$OPTARG"
			usage
			exit 1
			;;
	esac
done
shift $((OPTIND -1))

subcommand=$1;shift

case "$subcommand" in 

	ls )
		templates
		exit 0
		;;

	init )
		while getopts "d:t:" opt; do
			case ${opt} in 
				d )
					dest=$OPTARG
					echo  "Destination specified :: "$dest
					;;
				t )
					template=$OPTARG
					echo "Selected template :: "$template
					;;
				\? )
					echo "Invalid option -$OPTARG"
					usage
					exit 1
					;;
				: )
					echo "Invalid option -$OPTARG requires argument"
					usage
					exit 1
					;;
			esac
		done
		shift $((OPTIND -1))
		if [ ! -z $1 ] ; then 
			proj_name=$1;shift
		fi
		echo "project name is :: "$proj_name
		dirsetup $dest $proj_name
		filesetup $dest $proj_name $template
		exit 0
		;;

	new )
		while getopts "d:t:" opt; do
			case ${opt} in
				d ) 
					dest=$OPTARG
					echo "Project directory path specified :: "$dest
					;;
				t )
					tag_string=$OPTARG
					echo "Tagged post"
					;;
				\? )
					echo "Invalid option -$OPTARG"
					usage
					exit 1
					;;
				: )
					echo "Invalid option -$OPTARG requires argument"
					usage
					exit 1
					;;
			esac
		done
		shift $((OPTIND -1))
		if [ ! -z $1 ] ; then 
			post_name=$1;shift
		else 
			usage
			exit 1
		fi

		if [  -f $dest/meta.dat ]; then
			postsetup $dest $post_name $tag_string
		else
			echo "Use statim new in project directory or specify path using -d flag"
			usage
			exit 1
		fi
		exit 0
		;;

	build)
		while getopts "d:" opt; do
			case ${opt} in
				d ) 
					dest=$OPTARG
					echo "Project directory path specified :: "$dest
					;;
				\? )
					echo "Invalid option -$OPTARG"
					usage
					exit 1
					;;
				: )
					echo "Invalid option -$OPTARG requires argument"
					usage
					exit 1
					;;
			esac
		done
		shift $((OPTIND -1))
		if [ -f $dest/meta.dat ]; then
			buildall $dest
		else 
			usage
			exit 1
		fi
		exit 0
		;;
	* )
		echo "Invalid subcommand -$subcommand"
		usage
		exit 1
esac

