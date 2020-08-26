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
	echo "		statim init [-t] <target-dir> <blog-dir-name>	set up new blog directory.	"
	echo "		statim new  <new-post-name>	create new blog post		"
	echo "		build				build and commit changes	"
	echo
	echo
}

##############################
## Directory setup for init ##
##############################

dirsetup()
{
	local dir_path=$1/$2
	echo "Initializing project at "$dir_path
	mkdir $dir_path
}



#################################
## Processing args and options ##
#################################

blogdir="my-blog"
target="."

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
	init )
		blogdir=$1;shift
		while getopts "t:" opt; do
			case ${opt} in 
				t )
					target=$OPTARG
					echo "In target case"$target
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
		dirsetup $target $blogdir
		;;

	new )
		
		;;

	build)
		;;
	* )
		echo "Invalid subcommand -$subcommand"
		usage
		exit 1
esac

