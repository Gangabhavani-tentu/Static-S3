pipeline {
    agent any
    parameters {
        string(name: 'action', defaultValue: 'plan', description: 'Specify Terraform action (plan or apply)')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('terraform init') {
            steps {
                sh 'terraform init -reconfigure'
            }
        }

        stage('terraform plan') {
            steps {
                sh 'terraform plan -out=tfplan'  // Saves the plan as "tfplan"
            }
        }

        stage('terraform Action') {
            steps {
                echo "Terraform action is --> ${params.action}"
                script {
                    if (params.action == 'apply') {
                        sh 'terraform apply -auto-approve tfplan'  // Uses saved plan for apply
                    } else if (params.action == 'plan') {
                        sh 'terraform plan'
                    } else {
                        error "Invalid action: ${params.action}. Only 'plan' or 'apply' are allowed."
                    }
                }
            }
        }
    }
}