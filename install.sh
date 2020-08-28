## Install pandoc
##sudo apt-get update -y
##sudo apt-get install pandoc -y

statimdir=$(pwd)
echo "The app directory is set as " $statimdir
chmod +x $statimdir/statim.sh
echo "Made script :: statim.sh executable"
echo "alias statim='"$statimdir"/statim.sh'" >> ~/.bashrc
echo "added aliases to ~/.bashrc"
exec bash
