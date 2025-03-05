pipeline {
    agent any

    environment {
        JFROG_CLI_CREDENTIALS_ID = 'jfrog_cli'     // JFrog CLI API Key or Token
        JFROG_ADMIN_CREDENTIALS_ID = 'jfrog_cli1'  // JFrog Admin (Username & Password)
        AWS_CREDENTIALS_ID = 'jfrog-jenkins'       // AWS Credentials
        JFROG_CLI_PATH = "$HOME/.local/bin/jfrog"  // User-accessible JFrog CLI path
    }

    stages {

        // Clone GitHub Repository
        stage ('Clone Repository') {
            steps {
                git branch: 'main', credentialsId: 'github-cred', url: "https://github.com/tiqsclass6/jfrog-cli"
            }
        }

        // Install JFrog CLI (User-Level)
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

        // Configure JFrog Artifactory
        stage ('Configure JFrog Artifactory') {
            steps {
                withCredentials([usernamePassword(credentialsId: JFROG_ADMIN_CREDENTIALS_ID, 
                                                 usernameVariable: 'JFROG_USER', 
                                                 passwordVariable: 'JFROG_PASSWORD')]) {
                    sh '''
                    echo $JFROG_PASSWORD | $HOME/.local/bin/jfrog config add artifactory-server \
                        --artifactory-url=https://trialu79uyt.jfrog.io/artifactory \
                        --user=$JFROG_USER --password-stdin --interactive=false
                    '''
                }
            }
        }

        // Security Scan on GitHub Repo
        stage ('Scan GitHub Repository') {
            steps {
                sh """
                    curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh
                    trivy repo https://github.com/tiqsclass6/jfrog-cli --exit-code 1 || echo 'Vulnerabilities detected'
                """
            }
        }

        // Terraform Initialization
        stage ('Terraform Init') {
            steps {
                sh "terraform init"
            }
        }

        // Terraform Format Check
        stage ('Terraform Format Check') {
            steps {
                sh "terraform fmt -check"
            }
        }

        // Terraform Validation
        stage ('Terraform Validate') {
            steps {
                sh "terraform validate"
            }
        }

        // Terraform Plan
        stage ('Terraform Plan') {
            steps {
                withCredentials([aws(credentialsId: AWS_CREDENTIALS_ID, 
                                     accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                                     secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh """
                        echo "Validating AWS Credentials..."
                        aws sts get-caller-identity || exit 1
                        terraform plan -out=tfplan
                    """
                }
            }
        }

        // Terraform Apply (User Confirmation Required)
        stage ('Apply Terraform') {
            steps {
                input message: "Approve Terraform Apply?", ok: "Deploy"
                withCredentials([aws(credentialsId: AWS_CREDENTIALS_ID, 
                                     accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                                     secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh '''
                    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                    terraform apply -auto-approve tfplan
                    '''
                }
            }
        }

        // Terraform Destroy (User Confirmation Required)
        stage ('Destroy Terraform') {
            steps {
                input message: "Do you want to destroy the Terraform resources?", ok: "Destroy"
                withCredentials([aws(credentialsId: AWS_CREDENTIALS_ID, 
                                     accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                                     secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh '''
                    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                    terraform destroy -auto-approve
                    '''
                }
            }
        }

        // Deploy Application
        stage ('Deploy Application') {
            steps {
                echo 'Deploying application...'
            }
        }

        // Publish Build Info to JFrog Artifactory
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