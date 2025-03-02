/*
pipeline{
    agent any
    tools {
        jfrog 'jfrog_cli'
    }
    stages {
        stage ('Testing') {
            steps {
                jf '-v' 
                jf 'c show'
                jf 'rt ping'
                sh 'touch test-file'
                jf 'rt u test-file jfrog_cli/'
                jf 'rt bp'
                jf 'rt dl jfrog_cli/test-file'
            }
        } 
    }
}
*/

pipeline {
    agent any

    environment {
        TF_WORKING_DIR = "${WORKSPACE}/terraform"  // Adjust if Terraform files are in a subdirectory
    }

    stages {
        stage('Checkout Repository') {
            steps {
                git url: 'https://github.com/tiqsclass6/jfrog-cli.git', branch: 'main'
            }
        }

        stage('Setup Terraform') {
            steps {
                sh 'terraform version'  // Confirm Terraform is installed
                sh 'terraform init'     // Initialize Terraform in the working directory
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
    }

    post {
        success {
            echo 'Terraform applied successfully!'
        }
        failure {
            echo 'Terraform failed. Check the logs.'
        }
    }
}