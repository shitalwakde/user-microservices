module.exports = {
    apps: [{
      name: "user-microservice",
      script: "src/server.js",
      env: {
        NODE_ENV: "development"
      },
      env_dev: {
        NODE_ENV: "dev"
      },
      env_uat: {
        NODE_ENV: "uat"
      },
      env_prod: {
        NODE_ENV: "prod"
      }
    }]
  }