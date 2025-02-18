#This is my own little thing that I made to switch up desktop wallpapers, it sucks but I think it works best for me
#To get instructions on how to run this you can just execute it or look on github for "How to use"

VERSION=$"pizzapaper 1.2.6 yaml"	                #Tells the user the current version
user=$(whoami)							                      #Gets the username of the person calling the program so that it only affects that user's desktop
WallpaperPathList=()						                  #Stores custom wallpaper file locations            
ROTATION_SPEED=2 #Seconds                         #Will determine how fast wallpapers will rotate with the rotatewallaper function
#I like these variables better ^^^^^ so they get to be at the top

#Necessary checks needed for redundancy and being more user-friendly
if [ -d /home/pizza2d1 ]; then				                                                #I AM THE ADMIN I GET SPECIAL PRIVILEGES BITCHES
  IAMGOD=true
else
  IAMGOD=false
fi
if [ -f /usr/local/bin/pizzapaper ]; then			                                        #ProgName will be used to swap between "pizza-paper.sh" and "pizzapaper" depending on what the user has installed for convenience
  ProgName="pizzapaper"                             
elif [ -f ./pizza-paper.sh ]; then
  ProgName="./pizza-paper.sh"
fi
#Checks to see if the user decided to download all the included wallpapers (pizzapaper --sample)
if [ -f /home/$user/Pictures/pizza-papers/mountains.jpg ] && [ -f /home/$user/Pictures/pizza-papers/astolfo.jpg ] && [ -f /home/$user/Pictures/pizza-papers/sunglasses.jpeg ] && [ -f /home/$user/Pictures/pizza-papers/TRAINS.jpg ]; then
  ShortHelpFlag="|m|a|s|t"                                                            #Will display sample wallpaper options if the user has them downloaded
  SampleWallpaperStatus=""                                                            #Will NOT say something if the user has sample images
  YesYouHaveIt="(If you would like to delete them, use \"$ProgName --sample remove\")"          #Will tell the user if they have the sample images if it detects them
  WallpaperAccess=true                                                                #Will allow the user to access the sample images now that they're downloaded
else
  ShortHelpFlag=""                                                                    #Will display sample wallpaper options if the user has them downloaded (they dont)
  SampleWallpaperStatus=" (Must use --sample argument to install sample wallpapers)"  #The double spacing is needed to make sure that the variable doesn't touch the text in the help command
  YesYouHaveIt="(I recommend that you do)"                                            #No they don't have it
  WallpaperAccess=false                                                               #Will prevent the user from triggering the sample wallpaper functions because they haven't been downloaded
fi
###########################################

#Adds the neccessary directories and files in case the user doesn't have them
if [ ! -d "/home/$user/Pictures" ]; then                              #Makes a Pictures directory in case you are a little weird idiot that feels like they're better than everyone else, along with making a directory for custom wallpapers
  echo "wtf why don't you have a Pictures folder, making one now to store your custom wallpapers..."
  mkdir /home/$user/Pictures
fi
if [ ! -d "/home/$user/Pictures/pizza-papers" ]; then                 #Will make a pizzapapers directory that will store you custom wallpapers
  mkdir /home/$user/Pictures/pizza-papers
fi
if [ ! -f "/home/$user/Pictures/pizza-papers/settings.yaml" ]; then    #Creates a settings.yaml file if the user does not have it to store settings such as "show cli" or "open with selector"
  OriginalWallpaper=$(gsettings get org.gnome.desktop.background picture-uri-dark)
  if [[ $OriginalWallpaper == *"file://"* ]]; then
    OWallpaperPath=${OriginalWallpaper:8:-1}
  else
    OWallpaperPath=$OriginalWallpaper
  fi
  touch /home/$user/Pictures/pizza-papers/settings.yaml
  echo "settings:" > /home/$user/Pictures/pizza-papers/settings.yaml
  echo "defaultWallpaper:" >> /home/$user/Pictures/pizza-papers/settings.yaml
  echo "customWallpapers:" >> /home/$user/Pictures/pizza-papers/settings.yaml
  yq -yi ".settings.enableCLI = false
          |.settings.defaultFunction = 1
          |.settings.addSelectedFile = true
          |.defaultWallpaper = \"$OWallpaperPath\"" /home/$user/Pictures/pizza-papers/settings.yaml
fi

if [[ ! $(yq -r '.customWallpapers' /home/$user/Pictures/pizza-papers/settings.yaml) == null ]]; then #Checks to make sure that the "customWallpapers" dictionary is not empty
  for DictItem in $(yq -r '.customWallpapers[]' /home/$user/Pictures/pizza-papers/settings.yaml); do
    WallpaperPathList+=("$DictItem")
  done
fi

MessyDWall=$(yq -r '.defaultWallpaper' /home/$user/Pictures/pizza-papers/settings.yaml)
DefaultWallpaper=${MessyDWall:1:-1}

###########################################

#MAIN FUNCTIONS

