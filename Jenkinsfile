/* Secrets Configuration */
scmcredId = 'GitHub'
nexuscredId = 'nexus'
jiracredId = 'JIRA'

/* Application Constants */
sonarQubeURL='http://34.239.251.172:9000'
bbprotocol='https'
bbURL='github.com'
appRepo='github.com/milindbangar79/jenkins-docker-plugin.git'
automationRepo='github.com/milindbangar79/sonarProfile.git'
automationRepoDirectory='automation'
nexusBase = 'http://34.200.232.169:8081/nexus/content/repositories'
nexus_rest_3='http://34.200.232.169:8081/service/siesta/rest/v1/script'
nexus_rest='http://34.200.232.169:8081/nexus/service/local/artifact/maven/content'
devops_repo=""
relbranch_devops="master"
relbranch_config="master"
to_emailid='milind.bangar@tcs.com'

node ('master'){

   // Mark the code checkout 'stage'....
   def mvnHome = tool 'M3'
   
   stage 'Checkout'
   deleteDir() 
   try {
       checkoutscm()
       currentBuild.displayName="#${env.BUILD_NUMBER}"
       currentBuild.result='SUCCESS' 
   } catch (e) {
      currentBuild.result='FAILED'
      sendEmail( 'FAILED' )
      throw e
   }

   stage 'Build application and Run Unit Test'
   try {
      
      if (isUnix()){
         sh "${mvnHome}/bin/mvn -Dmaven.test.failure.ignore clean install package"
      } else {
         bat("${mvnHome}/bin/mvn -Dmaven.test.failure.ignore clean package")
      }
   } catch (e) {
      currentBuild.result='FAILED'
      sendEmail( 'FAILED' )
      throw e
   }

  /*stage 'Build Docker image'

   #def image = docker.build('infinityworks/dropwizard-example:snapshot', '.')

   stage 'Acceptance Tests'
   image.withRun('-p 8181:8080') {c ->
        sh "${mvnHome}/bin/mvn verify"
   }*/
   
   stage 'Run SonarQube Analysis'
   try {
     if (isUnix()) { 
         /*sh "${mvnHome}/bin/mvn clean org.jacoco:jacoco-maven-plugin:prepare-agent test"*/
         sh "${mvnHome}/bin/mvn package sonar:sonar -Dsonar.host.url='${sonarQubeURL}'"
     }else{
         /*bat("${mvnHome}/bin/mvn clean org.jacoco:jacoco-maven-plugin:prepare-agent test")*/
         bat("${mvnHome}/bin/mvn package sonar:sonar -Dsonar.host.url='${sonarQubeURL}'")
     }
   } catch (e){
      currentBuild.result='FAILED'
      sendEmail( 'FAILED' )
      throw e
   }
   
   /*stage("SonarQube Quality Gate") { 
        timeout(time: 1, unit: 'HOURS') { 
           def qg = waitForQualityGate() 
           if (qg.status != 'OK') {
             error "Pipeline aborted due to quality gate failure: ${qg.status}"
           }
        }
    }*/

   /*input "Does '${sonarQubeURL}'/dashboard/index/jenkins-docker-plugin look good?"*/

   stage 'Deploy to Nexus'
   try {
         /*uploadArtifacts()*/
      withMaven(
        // Maven installation declared in the Jenkins "Global Tool Configuration"
        maven: mvnHome,
        // Maven settings.xml file defined with the Jenkins Config File Provider Plugin
        // Maven settings and global settings can also be defined in Jenkins Global Tools Configuration
         mavenSettingsConfig: 'my-maven-settings'{
            sh "${mvnHome}/bin/mvn -Dmaven.test.failure.ignore deploy"
      }
   } catch(e){
      currentBuild.result='FAILED'
      sendEmail( 'FAILED' )
      throw e
   }
   
   /*stage 'Push image'

   #docker.withRegistry("<<pass as parameter>>", "docker-registry") {
    #  //tag=sh "\$(git rev-parse --short HEAD)"
     # image.tag("latest", false)
      #image.push()
   #}*/
   
   sendEmail( 'SUCCESS' )
   
}

def checkoutscm() {      
   withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: "${scmcredId}", usernameVariable: 'bb_userid', passwordVariable: 'bb_password']]) {    
      dir ("${WORKSPACE}") {  	  	      
              git credentialsId: "${scmcredId}", poll: false, url: "${bbprotocol}://${env.bb_userid}:${env.bb_password}@${appRepo}", branch: "${relbranch_config}"                       
       }   
   }
   
  withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: "${scmcredId}", usernameVariable: 'bb_userid', passwordVariable: 'bb_password']]) {    
     dir ("${WORKSPACE}/${automationRepoDirectory}") {  	  	      
              git credentialsId: "${scmcredId}", poll: false, url: "${bbprotocol}://${env.bb_userid}:${env.bb_password}@${automationRepo}", branch: "${relbranch_config}"                       
       }   
   }
}

def sendEmail( Status ) {        
    if ( "${Status}" == 'SUCCESS' || "${Status}" == 'UNSTABLE' )
    {        
        /*emailbody = readFile 'builddesc.txt'*/  
        emailbody   = 'Package Build Successful'
        currentBuild.result = "${Status}"
    }  
    else if ( "${Status}" == 'FAILED' )
    {
        emailbody = 'Deployment Failed !!! Please check attached logs.'        
        currentBuild.result = 'FAILED'
    }
    emailext attachLog: true, body: "${emailbody}", compressLog: true, subject: "Build #${env.BUILD_NUMBER} - Deployment ${Status}.", to: "${to_emailid}"
}

def uploadArtifacts() { 
    withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: "${nexuscredId}", usernameVariable: 'nexus_userid', passwordVariable: 'nexus_password']]) {
       sh "chmod ugo+rwx ${WORKSPACE}/${automationRepoDirectory}/nexusDeploy.sh"
       sh "${WORKSPACE}/${automationRepoDirectory}/nexusDeploy.sh ${WORKSPACE} ${nexus_rest} ${nexus_userid} ${nexus_password} ${BUILD_NUMBER}"
    }
    
}
