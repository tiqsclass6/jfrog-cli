pipeline {
    agent any

    environment {
        JFROG_CLI_CREDENTIALS_ID = 'jfrog_cli'  // Jenkins credential ID for JFrog CLI
        JFROG_ADMIN_CREDENTIALS_ID = 'jfrog_cli1'  // JFrog admin credentials
        AWS_CREDENTIALS_ID = 'jfrog-jenkins'  // Jenkins AWS credential ID
    }

    stages {
        stage ('Clone') {
            steps {
                git branch: 'master', url: "https://github.com/tiqsclass6/jfrog-cli"
            }
        }

        stage ('Artifactory Configuration') {
            steps {
                withCredentials([string(credentialsId: JFROG_CLI_CREDENTIALS_ID, variable: 'JFROG_CLI_TOKEN')]) {
                    rtServer (
                        id: "artifactory-server-id", 
                        url: "https://trialu79uyt.jfrog.io/artifactory",
                        credentialsId: JFROG_ADMIN_CREDENTIALS_ID
                    )
                }
            }
        }

        stage ('Scan GitHub Repository') {
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

        stage ('Deploy') {
            steps {
                echo 'Deploying application...'
            }
        }

        stage ('Publish Build Info') {
            steps {
                withCredentials([string(credentialsId: JFROG_CLI_CREDENTIALS_ID, variable: 'JFROG_CLI_TOKEN')]) {
                    rtPublishBuildInfo (
                        serverId: "helmRepoResource"
                    )
                }
            }
        }
    } // End of 'stages' block

    post {
        failure {
            script {
                echo "Build failed! Sending email notification..."
                emailext (
                    subject: "Jenkins Pipeline Failure: Terraform Error",
                    body: """
                    Jenkins Pipeline Execution Failed 🚨

                    Job Name: ${env.JOB_NAME}
                    Build Number: ${env.BUILD_NUMBER}
                    Build URL: ${env.BUILD_URL}

                    One of the Terraform steps (Plan, Apply, or Destroy) encountered an error. 
                    Please check the Jenkins logs for further details.

                    Regards,
                    Jenkins CI/CD System
                    """,
                    to: "daquietstorm22@gmail.com"
                )
            }
        }
        always {
            echo 'Pipeline execution completed.'
        }
    }
}