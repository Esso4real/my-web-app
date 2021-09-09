pipeline {
    agent any
	
	  tools
    {
       maven "maven"
    }
 /*stages {
      stage('checkout') {
           steps {
             
                git branch: 'master', url: 'https://github.com/Esso4real/CI-CD-using-Docker.git'
             
          }
        } */
	 stage('Execute Maven') {
           steps {
             
                sh 'mvn package'             
          }
        }
        

  stage('Docker Build and Tag') {
           steps {
              
                sh 'docker build -t samplewebapp:latest .' 
                sh 'docker tag samplewebapp esso4real/samplewebapp:latest'    
          }
        }
     
  stage('Publish image to Docker Hub') {
          
            steps {
		    script {
		       withCredentials([usernamePassword(credentialsId: 'hud-docker', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                         sh "echo $PASS | docker login -u $USER --password-stdin"
			       sh "docker push esso4real/samplewebapp:latest"
                }
		    }       
        }
    }
 stage('Provisioning Server') {
     steps {
         script {
             dir('terraform') {
                 sh "terraform init"
                 sh "terraform apply --auto-approve"
                 EC2_PUBLIC_IP = sh(
                     script: "terraform output ec2Public_ip"
                     returnStdout: true
                 ).trim()
             }
         }
     }
 }  
      
 stage('Deplying on remote server') {
             
            steps {
		    script {
		      def dockerCmd = "docker run -d -p 8003:8080 esso4real/samplewebapp "
			     sshagent(['pem-key']) {
				    sh "ssh -oStrictHostKeyChecking=no ec2-user@${EC2_PUBLIC_IP}  ${dockerCmd}"
             
                   }
		         }
               }
           }
       }
	}
    