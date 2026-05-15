pipeline {
    agent any

    environment {
        TRIVY_VERSION = "0.62.1"
    }

    stages {
        stage("Install Trivy") {
            steps {
                sh """
                    if ! command -v trivy &> /dev/null; then
                        curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin v${TRIVY_VERSION}
                    fi
                    trivy --version
                """
            }
        }

        stage("Trivy FS Scan") {
            steps {
                sh "trivy fs --severity HIGH,CRITICAL --format table --output trivy-fs-report.txt ."
            }
            post {
                always {
                    archiveArtifacts artifacts: "trivy-fs-report.txt", allowEmptyArchive: true
                }
            }
        }

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
                sh "docker build -t yaqubu/flask-app ."
            }
        }

        stage("Trivy Image Scan") {
            steps {
                sh "trivy image --severity HIGH,CRITICAL --format table --output trivy-image-report.txt yaqubu/flask-app"
                sh "trivy image --severity HIGH,CRITICAL --format json --output trivy-image-report.json yaqubu/flask-app"
            }
            post {
                always {
                    archiveArtifacts artifacts: "trivy-image-report.*", allowEmptyArchive: true
                }
            }
        }

        stage("Security Gate") {
            steps {
                script {
                    def criticalCount = sh(
                        script: "trivy image --severity CRITICAL --format json --quiet yaqubu/flask-app | python3 -c \"import sys,json; data=json.load(sys.stdin); print(sum(len(r.get('Vulnerabilities',[])) for r in data.get('Results',[])))\"",
                        returnStdout: true
                    ).trim()
                    echo "Critical vulnerabilities found: ${criticalCount}"
                    input message: "Trivy found ${criticalCount} CRITICAL vulnerabilities. Review reports and approve to continue.", ok: "Proceed"
                }
            }
        }

        stage("Deploy") {
            steps {
                sh "docker run -d --name flask-app --network app-network yaqubu/flask-app"
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
