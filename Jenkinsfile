pipeline {
    agent any

    environment {
        JFROG_CLI_CREDENTIALS_ID = 'jfrog_cli'
        JFROG_ADMIN_CREDENTIALS_ID = 'jfrog_cli1'
        AWS_CREDENTIALS_ID = 'jfrog-jenkins'
        JFROG_CLI_PATH = "$HOME/.local/bin/jfrog"
        JFROG_SERVER_ID = "artifactory-server" // Define the JFrog Server ID
    }

    stages {

        stage ('Clone Repository') {
            steps {
                git branch: 'main', credentialsId: 'github-cred', url: "https://github.com/tiqsclass6/jfrog-cli"
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
                    if $HOME/.local/bin/jfrog config show $JENKINS_SERVER_ID > /dev/null 2>&1; then
                        echo "Updating existing JFrog configuration..."
                        $HOME/.local/bin/jfrog config edit $JENKINS_SERVER_ID \
                            --artifactory-url=https://trialu79uyt.jfrog.io/artifactory \
                            --user=$JFROG_USER --password=$JFROG_PASSWORD
                    else
                        echo "Adding new JFrog configuration..."
                        $HOME/.local/bin/jfrog config add $JENKINS_SERVER_ID \
                            --artifactory-url=https://trialu79uyt.jfrog.io/artifactory \
                            --user=$JFROG_USER --password=$JFROG_PASSWORD --interactive=false
                    fi
                    '''
                }
            }
        }

        stage ('Terraform Init') {
            steps {
                sh "terraform init"
            }
        }

        stage ('Terraform Plan') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                                 credentialsId: AWS_CREDENTIALS_ID]]) {
                    sh """
                        echo "Validating AWS Credentials..."
                        aws configure list
                        aws configure set default.s3.signature_version s3v4
                        aws sts get-caller-identity || exit 1
                        terraform plan -out=tfplan
                    """
                }
            }
        }

        stage ('Apply Terraform') {
            steps {
                input message: "Approve Terraform Apply?", ok: "Deploy"
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                                 credentialsId: AWS_CREDENTIALS_ID]]) {
                    sh '''
                    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                    aws configure set default.s3.signature_version s3v4
                    terraform apply -auto-approve tfplan
                    '''
                }
            }
        }

        stage ('Destroy Terraform') {
            steps {
                input message: "Do you want to destroy the Terraform resources?", ok: "Destroy"
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                                 credentialsId: AWS_CREDENTIALS_ID]]) {
                    sh '''
                    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                    aws configure set default.s3.signature_version s3v4
                    terraform destroy -auto-approve
                    '''
                }
            }
        }

        stage ('Deploy Application') {
            steps {
                echo 'Deploying application...'
            }
        }

        stage ('Publish Build Info') {
            steps {
                withCredentials([string(credentialsId: JFROG_CLI_CREDENTIALS_ID, 
                                        variable: 'JFROG_CLI_TOKEN')]) {
                    sh "$HOME/.local/bin/jfrog rt build-publish artifactory-server"
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