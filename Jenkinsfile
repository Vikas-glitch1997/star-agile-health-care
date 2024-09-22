pipeline {
    agent any

    tools {
        maven 'maven s/w'
    }

    stages {
        stage('Build') {
            steps {
                git 'https://github.com/Vikas-glitch1997/star-agile-health-care.git'
                sh 'mvn -Dmaven.test.failure.ignore=true clean package'
            }
        }

        stage('Generate Test Reports') {
            steps {
                publishHTML([
                    allowMissing: false,
                    alwaysLinkToLastBuild: false,
                    keepAll: false,
                    reportDir: 'target/surefire-reports',
                    reportFiles: 'index.html',
                    reportName: 'HTML Report',
                    reportTitles: '',
                    useWrapperFileDirectly: true
                ])
            }
        }

        stage('Create Docker Image') {
            steps {
                sh 'docker build -t vikaskumargt/medicurehealthcaredomain:1.0 .'
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerlogin', passwordVariable: 'dockerpassword', usernameVariable: 'dockerlogin')]) {
                    sh 'docker login -u ${dockerlogin} -p ${dockerpassword}'
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                sh 'docker push vikaskumargt/medicurehealthcaredomain:1.0'
            }
        }

        stage('Setting Up Kubernetes with Terraform') {
            steps {
                withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'AwsAccessKey', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    dir('terraform-files') {
                        sh 'sudo chmod 600 virginia.pem'
                        sh 'terraform init'
                        sh 'terraform validate'
                        sh 'terraform apply --auto-approve'
                    }
                }
            }
        }
        stage('Deploy the Application to Kubernetes') {
            steps {
                sh 'sudo chmod 600 ./terraform-files/virginia.pem'

                // Copy deployment and service files to the Kubernetes node
                sh 'scp -o StrictHostKeyChecking=no -i ./terraform-files/virginia.pem ./terraform-files/kube.yml ubuntu@54.81.95.16:/home/ubuntu/'
                sh 'scp -o StrictHostKeyChecking=no -i ./terraform-files/virginia.pem ./terraform-files/service.yml ubuntu@54.81.95.16:/home/ubuntu/'

                script {
                    try {
                        // Apply the Kubernetes configuration
                        sh 'ssh -o StrictHostKeyChecking=no -i ./terraform-files/virginia.pem ubuntu@54.81.95.16 "kubectl apply -f /home/ubuntu/kube.yml"'
                        sh 'ssh -o StrictHostKeyChecking=no -i ./terraform-files/virginia.pem ubuntu@54.81.95.16 "kubectl apply -f /home/ubuntu/service.yml"'
                    } catch (error) {
                        // Retry if there is an error
                        sh 'ssh -o StrictHostKeyChecking=no -i ./terraform-files/virginia.pem ubuntu@54.81.95.16 "kubectl apply -f /home/ubuntu/kube.yml"'
                        sh 'ssh -o StrictHostKeyChecking=no -i ./terraform-files/virginia.pem ubuntu@54.81.95.16 "kubectl apply -f /home/ubuntu/service.yml"'
                    }
                }
            }
        }
    }
}
