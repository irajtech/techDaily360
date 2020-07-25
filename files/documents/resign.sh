#!/bin/sh
# Get the path of the folder
projectDirectory=$(pwd)
# Change to folder
cd "${projectDirectory}"
UPLOADDIR="${projectDirectory}"
# Get the entire path along with the file name
FILENAMEPATH="${UPLOADDIR}"/*.ipa

# Save the file name
IPAFILENAME=`basename -s .ipa ${FILENAMEPATH}`
echo "IPAFILENAME -- > '${IPAFILENAME}'"

# To check whether folder already exists
WEBDAVDIR=${IPAFILENAME// /_}

#Get the filename with extension
FILENAMEWITHEXTN=`basename ${FILENAMEPATH}`
echo "Filename -- > $FILENAMEWITHEXTN"

#Remove spaces from the files and rename it
FILENAMEWITHEXTN=${FILENAMEWITHEXTN// /_}
# Rename the old filename to new filename
mv ${FILENAMEPATH} $FILENAMEWITHEXTN
echo "Renamed Filename -- > $FILENAMEWITHEXTN"

# Check the directory with the same name, if exists then delete
if [ -d "${WEBDAVDIR}" ]; then
    rm -rf ${WEBDAVDIR}
fi

#### Create XML file ###
#########################
#1. Path to ipa
#2. App Name
#3. Bundle ID
CREATE_XML_FOR_MAAS360_APP_UPLOAD(){
if [[ -z "$1" || -z "$2"  || -z "$3" ]]; then
echo "Expected three arguments"
else
echo "AppID ='${1}'"
echo "App Path ='${2}'"
echo "AppName ='${3}'"

if [ -z "${2}" ]
then
    echo "${2} Empty"
else
    echo "NOT empty"
# Create xml
cat << EOF > "${1}.xml"
<appDetails>
<appId>${1}</appId>
<appType>1</appType>
<maas360Hosted>Yes</maas360Hosted>
<appSourceURL></appSourceURL>
<description>${3}</description>
<isAppApprovalApp>Yes</isAppApprovalApp>
<instantUpdate>No</instantUpdate>
</appDetails>
EOF
fi
fi
}


#### Update XML file ###
#########################
#1. Path to ipa
#2. App Name
#3. Bundle ID
UPDATE_XML_FOR_MAAS360_APP_UPLOAD(){
if [[ -z "$1" || -z "$2"  || -z "$3" ]]; then
fail "Expected three arguments"
else
echo ">>> Maas360 (.ipalink)='${1}'"
echo ">>> Maas360 (AppName)='${2}'"
echo ">>> Maas360(Bundle ID)='${3}'"

# Create upgrade.xml in targetDir
cat << EOF > "${APP_NAME}_upgrade.xml"
<appDetails>
<appId>${3}</appId>
<appType>1</appType>
<maas360Hosted>Yes</maas360Hosted>
<appSourceURL></appSourceURL>
<description>${APP_NAME}</description>
<isAppApprovalApp>No</isAppApprovalApp>
<instantUpdate>Yes</instantUpdate>
</appDetails>
EOF
fi
}

# Check if the file has been uploaded successfully then create a directory
if [ -f "$FILENAMEWITHEXTN" ]; then
    mkdir ${WEBDAVDIR}
    # move the file  to a new directory
    mv $FILENAMEWITHEXTN ${WEBDAVDIR}
    cd ${WEBDAVDIR}

    # Get the file and unzip 
    IPA=`basename ${FILENAMEWITHEXTN} | tr -d '\n'`
    unzip -q "${IPA}"

    # Find the plist in the app 
    PLIST=`find ./Payload -maxdepth 2 -type f -name Info.plist -print0`
    # Get the bundle id of the app
    BUNDLE_ID="`/usr/libexec/PlistBuddy -c \"Print CFBundleIdentifier\" \"${PLIST}\"`"
    # Get the display name of the app
    DISPLAY_NAME="`/usr/libexec/PlistBuddy -c \"Print CFBundleDisplayName\" \"${PLIST}\"`"
    echo ">>> BUNDLE_ID:'${BUNDLE_ID}'"
    echo ">>> DISPLAY_NAME:'${DISPLAY_NAME}'"
    # Delete the unzip folder name Payload
    rm -rf "Payload"
    
    # Use the fastlane sigh command to renew the certficate  
    fastlane sigh --force -a $BUNDLE_ID  -u xxxusernamexxx@xxx.com --verbose
    # Use the fastlane sigh resign command to sign the app 
    fastlane sigh resign --signing_identity "iPhone Distribution: XXXX" --verbose
    
    PROJECT_DIRECTORY=$(pwd)
    echo "PWD:  $PROJECT_DIRECTORY"

    # Get the informative message on the console
    figlet "XML Will be created"

    # Create an xml file for the maas360 app create
    CREATE_XML_FOR_MAAS360_APP_UPLOAD "$BUNDLE_ID" "$PROJECT_DIRECTORY" "$DISPLAY_NAME"

    #Create an xml file for the maas360 app update
    #UPDATE_XML_FOR_MAAS360_APP_UPLOAD "$BUNDLE_ID" "$PROJECT_DIRECTORY" "$DISPLAY_NAME"

    
    MAAS360AUTH=$(curl --request POST \
    --url https://services.fiberlink.com/auth-apis/auth/1.0/authenticate/XXXACCOUNTIDXXX \
    --header 'content-type: application/xml' \
    --data '<authRequest> \n<maaS360AdminAuth> \n<billingID>XXXACCOUNTIDXXX</billingID> \n<platformID>3</platformID> \n<appID>com.XXXXXX.api</appID> \n<appVersion>1.0</appVersion> \n<appAccessKey>XXXXXACCESSKEYXXX</appAccessKey> \n<userName>XXXUSERNAMEXXX</userName> \n<password>XXXPASSWORDXXX</password> \n</maaS360AdminAuth> \n</authRequest>')
    echo "$MAAS360AUTH"

    # Get the Token from response using sed
    TOKEN=$(sed -ne '/authToken/{s/.*<authToken>\(.*\)<\/authToken>.*/\1/p;q;}' <<< "$MAAS360AUTH")
    echo "token : $TOKEN"
    
    
    
    # Using Token to upload the new app using the xml file
    UPLOADJSON="curl -i -X POST https://services.fiberlink.com/application-apis/applications/1.0/addIOSEnterpriseApp/XXXACCOUNTIDXXX -H 'authorization: MaaS token=\"${TOKEN}\"' -H 'content-type: multipart/form-data' -F 'app_details=@${PROJECT_DIRECTORY}/${BUNDLE_ID}.xml' -F 'appSource=@$PROJECT_DIRECTORY/$FILENAMEWITHEXTN'"
    # Using Token upload the upgraded app using the xml file
    #UPLOADJSON="curl -i -X POST https://services.fiberlink.com/application-apis/applications/1.0/upgradeApp/XXXACCOUNTIDXXX -H 'authorization: MaaS token=\"${TOKEN}\"' -H 'content-type: multipart/form-data' -F 'app_details=@${PROJECT_DIRECTORY}/${BUNDLE_ID}_upgrade.xml' -F 'appSource=@$PROJECT_DIRECTORY/$FILENAMEWITHEXTN'"
    
    echo "$UPLOADJSON"
    eval $UPLOADJSON
    
    # rm *.mobileprovision

else 
    echo "$FILENAMEWITHEXTN does not exist."
fi





