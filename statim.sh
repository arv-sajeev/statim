#! /bin/bash

#######################
## The usage display ##
#######################

usage()
{
	echo "Usage :: $0 [options...] [init|new|build]					" 
	echo
	echo "OPTIONS									"
	echo "		statim -h			Display usage info.		"	
	echo
	echo "SUBCOMMANDS								"
	echo "		statim ls								Display available templates	"
	echo "		statim init  <blog-dir-name> [-d] <target-dir> [-t] <template-name>	set up new blog directory.	"
	echo "		statim new  <new-post-name>						create new blog post		"
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
	echo "Init complete"
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
		if [ ! -z $1 ] ; then 
			proj_name=$1;shift
		fi
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
		dirsetup $dest $proj_name
		filesetup $dest $proj_name $template
		exit 0
		;;

	new )
		exit 0
		
		;;

	build)
		exit 0
		;;
	* )
		echo "Invalid subcommand -$subcommand"
		usage
		exit 1
esac

