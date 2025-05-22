pipeline {
    agent any

    parameters {
        choice(name: 'TARGET_ENV', choices: ['dev', 'test', 'prod', 'default'], description: 'Hedef ortamı seçin')
        string(name: 'INSTANCE_COUNT', defaultValue: '1', description: 'Dağıtılacak EC2 instance sayısı')
    }

    environment {
        AWS_REGION = "us-east-1"
        TF_VAR_instance_count = "${params.INSTANCE_COUNT.toInteger()}"
        TF_VAR_ssh_key_name = "${params.TARGET_ENV}"
    }

    stages {
        stage('AWS Key Pair Oluştur') {
            steps {
                script {
                    try {
                        sh """
                            aws ec2 create-key-pair \
                            --region ${AWS_REGION} \
                            --key-name ${params.TARGET_ENV} \
                            --query 'KeyMaterial' \
                            --output text > ${params.TARGET_ENV}.pem
                            
                            chmod 400 ${params.TARGET_ENV}.pem
                        """
                    } catch(exc) {
                        error("Key pair oluşturma hatası: ${exc.getMessage()}")
                    }
                }
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                dir('terraform') {
                    script {
                        sh """
                            terraform workspace select ${params.TARGET_ENV} || terraform workspace new ${params.TARGET_ENV}
                            terraform init -upgrade
                            terraform apply \
                                -var='aws_region=${AWS_REGION}' \
                                -auto-approve
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                // Temizlik işlemleri
                sh """
                    rm -fv ${params.TARGET_ENV}.pem
                    aws ec2 delete-key-pair --region ${AWS_REGION} --key-name ${params.TARGET_ENV} || true
                """
                
                // Terraform destroy
                dir('terraform') {
                    sh "terraform destroy -auto-approve"
                }
            }
        }
    }
}
