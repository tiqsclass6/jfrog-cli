pipeline {
    agent any

    environment {
        JFROG_CLI_CREDENTIALS_ID = 'jfrog_cli'
        JFROG_ADMIN_CREDENTIALS_ID = 'jfrog_cli1'
        AWS_CREDENTIALS_ID = 'jfrog-jenkins'
        JFROG_CLI_PATH = "$HOME/.local/bin/jfrog"
        JFROG_BUILD_NAME = "05-03-25_Jenkins"  
        JFROG_REPO = "jfrog_cli"  
    }

    stages {

        stage('Checkout Code') {
            steps {
                script {
                    echo "Checking out source code from GitHub..."
                    checkout([$class: 'GitSCM',
                        branches: [[name: '*/main']],
                        userRemoteConfigs: [[url: 'https://github.com/tiqsclass6/jfrog-cli']]
                    ])
                    echo "Code checkout successful."
                    sh 'ls -la'
                }
            }
        }

        stage('Set AWS Credentials') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                                 credentialsId: AWS_CREDENTIALS_ID,
                                 accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                                 secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                    sh '''
                    echo "Configuring AWS CLI..."
                    aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
                    aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
                    aws configure set region us-east-1
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

        stage ('Terraform Init') {
            steps {
                sh "terraform init -upgrade"
            }
        }

        stage ('Terraform Format') {
            steps {
                sh "terraform fmt -recursive"
            }
        }

        stage ('Terraform Validate') {
            steps {
                sh "terraform validate"
            }
        }

        stage ('Terraform Plan') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                                 credentialsId: AWS_CREDENTIALS_ID,
                                 accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                                 secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                    sh """
                        echo "Validating AWS Credentials..."
                        aws sts get-caller-identity || exit 1

                        echo "Running Terraform Plan..."
                        terraform plan -out=tfplan
                    """
                }
            }
        }

        stage ('Apply Terraform') {
            steps {
                input message: "Approve Terraform Apply?", ok: "Deploy"
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                                 credentialsId: AWS_CREDENTIALS_ID,
                                 accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                                 secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                    sh '''
                    echo "Applying Terraform Changes..."
                    terraform apply -auto-approve tfplan
                    echo "Terraform Apply Completed."
                    '''
                }
            }
        }

        stage ('Destroy Terraform') {
            steps {
                input message: "Do you want to destroy the Terraform resources?", ok: "Destroy"
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                                 credentialsId: AWS_CREDENTIALS_ID,
                                 accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                                 secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                    sh '''
                    echo "Destroying Terraform Resources..."
                    terraform destroy -auto-approve
                    echo "Terraform Destroy Completed."
                    '''
                }
            }
        }

        stage ('Deploy Application') {
            steps {
                echo 'Deploying application...'
            }
        }

        stage ('Publish Build Info to JFrog') {
            steps {
                withCredentials([string(credentialsId: JFROG_CLI_CREDENTIALS_ID, 
                                        variable: 'JFROG_CLI_TOKEN')]) {
                    sh """
                        echo "Publishing build info to JFrog Artifactory..."
                        export PATH=$HOME/.local/bin:$PATH
                        $JFROG_CLI_PATH rt build-add-git $JFROG_BUILD_NAME
                        $JFROG_CLI_PATH rt build-publish --server-id=artifactory-server --repo=$JFROG_REPO $JFROG_BUILD_NAME
                        echo "Build info successfully published to JFrog Artifactory."
                    """
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