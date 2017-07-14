#!/bin/bash

workspace=$1
constantsrepo=$2
nexus_url_rest=$3
nexus_user=$4
nexus_password=$5
buidNumber=$9
repository="CustomerServiceSnapshot"

do         
    echo -e "\nInfo: Uploading package for application : ${appname}"
    if [[ -f ${workspace}/${constantsrepo}/applications/${appname}/utility.properties ]] ; then
       . ${workspace}/${constantsrepo}/applications/${appname}/utility.properties
       groupid=$(echo ${group} | sed 's/"//g')
       version="${configBranch}-${buidNumber}"
       pkgtype="zip"
       if [[ -f ${workspace}/buildPkg/${appname}.${pkgtype} ]] ; then
          HTTP_CODE=$(curl -s \
            -F "r=${PFDeployment_Repo}" \
            -F "g=${groupid}" \
            -F "a=${appname}" \
            -F "v=${version}" \
            -F "p=${pkgtype}" \
            -F "file=@${workspace}/buildPkg/${appname}.${pkgtype}" \
            -u ${nexus_user}:${nexus_password} \
            -o /dev/null -w %{http_code} \
            ${nexus_url_rest})      
         
          if [[ ${HTTP_CODE} == "201" ]] ; then
             echo "Info: Package : ${appname}.${pkgtype} with Version : ${version} Uploaded successfully"
          else
             echo "Error: Failed to upload Package : ${appname}.${pkgtype} with Version : ${version}. ERROR CODE : ${HTTP_CODE}"
             exit 1
          fi      
done
