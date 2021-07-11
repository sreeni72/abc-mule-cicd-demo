pipeline {
    agent {
        label "master"
    }
    tools {
         maven "M2_HOME"
    }
    environment {
	    BUILD_NUMBER = currentBuild.getNumber()
        NEXUS_VERSION = "nexus3"
        NEXUS_PROTOCOL = "http"
        NEXUS_URL = "localhost:8081"
        NEXUS_REPOSITORY = "maven-snapshots"
        NEXUS_CREDENTIAL_ID = "nexus.credentials"
        //DOCKER_REPOSITORY = "sreeni72/${pom.artifactId}-${pom.version}" 
        //DOCKER_CREDENTIALS = "dockerhub_credentials"
    }
    stages {
		stage("CheckOut") {
			steps {
				echo "Checkout the Code Repository..."
				git  branch: "master", credentialsId: "git.credentials", url: "https://github.com/sreeni72/abc-mule-cicd-demo.git"
			}
		}
        stage("Maven Clean Package") {
			steps {
				echo "Build the Application..." 
				bat "mvn clean package"
			}
		}
		stage("SonarQube Report") {
			steps {
				echo "Code Review With SonarQube Rules..." 
				withSonarQubeEnv('SonarQube-Server') {
                    bat "mvn sonar:sonar"
                }
			}
		}
        stage("Deploy To Nexus") {
            steps {
                // use profile nexus (-P nexus) to deploy to Nexus.
              // withCredentials([usernamePassword(credentialsId: 'nexus_credentials', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
              //      bat "mvn clean deploy -P nexus"
              // }
               //bat "mvn clean deploy -P nexus"
               	script {
					pom = readMavenPom file: "pom.xml";
					//filesByGlob = findFiles(glob: "target/*.${pom.packaging}");
					filesByGlob = findFiles(glob: "target/*.jar");
					echo "${filesByGlob[0].name} ${filesByGlob[0].path} ${filesByGlob[0].directory} ${filesByGlob[0].length} ${filesByGlob[0].lastModified}"
					artifactPath = filesByGlob[0].path;
					artifactExists = fileExists artifactPath;
					if(artifactExists) {
						echo "*** File: ${artifactPath}, group: ${pom.groupId}, packaging: ${pom.packaging}, version ${pom.version}";
						nexusArtifactUploader(
							nexusVersion: "${NEXUS_VERSION}",
							protocol: "${NEXUS_PROTOCOL}",
							nexusUrl: "${NEXUS_URL}",
							groupId: "${pom.groupId}",
							version: "${pom.version}",
							repository: "${NEXUS_REPOSITORY}",
							credentialsId: "${NEXUS_CREDENTIAL_ID}",
							artifacts: [
								[artifactId: "${pom.artifactId}",
								classifier: "",
								file: artifactPath,
								type: "jar"],
								[artifactId: "${pom.artifactId}",
								classifier: "",
								file: "pom.xml",
								type: "pom"]
							]
						);
					} else {
						error "*** File: ${artifactPath}, could not be found";
					}
				}
            }
        }
        stage("Build Docker Image"){
    		steps {
    			bat "docker build -t sreeni72/${pom.artifactId}:${BUILD_NUMBER} ."
    		}
        }
	   	stage("Push Docker Image"){
    		steps {
    		    withCredentials([string(credentialsId: "dockerhub_credentials", variable: "dockerhub_credentials")]) {
                    bat "docker login -u sreeni72 -p $dockerhub_credentials"
                }
                bat "docker push sreeni72/${pom.artifactId}:${BUILD_NUMBER}"
    		}
    	}
  }
  
}