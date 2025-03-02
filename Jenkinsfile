pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'  // AWS Region
        JFROG_CLI_PATH = '/usr/local/bin/jfrog' // Adjust if JFrog CLI is installed elsewhere
        JFROG_URL = 'https://trialu79uyt.jfrog.io/'
        JFROG_FILE_NAME = 'jfrog_cli_030225'
    }

    stages {
        stage('Checkout Repository') {
            steps {
                git url: 'https://github.com/tiqsclass6/jfrog-cli.git', branch: 'main'
            }
        }

        stage('Setup AWS Credentials') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'Jenkins3',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    sh 'echo "AWS credentials configured"'
                }
            }
        }

        stage('Setup Terraform') {
            steps {
                sh 'terraform version'
                sh 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -out=tfplan'
            }
        }

        stage('Terraform Apply') {
            steps {
                input message: "Do you want to apply Terraform changes?", ok: "Apply"
                sh 'terraform apply -auto-approve tfplan'
            }
        }

        stage('JFrog Security Scan') {
            steps {
                script {
                    sh "${JFROG_CLI_PATH} rt scan --fail --spec tf_scan.json"
                    
                    // Upload scan results to JFrog Artifactory
                    sh """
                        echo "Uploading JFrog scan results to Artifactory..."
                        ${JFROG_CLI_PATH} rt upload tf_scan.json ${JFROG_URL}/artifactory/${JFROG_FILE_NAME}
                    """
                }
            }
        }

        stage('Terraform Destroy') {
            steps {
                input message: "Do you want to destroy the Terraform resources?", ok: "Destroy"
                sh 'terraform destroy -auto-approve'
            }
        }
    }

    post {
        success {
            echo 'Terraform applied and destroyed successfully, with JFrog scan completed and uploaded!'
        }
        failure {
            echo 'Pipeline failed. Check logs for details.'
        }
    }
}