pipeline {
    agent any
    
    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'test', 'prod'],
            description: 'Target deployment environment'
        )
        string(
            name: 'INSTANCE_COUNT',
            defaultValue: '1',
            description: 'Number of instances to deploy'
        )
    }

    environment {
        AWS_REGION = "us-east-1"
        TF_DIR    = "terraform"
    }

    stages {
        stage('Prepare AWS Key Pair') {
            steps {
                script {
                    sh """
                        aws ec2 create-key-pair \
                            --region ${AWS_REGION} \
                            --key-name ${params.ENVIRONMENT}-key \
                            --query 'KeyMaterial' \
                            --output text > ${params.ENVIRONMENT}-key.pem
                        chmod 400 ${params.ENVIRONMENT}-key.pem
                    """
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir(TF_DIR) {
                    sh """
                        terraform workspace select ${params.ENVIRONMENT} || terraform workspace new ${params.ENVIRONMENT}
                        terraform init
                        terraform apply \
                            -var="instance_count=${params.INSTANCE_COUNT}" \
                            -auto-approve
                    """
                }
            }
        }
    }

    post {
        always {
            script {
                sh """
                    rm -f ${params.ENVIRONMENT}-key.pem || true
                    aws ec2 delete-key-pair \
                        --region ${AWS_REGION} \
                        --key-name ${params.ENVIRONMENT}-key || true
                """
            }
        }
        
        cleanup {
            dir(TF_DIR) {
                sh "terraform destroy -auto-approve"
            }
            deleteDir()
        }
    }
}