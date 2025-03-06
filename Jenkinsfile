pipeline {
    agent any

    environment {
        YAML_FILE = 'jenkins-jfrog.yaml'
    }

    stages {
        stage('Checkout Code') {
            steps {
                script {
                    echo "Checking out source code from GitHub..."
                    checkout scm
                    sh 'ls -la'
                }
            }
        }

        stage('Read YAML Configuration') {
            steps {
                script {
                    if (fileExists(YAML_FILE)) {
                        def pipelineConfig = readYaml file: YAML_FILE
                        echo "Pipeline Name: ${pipelineConfig.pipelines[0].name}"
                        echo "Step Name: ${pipelineConfig.pipelines[0].steps[0].name}"
                    } else {
                        error "YAML file not found: ${YAML_FILE}"
                    }
                }
            }
        }

        stage('Verify Jenkins Job Exists') {
            steps {
                script {
                    def config = readYaml file: YAML_FILE
                    def jenkinsJobName = config.pipelines[0].steps[0].configuration.jenkinsJobName

                    // If job is inside a folder, handle it properly
                    def folderName = '' // Set to your folder name if the job is inside one
                    if (folderName) {
                        jenkinsJobName = "${folderName}/${jenkinsJobName}"
                    }

                    echo "Checking if Jenkins job exists: ${jenkinsJobName}"

                    def jobExists = false
                    Jenkins.instance.getAllItems(Job.class).each { job ->
                        if (job.fullName.equals(jenkinsJobName)) {
                            jobExists = true
                        }
                    }

                    if (!jobExists) {
                        error "Jenkins job '${jenkinsJobName}' not found. Check job name and folder."
                    } else {
                        echo "Jenkins job '${jenkinsJobName}' exists and is ready to be triggered."
                    }
                }
            }
        }

        stage('Run Jenkins Step') {
            steps {
                script {
                    def config = readYaml file: YAML_FILE
                    def jenkinsJobName = config.pipelines[0].steps[0].configuration.jenkinsJobName
                    def timeout = config.pipelines[0].steps[0].configuration.timeoutSeconds

                    // If job is inside a folder, adjust the name
                    def folderName = '' // Update this if job is in a folder
                    if (folderName) {
                        jenkinsJobName = "${folderName}/${jenkinsJobName}"
                    }

                    echo "Triggering Jenkins job: ${jenkinsJobName} with timeout of ${timeout} seconds"

                    build job: jenkinsJobName, wait: true, parameters: [
                        string(name: 'timeoutSeconds', value: "${timeout}")
                    ]
                }
            }
        }
    }

    post {
        failure {
            script {
                echo "Pipeline execution failed! Check logs for details."
            }
        }
        always {
            echo 'Pipeline execution completed.'
        }
    }
}

/*
pipeline {
    agent any

    environment {
        JFROG_CLI_CREDENTIALS_ID = 'jfrog_cli'
        JFROG_ADMIN_CREDENTIALS_ID = 'jfrog_cli1'
        AWS_REGION = 'us-east-1'
        JFROG_CLI_PATH = '$HOME/.local/bin/jfrog'
        JFROG_BUILD_NAME = '05-03-25_Jenkins'  
        JFROG_REPO = 'jfrog_cli'
    }

    stages {

        stage('Checkout Code') {
            steps {
                script {
                    echo "Checking out source code from GitHub..."
                    checkout([$class: 'GitSCM',
                        branches: [[name: '/ *main']],
                        userRemoteConfigs: [[url: 'https://github.com/tiqsclass6/jfrog-cli']]
                    ])
                    echo "Code checkout successful."
                    sh 'ls -la'
                }
            }
        }

        stage('Set AWS Credentials') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'jfrog-jenkins',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    sh '''
                    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                    aws sts get-caller-identity
                    '''
                }
            }
        }

        stage ('Install JFrog CLI') {
            steps {
                sh """
                    curl -fL https://getcli.jfrog.io | sh
                    mkdir -p $HOME/.local/bin
                    mv jfrog $JFROG_CLI_PATH
                    chmod +x $JFROG_CLI_PATH
                    export PATH=$HOME/.local/bin:$PATH
                    $JFROG_CLI_PATH --version
                """
            }
        }

        stage ('Configure JFrog Artifactory') {
            steps {
                withCredentials([usernamePassword(credentialsId: JFROG_ADMIN_CREDENTIALS_ID, 
                                                 usernameVariable: 'JFROG_USER', 
                                                 passwordVariable: 'JFROG_PASSWORD')]) {
                    sh '''
                    chmod +x jfrog.sh
                    ./jfrog.sh
                    '''
                }
            }
        }

        stage ('Publish Build Info to JFrog') {
            steps {
                withCredentials([string(credentialsId: JFROG_CLI_CREDENTIALS_ID, 
                                        variable: 'JFROG_CLI_TOKEN')]) {
                    script {
                        def buildName = "jfrog_jenkins_" + new Date().format('ddMMyy')

                        sh """
                            echo "Publishing build info to JFrog Artifactory..."
                            export PATH=$HOME/.local/bin:$PATH

                            echo "Build Name: $buildName"
                            echo "Build Number: $BUILD_NUMBER"

                            # Add Git metadata to the build
                            $JFROG_CLI_PATH rt build-add-git "$buildName" "$BUILD_NUMBER"

                            # Publish the build info to JFrog CLI repo
                            $JFROG_CLI_PATH rt build-publish --server-id=artifactory-server $JFROG_REPO "$buildName" "$BUILD_NUMBER"

                            echo "Build info successfully published to JFrog Artifactory."

                            # Copy build info to new location
                            echo "Copying build info to Artifactory URL: https://trialu79uyt.jfrog.io/artifactory/jfrog_cli/"
                            $JFROG_CLI_PATH rt upload --server-id=artifactory-server \
                                "$HOME/.local/bin/*" "jfrog_cli/$buildName/"

                            echo "Build copy successfully uploaded to Artifactory."
                        """
                    }
                }
            }
        }

        stage ('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage ('Terraform Format') {
            steps {
                sh 'terraform fmt -recursive'
            }
        }

        stage ('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage ('Terraform Plan') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'jfrog-jenkins',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    sh '''
                    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                    terraform plan -out=tfplan
                    '''
                }
            }
        }

        stage ('Apply Terraform') {
            steps {
                input message: "Approve Terraform Apply?", ok: "Deploy"
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'jfrog-jenkins',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    sh '''
                    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                    terraform apply -auto-approve tfplan
                    '''
                }
            }
        }

        stage ('Deploy Application') {
            steps {
                echo 'Deploying application...'
            }
        }
        
        stage ('Destroy Terraform') {
            steps {
                input message: "Do you want to destroy the Terraform resources?", ok: "Destroy"
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'jfrog-jenkins',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    sh '''
                    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                    terraform destroy -auto-approve
                    '''
                }
            }
        }
    }

    post {
        failure {
            script {
                echo "Build failed! Check Jenkins logs for details."
            }
        }
        always {
            echo 'Pipeline execution completed.'
        }
    }
}
*/