function Less_Help (){                        #Runs when there are no arguments and whent the user inputs "pizzapaper -h"
  echo -e "\nPick which argument you want to use with \"$ProgName [-h$ShortHelpFlag | --help|add|select|sample|remove|settings|version]\"\n (The --help option may be more helpful)\n"
  if [[ ! $ProgName == *"pizzapaper"* ]]; then
    echo -e "OPTIONAL:"
    echo -e "   If you would like to run the program as \"pizzapaper [ARG]\" (as I recommend) you will have to run \"sudo ./pizza_path_partner -add\" to add pizzapaper to your \$PATH files"
    echo -e "   To remove the pizzapaper file in your \$PATH directory, use \"sudo path-adder.sh -remove\" OR \"sudo rm /usr/local/bin/pizzapaper\""
    echo -e "   After you run it, you can delete pizza-paper.sh :3\n"
  fi
}

function Help_Options (){                     #Gives the user instructions on how to use the program
  echo -e "I hate most --help descriptors that normal commands have that are overly-confusing, so I'm going to try to make this simple enough that a younger me could understand it\n"
  echo -e "$ProgName is a custom program that I made as a passion project to learn how to switch wallpapers in terminal, which eventually turned into a full passion project on learning how a small area of display bash-scripting works. Im also attempting to learn git commands alongside this so that I might become a better programmer and because I think it's interesting\n"
  echo -e "To use this command you must do:\n  $ProgName [ARG]"
  echo -e "  E.G. \"$ProgName -h\", \"$ProgName --sample\", or \"$ProgName --add\"\n\n"
  echo -e "   -h                 Gives the user a simple idea of what options to choose\n"
  echo -e "   -m | -mountain     Switches wallpaper to a mountainside           $SampleWallpaperStatus\n"
  echo -e "   -a | -astolfo      Switches wallpaper to Astolfo                  $SampleWallpaperStatus\n"
  echo -e "   -s | -sunglasses   Switches wallpaper to sunglasses on a beach    $SampleWallpaperStatus\n"
  echo -e "   -t | -train        Switches wallpaper to a picture of a train     $SampleWallpaperStatus\n"
  echo -e "  --sample            Will download sample images $YesYouHaveIt\n"
  echo -e "  --add               Lets you add custom wallpapers to a text file that you can select from (in the future), USAGE: --add | --add [Image URL]\n"
  echo -e "  --select            Lets you select what wallpaper you want to use out of your custom wallpapers that you have added, USAGE: --select | --select [wallpaper number]\n"
  echo -e "  --remove            Lets you remove a single or multiple wallpapers from your pizzapapers list/folder\n"
  echo -e "  --settings          Lets you select different settings that might be more useful to you\n"
  echo -e "  --rotate            Will rotate through all of your saved wallpapers\n"
  echo -e "  --version           Echos the current $ProgName version\n"
  echo -e "  --help              Will display this, a much more detailed explanation on how to use this program and its arguments\n\n"
}

