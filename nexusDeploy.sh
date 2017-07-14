#!/bin/bash

workspace=$1
nexus_url_rest=$2
nexus_user=$3
nexus_password=$4
buidNumber=$5
appname='HelloWorld'
appName='helloWorld-0.0.1-SNAPSHOT'
repository="CustomerServiceSnapshot"
version='0.0.1-SNAPSHOT'
Deployment_Repo='CustomerServiceSnapshot'
     
    echo -e "\nInfo: Uploading package for application : ${appname}"    
       groupid="com.example"
       version="${appName}-${buidNumber}"
       pkgtype="jar"
  if [[ -f ${workspace}/${appName}.${pkgtype} ]] ; then
          HTTP_CODE=$(curl -s \
            -F "r=${Deployment_Repo}" \
            -F "g=${groupid}" \
            -F "a=${appname}" \
            -F "v=${version}" \
            -F "p=${pkgtype}" \
            -F "file=@${workspace}/${appName}.${pkgtype}" \
            -u ${nexus_user}:${nexus_password} \
            -o /dev/null -w %{http_code} \
            ${nexus_url_rest})      
         
          if [[ ${HTTP_CODE} == "201" ]] ; then
             echo "Info: Package : ${appname}.${pkgtype} with Version : ${version} Uploaded successfully"
          else
             echo "Error: Failed to upload Package : ${appname}.${pkgtype} with Version : ${version}. ERROR CODE : ${HTTP_CODE}"
             exit 1
          fi
  fi
            
