pipeline {
    agent {
        docker {
            image 'google/dart'
            //noinspection GroovyAssignabilityCheck
            args '-v /opt/pub-cache:/opt/pub-cache -e PUB_CACHE="/opt/pub-cache" -u root:root'
        }
    }

    options {
        timestamps()
    }

    stages {
        stage('Prepare Cache') {
            steps {
                copyArtifacts filter: '.packages', fingerprintArtifacts: true, projectName: '${JOB_NAME}', optional: true, selector: 'lastCompleted'
            }
        }
        stage('Prepare') {
            steps {
                parallel(
                        dart_dependencies:
                                {
                                    echo "Install Dart dependencies"
                                    sh 'pub get'
                                },
                        install_global_tools:
                                {
                                    sh 'pub global activate --source git https://github.com/eknoes/dart-pana-to-junit.git'
                                }
                )
            }
        }

        stage('Save Cache') {
            steps {
                archiveArtifacts artifacts: '.packages', fingerprint: true
            }
        }

        stage('Test') {
            steps {
                echo 'Check Health'
                sh 'pub run pana --no-warning --source path ${WORKSPACE} > out.json'
                sh 'pub global run pana_to_junit:main --input out.json --output pana-report.xml'
            }
        }

    }

    post {
        always {
            junit 'pana-report.xml'
        }
    }

}
