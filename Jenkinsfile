pipeline {
    agent any

    environment {
        JFROG_CLI_CREDENTIALS_ID = 'jfrog_cli'  // Jenkins credential ID for JFrog CLI
        JFROG_ADMIN_CREDENTIALS_ID = 'jfrog_cli1'  // JFrog admin credentials
        AWS_CREDENTIALS_ID = 'jfrog-jenkins'  // Jenkins AWS credential ID
    }

    stages {
        stage ('Clone Repository') {
            steps {
                git branch: 'main', credentialsId: 'github-cred', url: "https://github.com/tiqsclass6/jfrog-cli"
            }
        }

        stage ('Configure JFrog Artifactory') {
            steps {
                withCredentials([string(credentialsId: JFROG_ADMIN_CREDENTIALS_ID, variable: 'JFROG_CLI_TOKEN')]) {
                    sh """
                        jfrog config add artifactory-server --artifactory-url=https://trialu79uyt.jfrog.io/artifactory --user=admin --password=$JFROG_CLI_TOKEN --interactive=false
                    """
                }
            }
        }

        stage ('Scan GitHub Repository for Vulnerabilities') {
            steps {
                script {
                    sh """
                        curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh
                        trivy repo https://github.com/tiqsclass6/jfrog-cli --exit-code 1 || echo 'Vulnerabilities detected'
                    """
                }
            }
        }

        stage ('Terraform Init') {
            steps {
                script {
                    sh "terraform init"
                }
            }
        }

        stage ('Terraform Format Check') {
            steps {
                script {
                    sh "terraform fmt -check"
                }
            }
        }

        stage ('Terraform Validate') {
            steps {
                script {
                    sh "terraform validate"
                }
            }
        }

        stage ('Terraform Plan') {
            steps {
                withCredentials([aws(credentialsId: AWS_CREDENTIALS_ID, accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    script {
                        sh """
                            echo "Validating AWS Credentials..."
                            aws sts get-caller-identity || exit 1
                            terraform plan -out=tfplan
                        """
                    }
                }
            }
        }

        stage ('Apply Terraform') {
            steps {
                input message: "Approve Terraform Apply?", ok: "Deploy"
                withCredentials([
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: AWS_CREDENTIALS_ID,
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]) {
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
                withCredentials([
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: AWS_CREDENTIALS_ID,
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]) {
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
                withCredentials([string(credentialsId: JFROG_CLI_CREDENTIALS_ID, variable: 'JFROG_CLI_TOKEN')]) {
                    sh """
                        jfrog rt build-publish artifactory-server
                    """
                }
            }
        }
    } // End of 'stages' block

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