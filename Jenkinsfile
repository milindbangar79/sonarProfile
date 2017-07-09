/* Secrects Configuration */
bbcredId = 'GitHub'
nexuscredId = 'Nexus'
jiracredId = 'JIRA'
bbprotocol="https"
bbURL="github.com/milindbangar79/jenkins-docker-plugin.git"
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

   step([$class: 'JUnitResultArchiver', testResults: '**/target/surefire-reports/TEST-*.xml'])


  /*stage 'Build Docker image'

   #def image = docker.build('infinityworks/dropwizard-example:snapshot', '.')

   stage 'Acceptance Tests'
   image.withRun('-p 8181:8080') {c ->
        sh "${mvnHome}/bin/mvn verify"
   }*/

   /* Archive acceptance tests results */
   step([$class: 'JUnitResultArchiver', testResults: '**/target/failsafe-reports/TEST-*.xml'])

   stage 'Run SonarQube analysis'
   sh "${mvnHome}/bin/mvn clean org.jacoco:jacoco-maven-plugin:prepare-agent test"
   sh "${mvnHome}/bin/mvn package sonar:sonar -Dsonar.host.url=http://192.168.99.100:9000"

   input "Does http://192.168.99.100:9000/dashboard/index/io.dropwizard:dropwizard-example look good?"

   /*stage 'Push image'

   #docker.withRegistry("https://registry.infinityworks.com", "docker-registry") {
    #  //tag=sh "\$(git rev-parse --short HEAD)"
     # image.tag("latest", false)
      #image.push()
   #}*/

}

def checkoutscm() {      
   withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: "${bbcredId}", usernameVariable: 'bb_userid', passwordVariable: 'bb_password']]) {    
      dir ("${WORKSPACE}") {  	  	      
              git credentialsId: "${bbcredId}", poll: false, url: "${bbprotocol}://${env.bb_userid}:${env.bb_password}@${bbURL}", branch: "${relbranch_config}"                       
       }   
   }
}
