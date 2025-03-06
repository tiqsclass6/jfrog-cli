pipeline {
    agent any

    environment {
        JFROG_CLI_CREDENTIALS_ID = 'jfrog_cli'
        JFROG_ADMIN_CREDENTIALS_ID = 'jfrog_cli1'
        AWS_CREDENTIALS_ID = 'jfrog-jenkins'
        JFROG_CLI_PATH = "$HOME/.local/bin/jfrog"
        JFROG_BUILD_NAME = "05-03-25_Jenkins"  // Set the Build Name
        JFROG_REPO = "jfrog_cli"  // JFrog Repository
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
                    chmod +x jfrog.sh
                    ./jfrog.sh
                    '''
                }
            }
        }

        stage ('Terraform Init') {
            steps {
                sh "terraform init"
            }
        }

        stage ('Terraform Format') {
            steps {
                sh "terraform fmt -check"
            }
        }

        stage ('Terraform Validate') {
            steps {
                sh "terraform validate"
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
                        $HOME/.local/bin/jfrog rt build-add-git $JFROG_BUILD_NAME
                        $HOME/.local/bin/jfrog rt build-publish --server-id=artifactory-server --repo=$JFROG_REPO $JFROG_BUILD_NAME
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