function AddWallpaper (){                     #Will let the user add a wallpaper from their computer files

  echo -e "How would you like to add your custom wallpaper?:\n"
  echo -e "  1. File selection        Will add a wallpaper from your local computer storage"
  echo -e "  2. Web image URL         Will take a image URL and download it to your /Pictures/pizza-papers/ directory\n"
  read -p "[1/2]: " uinput
  AddToSet=$(echo "AddToSet" | GetSettings)
  if [[ $uinput == "1" || $uinput == *"ile"* ]]; then                                   #Checks to see if the user chose 1 or file/File
    echo "Select which file(s) you would like to add"                                   #Yes, you can select multiple files
    Files=$(zenity --file-selection --multiple)                                         #Opens file selection to choose image files
    IFS='|'                                                                             #Sets the splice modifier so that "read -ra" splits the $Files string after every "|"
    if [[ $Files == "" ]]; then
      echo "Exiting out"
      exit;
    fi
    read -ra IndividualImages <<< "$Files" #Appends each file name into an array name IndividualImages
    if [[ ${#IndividualImages[@]} == 1 ]] && [[ $AddToSet == true ]]; then
      gsettings set org.gnome.desktop.background picture-uri "$IndividualImages"
      gsettings set org.gnome.desktop.background picture-uri-dark "$IndividualImages"
    fi
    for fileL in "${IndividualImages[@]}"; do   #For each image that the user selected...
      if [[ $fileL == *".jpg"* || $fileL == *".jpeg"* || $fileL == *".png"* ]] && [[ $fileL != *" "* ]]; then  #Will only accept URLs with https and valid image file extensions
        if [[  ${WallpaperPathList[@]} != *"$fileL"* ]]; then					                      #Checks to make sure that PART of $fileL is nowhere in the WallpaperPathList array
          cp "$fileL" /home/$user/Pictures/pizza-papers/                                  #Copies wallpaper file to pizza-papers so it can be selected in gui
          echo "$fileL has been added to your wallpapers"
          fileName=$(basename $fileL | sed -r 's/\.//')
          yq -yi ".customWallpapers.$fileName = \"$fileL\"" /home/$user/Pictures/pizza-papers/settings.yaml
        else
          echo "That wallpaper is already in your list of wallpapers"
        fi
      elif [[ $fileL != "" ]]; then
        echo "$fileName is not a valid image file type"
      else
        echo "You did not make a selection or chose a invalid file type"
      fi
    done
  elif [[ $uinput == "2" || $uinput == *"eb"* || $uinput == *"URL"* ]]; then           #Checks to see if the user chose 2 or web/Web/URL
    URL=$(zenity --entry --title="Please input a image URL")
    if [[ $URL == *".jpg"* || $URL == *".jpeg"* || $URL == *".png"* ]]; then           #Will only accept files that contain image extensions
      if [[  ${WallpaperPathList[@]} != *"$URL"* ]]; then					                         #Checks to make sure that PART of $fileL is nowhere in the WallpaperPathList array
        fileName=$(basename "$URL")
        newFileName=$(echo "$fileName" | sed 's/[[:punct:]]//g')
        cd /home/$user/Pictures/pizza-papers/ && { curl -O "$URL" ; cd -; }            #Downloads the URL image to the pizza-papers directory   ##################################
        echo "$newFileName has been added to your wallpapers"
        yq -yi ".customWallpapers.\"$newFileName\" = \"/home/$user/Pictures/pizza-papers/$fileName\"" /home/$user/Pictures/pizza-papers/settings.yaml
        if [[ $AddToSet == true ]]; then ##################Adding same url image issue
          gsettings set org.gnome.desktop.background picture-uri /home/$user/Pictures/pizza-papers/$fileName
          gsettings set org.gnome.desktop.background picture-uri-dark /home/$user/Pictures/pizza-papers/$fileName
        fi
      else
        echo "That wallpaper is already in your list of wallpapers"
      fi
    elif [[ $URL == "" ]]; then
      echo "No link provided, exiting"
    else
      echo -e "Invalid link, make sure it contains an image extension type, E.G. \"IMAGE-NAME.[png | jpg | jpeg]\""  
    fi
  else
    echo -e "\nInvalid input\n"
  fi
}

function SelectWallpaper (){                  #The user chooses a wallpaper that they they have stored in a directory that they added using AddWallpaper
  if [[ $WallpaperPathList == "" ]]; then           #Will check to make sure that the user has entered any wallpapers yet
    echo -e "\nYou do not have any custom wallpapers, you can add some by using $ProgName --add\n"
    exit;
  fi
  echo -e "\n  0   Remove A Wallpaper"							  #A new option that will be made useful later to remove custom wallpapers from the list
  Num=1
  for LINE in ${WallpaperPathList[@]}; do           #A loop that encompasses ALL items in the WallpaperPathList array
    ImageName="$(basename $LINE)"               #Takes the substring value of the image by removing the parent directories from the string
    echo "  $Num   $ImageName"								  #Displays the wallpaper FILE name and its number selection choice
    ((Num+=1))
  done
  echo "" #Just a spacer
  read -p "Which wallpaper would you like to choose?: " uinput				#Has the user input a selection in the terminal #REFERENCE#
  re='^[0-9]+$'
  if [[ $uinput == "0" ]]; then                 #Will check that the user wanted to delete a wallpaper
    echo -e "\n  0   Exit"
    Num=1
    for LINE in ${WallpaperPathList[@]}; do
      ImageName="$(basename $LINE)"
      echo "  $Num   $ImageName"
      ((Num+=1))
    done
    echo ""
    read -p "Which wallpaper would you like to remove?: " uinput  #Takes user input
    if [[ $uinput == "0" || $uinput == "" ]]; then
      echo "No wallpaper was deleted, exiting"
    elif [[ $uinput =~ $re ]]; then           #Checks to see that the user's input is a number (except 0) to remove a custom wallpaper
      echo -e "\nRemoved ${WallpaperPathList[ (($uinput-1)) ]} from your list of wallpapers\n(note that this does not delete the actual image file in your system)\n"
      WallpaperKey=$(basename "${WallpaperPathList[ (($uinput-1)) ]}" | sed -r 's/\.//')
      yq -yi "del(.customWallpapers.$WallpaperKey)" /home/$user/Pictures/pizza-papers/settings.yaml                         #Gets rid of the wallpaper the user chose
    fi
    exit;
  fi
  if [[ $uinput =~ $re ]] && [[ $uinput -lt $((${#WallpaperPathList[@]}+1)) ]]; then								#Checks to see that the user's input is a number
    SelectedWallpaper=${WallpaperPathList[ (($uinput-1)) ]}
    echo "$SelectedWallpaper is now your new wallpaper"
    gsettings set org.gnome.desktop.background picture-uri-dark / #Resets wallpaper to prevent the selected wallpaper from not refreshing
    gsettings set org.gnome.desktop.background picture-uri-dark $SelectedWallpaper
    gsettings set org.gnome.desktop.background picture-uri $SelectedWallpaper
  else
    echo "Invalid input"
  fi
}

function GUISelectWallpaper (){               #The user chooses a wallpaper out of their custom wallpapers from a feh gui image selector
  if test -e /home/$user/Pictures/pizza-papers/; then
    touch TEMPLIST.txt
    if [[ ${#WallpaperPathList[@]} -lt 8 ]]; then #If there are LESS THAN (-lt) 8 images in the WallpaperPathList array then feh will display the images larger for selection
      FehImageHeight=256
      FehImageWidth=216
    else
      FehImageHeight=128
      FehImageWidth=108
    fi
    feh -t /home/$user/Pictures/pizza-papers/ -E $FehImageHeight -y $FehImageWidth --action 'echo %n >> ./TEMPLIST.txt'  #Opens a feh GUI in "thumbnail" mode so that that user can select a wallpaper from their list that they can see/select from
    FirstImage=$(head -n 1 ./TEMPLIST.txt)
    if [[ $FirstImage == "" ]]; then
      echo "You did not select an image"
    else
      echo "$FirstImage is now your desktop wallpaper"
      gsettings set org.gnome.desktop.background picture-uri-dark /home/$user/Pictures/pizza-papers/$FirstImage
      gsettings set org.gnome.desktop.background picture-uri /home/$user/Pictures/pizza-papers/$FirstImage
    fi
    rm ./TEMPLIST.txt
    exit;
  else
    echo "You do not have any custom wallpapers"
    exit;
  fi
}

function RemoveWallpaper (){                  #The user can choose what wallpaper(s) they want to delete
  echo "Select the wallpaper(s) you would like to remove"
  if [ -e /home/$user/Pictures/pizza-papers/ ]; then  #Checks if there are any files in the pizza-papers directory
    touch TEMPLIST.txt   #Can't use zenity to choose what files to delete because I can't automatically make zenity open to the /Pictures/pizza-papers directory
    feh -t /home/$user/Pictures/pizza-papers/ -E 128 -y 128 -W 1024 --action 'echo %n >> ./TEMPLIST.txt; exit;' #Thumbnail mode displaying small previews of wallpapers that the user can select
    for SingleImage in $(cat ./TEMPLIST.txt); do
      if [[ $SingleImage == "" ]]; then
        echo "You did not select an image"
        exit;
      fi
      if [[ $SingleImage != *".jpg"* && $SingleImage != *".jpeg"* && $SingleImage != *".png"* ]]; then
        echo -e "\nyou have selected a invalid image, make sure it does not contain any white-spaces, to force remove invalid image you must have \"CLI Selection\" settings enabled and THEN delete it in $ProgName --selection\n"
        exit;
      fi
      read -p "Are you sure you want to delete $SingleImage? [y/N]: " UserConfimation  #If the user selects a wallpaper, it will ask for confirmation that they want to delete it and store the input as $UserConfirmation
      if [[ $UserConfimation == *"y"* ]]; then
        rm /home/$user/Pictures/pizza-papers/$SingleImage
        echo "Deleted $SingleImage"
        SingleImageKey=$(echo $SingleImage | sed -r 's/\.//')
        yq -yi "del(.customWallpapers.$SingleImageKey)" /home/$user/Pictures/pizza-papers/settings.yaml
      else
        echo "Did not delete $SingleImage"
      fi
    done
    rm ./TEMPLIST.txt
    FallbackWallpaper     #If the user deletes their current wallpaper (which is stored in the pizza-papers folder) the default wallpaper will be set
    exit;
  else
    echo "You do not have any custom wallpapers"
    exit;
  fi
}

function Settings (){                         #Will allow the user to change settings in the CLI to let them determine default function that runs when the user does not provide an argument (current: LessHelp)
  DisplayCurrentDefault
  GetSettings
  echo "" #adds a spacer
  read -p "What setting do you want to change? [1/2/3/4]: " uinput
  while [[ $uinput != "" ]]; do
    if [[ $uinput == "1" ]]; then
      Setting1        #Used for enabling CLI interface
      DisplayCurrentDefault
      GetSettings
      echo "" #adds a spacer
    elif [[ $uinput == "2" ]]; then
      Setting2        #Used for changing the default function
      DisplayCurrentDefault
      GetSettings
      echo "" #adds a spacer
    elif [[ $uinput == "3" ]]; then
      Setting3        #Used for if the user wants to set new wallpapers
      DisplayCurrentDefault
      GetSettings
      echo "" #adds a spacer
    elif [[ $uinput == "4" ]]; then
      Setting4        #Used to set the default wallpaper
      DisplayCurrentDefault
      GetSettings
      echo "" #adds a spacer
    else
      echo "Invalid input"
      exit
    fi
    read -p "What setting do you want to change? [1/2/3/4]: " uinput
  done
  echo "Exiting"
  exit;

}

function FallbackWallpaper (){                #If the user deletes their current wallpaper, they can run pizzapaper again to set it back to their default wallpaper when they first ran the program
  CurrentWallpaper=$(gsettings get org.gnome.desktop.background picture-uri)
  CurrentWallpaperDark=$(gsettings get org.gnome.desktop.background picture-uri-dark)
  if [[ $CurrentWallpaper == *"file://"* ]]; then
    CurrentWallpaper=${CurrentWallpaper:8:-1}
  fi
  if [[ $CurrentWallpaperDark == *"file://"* ]]; then
    CurrentWallpaperDark=${CurrentWallpaperDark:8:-1}
  fi
  if [ ! -f ${CurrentWallpaper:1:-1} ] && [ ! -f ${CurrentWallpaperDark:1:-1} ]; then
    echo -e "\nLooks like you deleted your current wallpaper, reverting back to your original wallpaper\n"
    gsettings set org.gnome.desktop.background picture-uri "$DefaultWallpaper"
    gsettings set org.gnome.desktop.background picture-uri-dark "$DefaultWallpaper"
  fi
}

function RotateWallpaper (){
  CurrentWallpaper=$(gsettings get org.gnome.desktop.background picture-uri)
  if [[ ${WallpaperPathList[@]} == *${CurrentWallpaper:1:-1}* ]]; then
    for item in $(seq 0 ${#WallpaperPathList[@]}); do
      if [[ ${WallpaperPathList[$item]} == *${CurrentWallpaper:1:-1}* ]]; then
        Index=$item;
      fi
    done
    for i in $(seq $Index $((${#WallpaperPathList[@]}-1))); do
      if [[ ${WallpaperPathList[i]} != *"astolfo"* ]]; then #################### Prevents the astolfo wallpaper from showing up randomly in class (fuck fuck fuck I messed up)
        gsettings set org.gnome.desktop.background picture-uri "${WallpaperPathList[i]}"
        gsettings set org.gnome.desktop.background picture-uri-dark "${WallpaperPathList[i]}"
        sleep $ROTATION_SPEED
      fi
    done
  fi
  while true; do
    CurrentWallpaper=$(gsettings get org.gnome.desktop.background picture-uri)
    CurrentWallpaperDark=$(gsettings get org.gnome.desktop.background picture-uri-dark)
    if [[ $CurrentWallpaper != $CurrentWallpaperDark ]]; then
      $CurrentWallpaperDark=$CurrentWallpaper
    fi
    for i in $(seq 0 $((${#WallpaperPathList[@]}-1))); do
      if [[ ${WallpaperPathList[i]} != *"astolfo"* ]]; then
        gsettings set org.gnome.desktop.background picture-uri "${WallpaperPathList[i]}"
        gsettings set org.gnome.desktop.background picture-uri-dark "${WallpaperPathList[i]}"
        sleep $ROTATION_SPEED
      fi
    done
  done
}
##########################################

#Smaller functions that are only for clean code and ease of development

function GetSettings() {  #Will return number values depending on what was piped into it
  SettingsArray=()
  re='^[0-9]+$'
  for ITEM in $(yq -r '.settings[]' /home/$user/Pictures/pizza-papers/settings.yaml); do  #Gets all number values in settings files (numbers are the data being used)
    if [[ $ITEM =~ $re ]]; then
      SettingsArray+=($ITEM)
    fi
  done

  #Will display settings and what value they are
  if [ -t 0 ]; then #Will check if a value has NOT been piped INTO the function, running [ -t 1 ] again will test if the function is being piped OUT of the function
    echo -e "Enable CLI Selection:  $(yq '.settings.enableCLI' /home/$user/Pictures/pizza-papers/settings.yaml)     #Lets the user use CLI instead of the default GUI selectors"
    echo -e "Default Function:      $(yq '.settings.defaultFunction' /home/$user/Pictures/pizza-papers/settings.yaml)        #Decides what main function will run when pizza-paper is executed without arguments (LessHelp, Help_Options, AddWallpaper, SelectWallpaper)"
    echo -e "Select when adding:    $(yq '.settings.addSelectedFile' /home/$user/Pictures/pizza-papers/settings.yaml)     #When the user adds a new wallpaper it will automatically make it their wallpaper"
    echo -e "Set default wallpaper           #Will set the user's current wallpaper as the default wallpaper to fallback on when the current wallpaper is deleted"
    return
  fi

  read PipedValue #Since there WAS a piped value we can read it without the program getting softlocked and get a return value :3
  if [[ $PipedValue == "WantCLI" ]]; then
    echo $(yq '.settings.enableCLI' /home/$user/Pictures/pizza-papers/settings.yaml)
  elif [[ $PipedValue == "Default" ]]; then
    echo $(yq '.settings.defaultFunction' /home/$user/Pictures/pizza-papers/settings.yaml)
  elif [[ $PipedValue == "AddToSet" ]]; then
    echo $(yq '.settings.addSelectedFile' /home/$user/Pictures/pizza-papers/settings.yaml)
  else
    echo "How did this happen"
  fi
}

function DisplayCurrentDefault (){
  SettingValue=$(echo "Default" | GetSettings)
  if [[ $SettingValue == "1" ]]; then
    echo "###########################################"
    echo -e "\nCurrent Default Function:    LessHelp -----------> Will display a short amount of arguments the user can do\n"
  elif [[ $SettingValue == "2" ]]; then
    echo "###########################################"
    echo -e "\nCurrent Default Function:    MoreHelp -----------> Will display all arguments and descriptions that the user can do\n"
  elif [[ $SettingValue == "3" ]]; then
    echo "###########################################"
    echo -e "\nCurrent Default Function:    AddWallpaper -------> Will allow the user to add a wallpaper from their file system or image URL\n"
  else
    echo "###########################################"
    echo -e "\nCurrent Default Function:    SelectWallpaper ----> Will prompt the user to select a wallpaper from their pizza-papers folder\n"
  fi
}

function Setting1 (){     #Used for enabling CLI interface
  #Switches the value of the first setting
  if [[ $(yq '.settings.enableCLI' /home/$user/Pictures/pizza-papers/settings.yaml) == true ]]; then
    yq -yi '.settings.enableCLI = false' /home/$user/Pictures/pizza-papers/settings.yaml
  else
    yq -yi '.settings.enableCLI = true' /home/$user/Pictures/pizza-papers/settings.yaml
  fi
}

function Setting2 (){     #Used for changing the default function...
  #Switches the value of the first setting
  if [[ $(yq '.settings.defaultFunction' /home/$user/Pictures/pizza-papers/settings.yaml) == 4 ]]; then
    yq -yi '.settings.defaultFunction = 1' /home/$user/Pictures/pizza-papers/settings.yaml
  else
    DFValue=$(yq '.settings.defaultFunction' /home/$user/Pictures/pizza-papers/settings.yaml)
    ((DFValue+=1))
    yq -yi ".settings.defaultFunction = $DFValue" /home/$user/Pictures/pizza-papers/settings.yaml
  fi
}

function Setting3 (){     #Used for if the user wants to set new wallpapers
  #Switches the value of the first setting
  if [[ $(yq '.settings.addSelectedFile' /home/$user/Pictures/pizza-papers/settings.yaml) == true ]]; then
    yq -yi '.settings.addSelectedFile = false' /home/$user/Pictures/pizza-papers/settings.yaml
  else
    yq -yi '.settings.addSelectedFile = true' /home/$user/Pictures/pizza-papers/settings.yaml
  fi
}

function Setting4 (){     #Used to set the default wallpaper
  NewDefaultWallpaper=$(gsettings get org.gnome.desktop.background picture-uri-dark)
  yq -yi ".defaultWallpaper = \"$NewDefaultWallpaper\"" /home/$user/Pictures/pizza-papers/settings.yaml
  echo -e "\n##########################\nSet $NewDefaultWallpaper as your new default wallpaper\n##########################\n"
}
##########################################


#For setting the SAMPLE wallpapers, the user might either have "picture-uri-dark" or "picture-uri" being displayed, so its best to just set both of them.-
#-Think of them like layers, where on one system picture-uri is on top of picture-uri-dark and vice versa, we just change both so we dont deal with it
function Mountain_Wallpaper (){		  #Sets the wallpaper to a cool mountainside
  gsettings set org.gnome.desktop.background picture-uri-dark / #Resets wallpaper to prevent the selected wallpaper from not refreshing
  gsettings set org.gnome.desktop.background picture-uri-dark file:///home/$user/Pictures/pizza-papers/mountains.jpg
  gsettings set org.gnome.desktop.background picture-uri file:///home/$user/Pictures/pizza-papers/mountains.jpg
}
function Astolfo_Wallpaper (){		  #Sets the wallpaper to astolfo because I have a feeling my friends will open it
  gsettings set org.gnome.desktop.background picture-uri-dark / #Resets wallpaper to prevent the selected wallpaper from not refreshing
  gsettings set org.gnome.desktop.background picture-uri-dark file:///home/$user/Pictures/pizza-papers/astolfo.jpg
  gsettings set org.gnome.desktop.background picture-uri file:///home/$user/Pictures/pizza-papers/astolfo.jpg
}
function Sunglasses_Wallpaper (){		#Sets the wallpaper to a beach photo with some sunglasses
  gsettings set org.gnome.desktop.background picture-uri-dark / #Resets wallpaper to prevent the selected wallpaper from not refreshing
  gsettings set org.gnome.desktop.background picture-uri-dark file:///home/$user/Pictures/pizza-papers/sunglasses.jpeg
  gsettings set org.gnome.desktop.background picture-uri file:///home/$user/Pictures/pizza-papers/sunglasses.jpeg
}
function Trains_Wallpaper (){	      #Sets the wallpaper to the inside of a autist's mind
  gsettings set org.gnome.desktop.background picture-uri-dark / #Resets wallpaper to prevent the selected wallpaper from not refreshing
  gsettings set org.gnome.desktop.background picture-uri-dark file:///home/$user/Pictures/pizza-papers/TRAINS.jpg
  gsettings set org.gnome.desktop.background picture-uri file:///home/$user/Pictures/pizza-papers/TRAINS.jpg
}
###########################################


#Lists the different options that the user can choose from, "hmast" is for individual letters options like "-h" and "-m"
options=$(getopt -o hmast,help,mountain,astolfo,sunglasses,train --long "add,select,remove,sample,settings,help,version,normal,rotate" -- "$@")
[ $? -eq 0 ] || {
    echo "Incorrect options provided"
    exit 1
}
eval set -- "$options"
while true; do
    case "$1" in
      -h | -help)                   #Will activate when pizzapaper -h is used)
         Less_Help
         exit;;
      -m | -mountain)       #Will make the desktop background a mountainside)
         if $WallpaperAccess; then
           Mountain_Wallpaper
         else
           echo -e "You must run \"$ProgName --sample\" to download these files"
         fi
         exit;;
      -a | -astolfo)        #Will make the desktop background astolfo)
         if $WallpaperAccess; then
           Astolfo_Wallpaper
         else
           echo -e "You must run \"$ProgName --sample\" to download these files"
         fi
         exit;;
      -s | -sunglasses)     #Will make the desktop background some sunglasses)
         if $WallpaperAccess; then
           Sunglasses_Wallpaper
         else
           echo -e "You must run \"$ProgName --sample\" to download these files"
         fi
         exit;;
      -t | -train)          #Will make the desktop background a picture of a train)
         if [[  ${WallpaperPathList[@]} == *"TRAINS.jpg"* ]]; then	
           Trains_Wallpaper
         else
           echo -e "You must run \"$ProgName --sample\" to download these files"
         fi
         exit;;
      \?)                   #Does something, I don't know what, but if I remove it then it breaks so I'll keep it around)
         echo "Invalid option"
         exit;;
    --add)                  #Has the user select a image file's name to add to a text file which lists all custom wallpapers)
        shift;
        if [[ $2 == *"https"* ]] && [[ $2 == *".jpg"* || $2 == *".jpeg"* || $2 == *".png"* ]]; then   #Will only accept URLs with https and valid image file extensions
          if [[  ${WallpaperPathList[@]} != *"$2"* ]]; then					                                      #Checks to make sure that PART of $fileL is nowhere in the WallpaperPathList array
            feh $2 -E 128 -y 128								                                                      #Show the new wallpaper in a -E (height) 128 px and -y (width) 128 px (yes they made -y be width)
            cd /home/pizza2d1/Pictures/pizza-papers/ && { curl -O "$2" ; cd -; }                      #Downloads the URL image to the pizza-papers directory
            shortname=$(basename $2)
            yq -yi ".customWallpapers.$shortname = \"$2\"" /home/$user/Pictures/pizza-papers/settings.yaml
          else
            echo "That wallpaper is already in your list of wallpapers"
          fi
        elif [[ $2 != "" ]]; then
          echo -e "\nInvalid download link, make sure your URL is valid:\n  Usage:  $ProgName --add https-------------.image_extention   (specifically: *.png, *.jpg, and *.jpeg)\n"
        else
          AddWallpaper
        fi
        exit;;
    --select)				        #Lets the user select one of their custom wallpapers in a numbered list along with displaying the choice's names)
        shift;
        if [[ $WallpaperPathList == "" ]]; then           #Will check to make sure that the user has entered any wallpapers yet
          echo -e "\nYou do not have any custom wallpapers, you can add some buy using $ProgName --add\n"
          exit;
        fi
        re='^[0-9]+$'
        if [[ $2 =~ $re ]] && [[ $2 -lt $((${#WallpaperPathList[@]}+1)) ]]; then	#Checks to see that the users second argument is a number (if there even IS and argument)
          echo "$(basename ${WallpaperPathList[$2-1]}) is now your new wallpaper"
          gsettings set org.gnome.desktop.background picture-uri-dark ${WallpaperPathList[ (($2-1)) ]}
          gsettings set org.gnome.desktop.background picture-uri ${WallpaperPathList[ (($2-1)) ]}
        elif [[ $(echo "WantCLI" | GetSettings) == false ]]; then #If the user chose to have a CLI instead of GUI in settings, it will do that instead
          GUISelectWallpaper
        else
          SelectWallpaper
        fi
        exit;;
    --remove)               #Opens a feh GUI in "thumbnail" mode so that that user can delete selected wallpapers in /Pictures/pizza-papers/ directory)
        shift;
        RemoveWallpaper
        exit;;
    --sample)               #Downloads 4 example image files for the user to be able to use)
        shift;
        echo -e ""
        if [[ $2 == *"remove"* ]]; then       #Lets the user delete the sample wallpapers in case they want to
          if test -f /home/$user/Pictures/pizza-papers/TRAINS.jpg; then
            echo -e "Deleted sample wallpapers\n"
            rm /home/$user/Pictures/pizza-papers/mountains.jpg
            rm /home/$user/Pictures/pizza-papers/astolfo.jpg
            rm /home/$user/Pictures/pizza-papers/sunglasses.jpeg
            rm /home/$user/Pictures/pizza-papers/TRAINS.jpg
            FallbackWallpaper
          else
            echo -e "\nYou do not have any of the sample wallpapers downloaded\n"
          fi
          exit;
        fi
        if [[ ! $2 == *"y"* ]]; then      #Ineffecient way of auto selecting yes, but whatever
          read -p "This will add 4 image files to your /Pictures/pizza-papers directory, do you still want to continue? [y/N]: " uinput
        fi
        if [[ $uinput == *"y"* || $2 == *"y"* ]]; then
        #Requests images from different website links (they are extracted in incoherant names)
          urls="https://i.etsystatic.com/43678560/r/il/e318c5/5095674952/il_1140xN.5095674952_4itq.jpg https://images.unsplash.com/photo-1473496169904-658ba7c44d8a?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D https://images4.alphacoders.com/906/thumb-1920-906149.png https://images.wallpaperscraft.com/image/single/train_railway_forest_169685_1920x1080.jpg"
          for links in $urls; do
            cd /home/pizza2d1/Pictures/pizza-papers/ && { curl -O $links ; cd -; }
          done
          #This part will make them readable (and in the case of sunglasses, usable), they are in order of links above
          mv /home/$user/Pictures/pizza-papers/il_1140xN.5095674952_4itq.jpg /home/$user/Pictures/pizza-papers/mountains.jpg
          mv /home/$user/Pictures/pizza-papers/photo-1473496169904-658ba7c44d8a /home/$user/Pictures/pizza-papers/sunglasses.jpeg #There was no image extension so I had to add it to make it work
          mv /home/$user/Pictures/pizza-papers/thumb-1920-906149.png /home/$user/Pictures/pizza-papers/astolfo.jpg
          if [ $? -ne 0 ]; then #Makes sure that the train wallpaper is still in the pizza-papers dir as a sign that the user still has all sample wallpapers
            echo -e "\nThird download failed; Make sure you are not on school wifi"
          fi
          mv /home/$user/Pictures/pizza-papers/train_railway_forest_169685_1920x1080.jpg /home/$user/Pictures/pizza-papers/TRAINS.jpg
          #Will add the sample wallpapers to /home/$user/Pictures/pizza-papers/settings.yaml so they can be selected in the selection interface
          if [[  ${WallpaperPathList[@]} != *"mountains.jpg"* ]]; then	
            yq -yi ".customWallpapers.\"mountainsjpg\" = \"/home/$user/Pictures/pizza-papers/mountains.jpg\"" /home/$user/Pictures/pizza-papers/settings.yaml  #If there is not already this sample image name put into the wallpaper list, it will add it
          fi
          if [[  ${WallpaperPathList[@]} != *"astolfo.jpg"* ]]; then	
            yq -yi ".customWallpapers.\"astolfojpg\" = \"/home/$user/Pictures/pizza-papers/astolfo.jpg\"" /home/$user/Pictures/pizza-papers/settings.yaml  #If there is not already this sample image name put into the wallpaper list, it will add it
          fi
          if [[  ${WallpaperPathList[@]} != *"sunglasses.jpeg"* ]]; then	
            yq -yi ".customWallpapers.\"sunglassesjpeg\" = \"/home/$user/Pictures/pizza-papers/sunglasses.jpeg\"" /home/$user/Pictures/pizza-papers/settings.yaml  #If there is not already this sample image name put into the wallpaper list, it will add it
          fi
          if [[  ${WallpaperPathList[@]} != *"TRAINS.jpg"* ]]; then	
            yq -yi ".customWallpapers.\"TRAINSjpg\" = \"/home/$user/Pictures/pizza-papers/TRAINS.jpg\"" /home/$user/Pictures/pizza-papers/settings.yaml  #If there is not already this sample image name put into the wallpaper list, it will add it
          fi
        else
          echo "Exiting"
        fi
        exit;;
    --settings)             #Will allow the user to change their settings for a more personal selection format)
        shift;
        echo "Default functions: (1: LessHelp, 2: MoreHelp, 3: AddWallpaper, 4: SelectWallpaper)"
        Settings
        exit;;
    --rotate)
        shift;
        RotateWallpaper
        exit;;
    --help)				          #Will activate when pizzapaper --help is used, the BETTER option for getting info)
        shift;	            #I don't know why shift is used tbh, but I'm afraid it will break if I remove it
        Help_Options
        exit;;
    --version)              #Will display current version)
        shift;
        echo $VERSION
        exit;;
    --)					            #No idea whatsoever, I don't want to remove it though)
        shift
        break
        ;;
    esac
    shift
done


#I am the one and only
if $IAMGOD; then
  echo -e "Dev commands:\n"
  echo "./path-partner --retard.............Resets all pizza-paper files and directories"
  echo "./path-partner --copy...............Can be used to add -a and remove -r pizzapaper-testing to PATH"
fi


#Will decide what function will be used when the user only does "./pizza-paper.sh" or "pizzapaper", the default is Less_Help
DefaultFunction=$(echo "Default" | GetSettings) #Will pipe (insert) a string containing "Default" into the GetSettings function, which will identify the string and return a certain value as a variable
case $DefaultFunction in                      #case will check to see if $DefaultFunction fits the same value of any of the options
    1)
        Less_Help
        exit;;
    2)
        Help_Options
        exit;;
    3)
        AddWallpaper
        exit;;
    4)
        SelectWallpaper
        exit;;
esac
