pipeline {
  agent any
  parameters {
    choice(name: 'ENV', choices: ['dev','test','staging','prod'], description: 'Target Environment')
  }
  stages {
    stage('Setup Key Pair') {
      steps {
        script {
          if(!aws ec2 describe-key-pairs --key-name=proj-key){
            sh "aws ec2 create-key-pair --key-name proj-key --query 'KeyMaterial' --output text > proj-key.pem"
          }
        }
      }
    }
    stage('Terraform Apply') {
      steps {
        dir('environments') {
          sh "terraform workspace select ${params.ENV} || terraform workspace new ${params.ENV}"
          sh "terraform init"
          sh "terraform apply -auto-approve -var 'key_name=proj-key'"
        }
      }
    }
  }
}