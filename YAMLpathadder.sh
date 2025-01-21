#Can be used to copy pizza-paper.sh to one of your PATH folders, mainly so that you don't have to be in a specific directory to use it and I don't like it ending with .sh (github requires it)
#YOU DO NOT NEED TO RUN THIS, IT IS COMPLETELY **OPTIONAL** AND IS ONLY FOR MILD CONVENIENCE AND DEVELOPMENT

user="pizza2d1"

RemoveFile (){
  if test -f /usr/local/bin/pizzapaper; then		  #If pizzapaper is found in the path file, then it will delete it
    rm /usr/local/bin/pizzapaper
  else
    echo "pizzapaper was not found in that directory, it may have already been removed"
  fi
}

AddFile (){
  if ! test -f /usr/local/bin/pizzapaper; then		#If pizzapaper is NOT found in the path file, it will add it
    if test -f */pizzapaper; then
      cp ./pizza-paper.sh /usr/local/bin/pizzapaper
    else
      cp ./pizzapaper_testing.sh /usr/local/bin/pizzapaper  #This is my personal testing/dev file, you don't need to worry about it
    fi
  else
    echo "pizzapaper is already in the path directory: /usr/local/bin/"
  fi
}

####DEV TOOLS#### Note: all files that are deleted will be remade when running ./pizzapaper // pizza-paper.sh as the actual user
ResetFiles (){
  rm -rf /home/$user/Pictures/pizza-papers
}
# ResetSettings (){
#   rm /home/$user/Pictures/pizza-papers/settings.yaml
# }

options=$(getopt -o ar,add,remove --long "add,remove,retard,copy" -- "$@")
[ $? -eq 0 ] || { 
    echo "Incorrect options provided"
    exit 1
}
eval set -- "$options"
while true; do
    case "$1" in
      -a)
         AddFile
         exit;;
      -r)
         RemoveFile
         exit;;
      \?)
         echo "Invalid option"
         exit;;
    --add)
        shift;
        AddFile
        exit;;
    --remove)
        shift;
        RemoveFile
        exit;;
    --retard) #users don't use this, fuck off)
        shift;
        echo "Resetting pizzapaper contents"
        sleep 0.2
        ResetFiles
        # echo "Resetting settings"
        # sleep 0.2
        # ResetSettings
        gsettings set org.gnome.desktop.background picture-uri "file:///usr/share/backgrounds/warty-final-ubuntu.png"
        gsettings set org.gnome.desktop.background picture-uri-dark "file:///usr/share/backgrounds/warty-final-ubuntu.png"
        exit;;
    --copy)
        shift;
        cp /home/pizza2d1/pizzapaper_testing.sh /home/pizza2d1/pizza-paper.sh
        exit;;
    --version)
        shift;
        echo "Why would this have a version number, dumbass"
        exit;;
    --)
        shift
        break
        ;;
    esac
    shift
done

echo -e "\nThis lets you add or remove the pizza-paper.sh file to your \$PATH folder, specifically the /usr/local/bin/ folder (which is generally empty so it's easy to find)"
echo -e "To run this file, you have to provide an argument as either\n"
echo -e " ./pizza_path_partner -add   		Add the pizza-paper.sh file to /usr/local/bin/ to be able to execute it as \"pizzapaper [ARG]\" instead"
echo -e " ./pizza_path_partner -remove		Removes the pizzapaper file from your \$PATH folder\n"
echo -e "Make sure you are doing this in sudo, as it was made to modify your machine folders which are locked behind admin perms"
