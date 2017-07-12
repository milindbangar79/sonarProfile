/* Secrets Configuration */
scmcredId = 'GitHub'
nexuscredId = 'Nexus'
jiracredId = 'JIRA'

/* Application Constants */
sonarQubeURL='http://34.239.251.172:9000'
bbprotocol='https'
bbURL='github.com/experiencedevops/customerservice.git'
devops_repo=""
relbranch_devops="master"
relbranch_config="master"
to_emailid='milind.bangar@tcs.com'

node ('master'){

   // Mark the code checkout 'stage'....
   stage 'Checkout'
   deleteDir() 
   try {
       checkoutscm()
       currentBuild.displayName="#${env.BUILD_NUMBER}"
       currentBuild.result='SUCCESS' 
   } catch (e) {
      currentBuild.result = "FAILED"
      sendMail( 'FAILED' )
      throw e
   }

   stage 'Build application and Run Unit Test'
   try {
      def mvnHome = tool 'M3'
      if (isUnix){
         sh "${mvnHome}/bin/mvn -Dmaven.test.failure.ignore clean package"
      } else {
         bat("${mvnHome}/bin/mvn -Dmaven.test.failure.ignore clean package")
      }
   } catch (e) {
      currentBuild.result = "FAILED"
      sendMail( 'FAILED' )
      throw e
   }
   
   stage('Results') {
      junit '*/target/surefire-reports/TEST-.xml'
      archive 'target/*.jar'
     }

  /*stage 'Build Docker image'

   #def image = docker.build('infinityworks/dropwizard-example:snapshot', '.')

   stage 'Acceptance Tests'
   image.withRun('-p 8181:8080') {c ->
        sh "${mvnHome}/bin/mvn verify"
   }*/

   
   /* In case SONAR Is required to be parameterized 
   stage('SonarQube analysis') { 
        withSonarQubeEnv('Sonar') { 
          sh 'mvn org.sonarsource.scanner.maven:sonar-maven-plugin:3.3.0.603:sonar ' + 
          '-f ./pom.xml ' +
          '-Dsonar.projectKey= com.company.selfservice:customerservice' +
          '-Dsonar.login=$SONAR_UN ' +
          '-Dsonar.password=$SONAR_PW ' +
          '-Dsonar.language=java ' +
          '-Dsonar.sources=. ' +
          '-Dsonar.tests=. ' +
          '-Dsonar.test.inclusions=**/*Test*/** ' +
          '-Dsonar.exclusions=**/*Test*/**'
        }
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
      currentBuild.result="FAILED"
      sendEmail( 'FAILED' )
      throw e
   }
   
   stage("SonarQube Quality Gate") { 
        timeout(time: 1, unit: 'HOURS') { 
           def qg = waitForQualityGate() 
           if (qg.status != 'OK') {
             error "Pipeline aborted due to quality gate failure: ${qg.status}"
           }
        }
    }

   /*input "Does '${sonarQubeURL}'/dashboard/index/jenkins-docker-plugin look good?"*/

   stage 'Deploy to Nexus'
   try {
      if(isUnix){
         sh "${mvnHome}/bin/mvn clean deploy"
      } else{
         bat("${mvnHome}/bin/mvn clean deploy")
      }
   } catch(e){
      currentBuild.Result="FAILED"
      sendEmail( 'FAILED' )
      throw e
   }
   
   /*stage 'Push image'

   #docker.withRegistry("<<pass as parameter>>", "docker-registry") {
    #  //tag=sh "\$(git rev-parse --short HEAD)"
     # image.tag("latest", false)
      #image.push()
   #}*/
   
   sendEmail ( 'SUCCESS' )
   
}

def checkoutscm() {      
   withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: "${scmcredId}", usernameVariable: 'bb_userid', passwordVariable: 'bb_password']]) {    
      dir ("${WORKSPACE}") {  	  	      
              git credentialsId: "${scmcredId}", poll: false, url: "${bbprotocol}://${env.bb_userid}:${env.bb_password}@${bbURL}", branch: "${relbranch_config}"                       
       }   
   }
}

def sendMail( Status ) {        
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
