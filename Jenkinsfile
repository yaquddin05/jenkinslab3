pipeline {
    agent any
    stages {
        stage("Cleanup") {
            steps {
                sh "docker rm -f flask-app nginx-proxy 2>/dev/null || true"
                sh "docker network rm app-network 2>/dev/null || true"
            }
        }
        stage("Setup") {
            steps {
                sh "docker network create app-network"
            }
        }
        stage("Build") {
            steps {
                sh "docker build -t ammnelson/flask-app ."
            }
        }
        stage("Deploy") {
            steps {
                sh "docker run -d --name flask-app --network app-network ammnelson/flask-app"
                sh "docker run -d -p 80:80 --name nginx-proxy --network app-network -v \$(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro nginx"
            }
        }
        stage("Test") {
            steps {
                sh "sleep 5"
                sh "curl -f localhost"
            }
        }
    }
}
