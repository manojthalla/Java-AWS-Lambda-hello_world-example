pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-access-key')  // Store your AWS credentials in Jenkins
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')
        AWS_DEFAULT_REGION = 'us-west-1'  // Set your AWS region here
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout the code from your Git repository
                git branch: 'master', credentialsId:'Github_Token', url: 'https://github.com/manojthalla/Java-AWS-Lambda-hello_world-example.git'
            }
        }

        stage('Install Terraform') {
            steps {
                // Install Terraform using a shell command, assuming the machine has access to an installer
                sh '''
                if ! [ -x "$(command -v terraform)" ]; then
                  echo "Terraform not found, installing..."
                  curl -O https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_linux_amd64.zip
                  unzip terraform_1.5.0_linux_amd64.zip
                  sudo mv terraform /usr/local/bin/
                  terraform -v
                else
                  echo "Terraform is already installed"
                  terraform -v
                fi
                '''
            }
        }

        stage('Terraform Init') {
            steps {
                // Initialize Terraform
                sh 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                // Run Terraform plan to see the changes
                sh 'terraform plan'
            }
        }

        stage('Terraform Apply') {
            steps {
                // Apply the Terraform configuration to deploy the Lambda function
                sh 'terraform apply -auto-approve'
            }
        }

        stage('Invoke Lambda') {
            steps {
                // Invoke the Lambda function as part of the pipeline
                echo 'Invoking Lambda function...'
                sh 'aws lambda invoke --function-name HelloWorldFunction --payload "{}" output.json'
                sh 'cat output.json'
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
