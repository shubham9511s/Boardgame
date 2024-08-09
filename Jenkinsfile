pipeline {
    agent any
    
     tools {
        jdk 'jdk17'
        maven 'maven3'
    }
     environment{
        SCANNER_HOME=tool 'sonar'
    }
    

    stages {
        stage('Git_Checkout') {
            steps {
                echo 'Git_checkout'
                git branch: 'main', changelog: false, poll: false, url: 'https://github.com/shubham9511s/Boardgame.git'
            }
        }
        
        stage('Maven_All_Stages') {
            steps {
                echo 'Maven stage'
                sh 'mvn clean install'
            }
        }
        
         stage('Code_quality_check') {
            steps {
                echo 'Code_Quality_check'
                withSonarQubeEnv('sonar-server') {
                       sh"$SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Boardgame_java -Dsonar.projectKey=Boardgame_java -Dsonar.java.binaries=. "
                      
                   }
            }
        }
        
         stage('Quality_Gate') {
               steps {
                 waitForQualityGate abortPipeline: false 
                   /* script{
                        def qualityGate = waitForQualityGate()
                        if (qualityGate.status != 'OK') {
                            error "Pipeline aborted due to quality gate failure: ${qualityGate.status}"
                    }else{
                        
                        echo"Quality gate all condition are satisfy"
                    }
                }*/
              }
            }
         stage('OWASP dependency Check') {
            steps {
                    dependencyCheck additionalArguments: '--scan ./   ', odcInstallation: 'DC'
                    dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
                   
                
            }
        }
        
         stage('Deploy to Artifactory') {
            environment {
                TARGET_REPO = 'Boardgame'
            }
            
            steps {
                script {
                    try {
                        def server = Artifactory.newServer url: 'http://java-lb-1318408787.eu-north-1.elb.amazonaws.com:8082/artifactory', credentialsId: 'jfrog-id'
                        def uploadSpec = """{
                            "files": [
                                {
                                    "pattern": "target/*.jar",
                                    "target": "${TARGET_REPO}/"
                                }
                            ]
                        }"""
                        
                        server.upload(uploadSpec)
                    } catch (Exception e) {
                        error("Failed to deploy artifacts to Artifactory: ${e.message}")
                    }
                }
            }
        }
        
        stage('Build docker Imgage') {
            steps {
                    script{
                        withDockerRegistry(credentialsId: 'docker_token', toolName: 'Docker') {
                            
                            sh'docker build -t shubhamshinde2206/boardgame:latest .'
                            
                        }
                    }
            }
        }
        stage('Trivy_Image_Scan ') {
            steps {
                    sh'trivy image --format table -o trivy-image-report.html shubhamshinde2206/boardgame:latest'
                
            }
        }
        
         stage('Push docker Image') {
            steps {
                    script{
                        withDockerRegistry(credentialsId: 'docker_token', toolName: 'Docker') {
                            
                            sh'docker push shubhamshinde2206/boardgame:latest'
                            
                        }
                    }
            }
        }
        stage('Cleanup_docker_image') {
            steps {
                    script{
                        withDockerRegistry(credentialsId: 'docker_token', toolName: 'Docker') {
                            
                            sh'docker rmi $(docker images -q)'
                            
                        }
                    }
            }
        }
        
         stage('Deploy on Docker') {
            steps {
                    script{
                        withDockerRegistry(credentialsId: 'docker_token', toolName: 'Docker') {
                            
                            sh'docker run -d -p 8085:8085 shubhamshinde2206/boardgame:latest'
                            
                        }
                    }
            }
        }
        
            
        
        
        
        
    }
}
