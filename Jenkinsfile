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
        TF_VERSION = "1.11.0"  // Set your Terraform version
        AWS_CREDENTIALS_ID = "Jenkins3"  // Update with your Jenkins credentials ID if using AWS
    }

    stages {
        stage('Checkout Code') {
            steps {
                git url: 'https://github.com/tiqsclass6/jfrog-cli.git', branch: 'main'
            }
        }

        stage('Install Terraform') {
            steps {
                sh '''
                if ! terraform version | grep -q "$TF_VERSION"; then
                    echo "Installing Terraform..."
                    wget https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip
                    unzip terraform_${TF_VERSION}_linux_amd64.zip
                    sudo mv terraform /usr/local/bin/
                fi
                terraform --version
                '''
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([string(credentialsId: 'Jenkins3', variable: 'AWS_ACCESS_KEY_ID'),
                                string(credentialsId: 'Jenkins3', variable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh 'terraform init'
                }
            }
        }


        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -out=tfplan'
            }
        }

        stage('Terraform Apply') {
            steps {
                input message: "Do you want to apply the Terraform changes?", ok: "Yes"
                sh 'terraform apply -auto-approve tfplan'
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'tfplan', fingerprint: true
            cleanWs()
        }
    }
}
