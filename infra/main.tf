module "create_url_lambda" {
  source      = "./modules/lambdas"
  name        = "create-url-lambda"
  handler     = "main.lambda_handler"
  source_path = "${path.root}/create-url.zip"
  env_vars = {
    REGION_AWS = "us-east-1"
    DB_NAME    = "url-shortener"
    APP_URL    = "https://ce09-avengers-urlshortener.sctp-sandbox.com/"
    MIN_CHAR   = "12"
    MAX_CHAR   = "16"
  }

  timeout = 10
}

module "retrieve_url_lambda" {
  source      = "./modules/lambdas"
  name        = "retrieve-url-lambda"
  handler     = "main.lambda_handler"
  source_path = "${path.root}/retrieve-url.zip"

  env_vars = {
    REGION_AWS = "us-east-1"
    DB_NAME    = "url-shortener"
  }

  timeout = 5
}

module "dynamodb" {
  source     = "./modules/dynamodb"
  table_name = "url-shortener"
  env        = "dev"
}

module "api_gateway" {
  source                 = "./modules/api_gateway"
  name                   = "url-shortener-api"
  lambda_post_invoke_arn = module.create_url_lambda.lambda_function_name
  lambda_get_invoke_arn  = module.retrieve_url_lambda.lambda_function_name
  custom_domain          = "ce09-avengers-urlshortener.sctp-sandbox.com"
  cert_arn               = var.acm_cert_arn
  zone_id                = var.route53_zone_id
}

module "waf" {
  source           = "./modules/waf"
  name             = "url-shortener-waf"
  env              = "dev"
  allowed_ips      = ["115.66.249.184/32"] # Replace with your IP
  api_gw_stage_arn = "arn:aws:apigateway:us-east-1::/restapis/${module.api_gateway.api_id}/stages/v1"
}

module "cloudwatch_create_url" {
  source      = "./modules/cloudwatch"
  name        = "create-url"
  lambda_name = module.create_url_lambda.lambda_function_name
}

module "cloudwatch_retrieve_url" {
  source      = "./modules/cloudwatch"
  name        = "retrieve-url"
  lambda_name = module.retrieve_url_lambda.lambda_function_name
}
