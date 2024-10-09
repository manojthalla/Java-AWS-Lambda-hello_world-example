pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                // Checkout the code from your Git repository
                git branch: 'master', credentialsId: 'Github_Token', url: 'https://github.com/manojthalla/Java-AWS-Lambda-hello_world-example.git'
            }
        }

        stage('build code') {
            steps {
                // Install Terraform using a batch command, assuming Terraform is installed or install it using choco if needed
                bat '''
                  mvn clean package
                '''
            }
        }

        stage('Terraform Init') {
            steps {
                // Initialize Terraform using bat (batch commands)
                bat 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                // Run Terraform plan to see the changes
                bat 'terraform plan'
            }
        }

        stage('Terraform Apply') {
            steps {
                // Apply the Terraform configuration to deploy the Lambda function
                bat 'terraform apply -auto-approve'
            }
        }

        stage('Invoke Lambda') {
            steps {
                // Invoke the Lambda function as part of the pipeline
                echo 'Invoking Lambda function...'
                bat 'aws lambda invoke --function-name HelloWorldFunction --payload "{}" output.json'
                bat 'type output.json'
            }
        }
    }

    post {
        always {
            // Clean up
            echo 'Pipeline finished'
        }
        failure {
            echo 'Pipeline failed'
        }
    }
}
