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