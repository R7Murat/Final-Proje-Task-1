pipeline {
    agent any

    parameters {
        choice(name: 'TARGET_ENV', choices: ['default', 'test', 'dev', 'prod'], description: 'Select the target environment')
        string(name: 'NODE_COUNT', defaultValue: '1', description: 'Number of instances to deploy, must be a positive number')
    }

    environment {
        CLOUD_REGION = "us-east-1"
        NODE_COUNT_INT = "${params.NODE_COUNT.toInteger()}"
        
        SERVER_SPEC = "${ 
            (params.TARGET_ENV == 'dev') ? 't2.micro' : 
            (params.TARGET_ENV == 'test') ? 't2.small' : 
            (params.TARGET_ENV == 'prod') ? 't3a.medium' : 
            't2.micro' 
        }"
        
        OPEN_PORTS = "${ 
            (params.TARGET_ENV == 'dev') ? '[80, 443, 22, 8080, 3306]' : 
            (params.TARGET_ENV == 'test') ? '[80, 443, 22, 8080, 8090]' : 
            (params.TARGET_ENV == 'prod') ? '[22, 80, 443, 8080, 3000]' : 
            '[80, 22]' 
        }"
    }

    stages {
        stage('Generate EC2 Key') {
            steps {
                script {
                    echo "Creating Key Pair for ${params.TARGET_ENV}"
                    sh(script: """
                        aws ec2 create-key-pair \
                            --region ${CLOUD_REGION} \
                            --key-name ${params.TARGET_ENV} \
                            --query 'KeyMaterial' \
                            --output text > ${params.TARGET_ENV}.pem
                        chmod 400 ${params.TARGET_ENV}.pem
                    """, returnStatus: true)
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    dir('terraform-configs') {
                        sh """
                            terraform workspace select ${params.TARGET_ENV} || terraform workspace new ${params.TARGET_ENV}
                            terraform init -no-color
                            terraform apply -no-color \
                                -var='instance_count=${NODE_COUNT_INT}' \
                                -var='instance_type=${SERVER_SPEC}' \
                                -var='allowed_ports=${OPEN_PORTS}' \
                                -var='ssh_key_name=${params.TARGET_ENV}' \
                                -auto-approve
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            echo "Post-Deployment Cleanup..."
            sh """
                rm -f ${params.TARGET_ENV}.pem || true
            """
        }
        
        cleanup {
            script {
                dir('terraform-configs') {
                    sh(script: "terraform destroy -auto-approve -no-color", returnStatus: true)
                }
                try {
                    sh "aws ec2 delete-key-pair --region ${CLOUD_REGION} --key-name ${params.TARGET_ENV}"
                } catch(exc) {
                    echo "Key pair deletion failed: ${exc}"
                }
            }
            echo "Destroy Cloud Infrastructure"
        }
    }
}