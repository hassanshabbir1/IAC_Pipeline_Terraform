# Require TF version to be same as or greater than 0.12.16
terraform {
  required_version = ">=1.0.8"
  
  # Check if the s3 bucket exists or not.
  # backend "s3" {
  #   region         = "us-east-1"
  #   encrypt        = true
  # } 

}



# Download any stable version in AWS provider of 2.36.0 or higher in 2.36 train


## Build an S3 bucket and DynamoDB for Terraform state and locking
module "bootstrap" {
  source                              = "./modules/bootstrap"
  s3_tfstate_bucket                   =  "${var.enviroment}-${var.projectname}-tfstate"   
  s3_logging_bucket_name              = "${var.enviroment}-${var.projectname}-logging-bucket"  ## Vairbale : Porject_name-varname-env 
  dynamo_db_table_name                = "${var.enviroment}-${var.projectname}-terraform-locking"
  codebuild_iam_role_name             = "${var.enviroment}-${var.projectname}-CodeBuildIamRole"  ## Variable : 
  codebuild_iam_role_policy_name      = "${var.enviroment}-${var.projectname}-CodeBuildIamRolePolicy" 
  terraform_codecommit_repo_arn       = module.codecommit.terraform_codecommit_repo_arn
  tf_codepipeline_artifact_bucket_arn = module.codepipeline.tf_codepipeline_artifact_bucket_arn
}

## Build a CodeCommit git repo
module "codecommit" {
  source          = "./modules/codecommit" 
  repository_name = "${var.projectname}-CodeCommitTerraform" ## var
}

## Build CodeBuild projects for Terraform Plan and Terraform Apply
module "codebuild" {
  source                                 = "./modules/codebuild"
  codebuild_project_terraform_plan_name  = "${var.projectname}-TerraformPlan-${var.enviroment}"
  codebuild_project_terraform_apply_name = "${var.projectname}-TerraformApply-${var.enviroment}"
  s3_logging_bucket_id                   = module.bootstrap.s3_logging_bucket_id
  codebuild_iam_role_arn                 = module.bootstrap.codebuild_iam_role_arn
  s3_logging_bucket                      = module.bootstrap.s3_logging_bucket
}

## Build a CodePipeline
module "codepipeline" {
  source                               = "./modules/codepipeline"
  tf_codepipeline_name                 = "${var.projectname}-TerraformCodePipeline-${var.enviroment}"  ## Var
  tf_codepipeline_artifact_bucket_name = "${var.projectname}-artifact-bucket-${var.enviroment}"
  tf_codepipeline_role_name            = "${var.projectname}-TerraformCodePipelineIamRole-${var.enviroment}"
  tf_codepipeline_role_policy_name     = "${var.projectname}-TerraformCodePipelineIamRolePolicy-${var.enviroment}"
  terraform_codecommit_repo_name       = module.codecommit.terraform_codecommit_repo_name
  codebuild_terraform_plan_name        = module.codebuild.codebuild_terraform_plan_name 
  codebuild_terraform_apply_name       = module.codebuild.codebuild_terraform_apply_name
}

provider "aws" {
  region  = "us-east-1"
  version = "~> 2.36.0"
  
}
