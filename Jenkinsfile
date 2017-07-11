/* Secrects Configuration */
scmcredId = 'GitHub'
nexuscredId = 'Nexus'
jiracredId = 'JIRA'
sonarQubeURL='http://34.239.251.172:9000'
bbprotocol='https'
bbURL='github.com/milindbangar79/jenkins-docker-plugin.git'
devops_repo=""
relbranch_devops="master"
relbranch_config="master"

node ('master'){

   // Mark the code checkout 'stage'....
   stage 'Checkout'
   deleteDir()  
   checkoutscm()
   currentBuild.displayName = "#${env.BUILD_NUMBER}"

   stage 'Build application and Run Unit Test'

   def mvnHome = tool 'M3'
   sh "${mvnHome}/bin/mvn clean package"

  /*stage 'Build Docker image'

   #def image = docker.build('infinityworks/dropwizard-example:snapshot', '.')

   stage 'Acceptance Tests'
   image.withRun('-p 8181:8080') {c ->
        sh "${mvnHome}/bin/mvn verify"
   }*/

   stage 'Run SonarQube Analysis'
   /*sh "${mvnHome}/bin/mvn clean org.jacoco:jacoco-maven-plugin:prepare-agent test"*/
   sh "${mvnHome}/bin/mvn package sonar:sonar -Dsonar.host.url="${sonarQubeURL}""

   input "Does "${sonarQubeURL}"/dashboard/index/jenkins-docker-plugin look good?"

   /*stage 'Push image'

   #docker.withRegistry("<<pass as parameter>>", "docker-registry") {
    #  //tag=sh "\$(git rev-parse --short HEAD)"
     # image.tag("latest", false)
      #image.push()
   #}*/

}

def checkoutscm() {      
   withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: "${scmcredId}", usernameVariable: 'bb_userid', passwordVariable: 'bb_password']]) {    
      dir ("${WORKSPACE}") {  	  	      
              git credentialsId: "${scmcredId}", poll: false, url: "${bbprotocol}://${env.bb_userid}:${env.bb_password}@${bbURL}", branch: "${relbranch_config}"                       
       }   
   }
}
