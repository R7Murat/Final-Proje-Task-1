parameters {
    choice(name: 'TARGET_ENV', choices: ['default', 'test', 'dev', 'prod'], description: 'Target environment')
    string(name: 'INSTANCE_COUNT', defaultValue: '1', description: 'Number of instances to deploy')
}

environment {
    AWS_REGION = "us-east-1"
    INSTANCE_COUNT_INT = "${params.INSTANCE_COUNT.toInteger()}"
}

stage('Create Key Pair') {
    steps {
        sh """
            aws ec2 create-key-pair --region ${AWS_REGION} --key-name ${TARGET_ENV} --query KeyMaterial --output text > ${TARGET_ENV}
            chmod 400 ${TARGET_ENV}
        """
    }
}

stage('Deploy Infrastructure') {
    steps {
        sh """
            terraform apply -var='instance_count=${INSTANCE_COUNT_INT}' \
                            -var='ssh_key_name=${TARGET_ENV}' \
                            -auto-approve
        """
    }
}