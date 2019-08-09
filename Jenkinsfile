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
        stage('Prepare') {
            steps {
                parallel(
                        dart_dependencies:
                                {
                                    echo "Install Dart dependencies"
                                    sh 'pub get'
                                },
                        dart_global_tools:
                                {
                                    echo 'Install global tools'
                                    sh 'pub global activate junitreport'
                                    sh 'pub global activate pana'
                                }
                )
            }
        }

        stage('Test') {
            steps {
                echo 'Check Health'
                sh 'pub global run pana --no-warning --source path ${WORKSPACE} > out.json'
                sh 'pub run main.dart --input out.json --output pana-report.xml'
            }
        }

    }

    post {
        always {
            junit 'pana-report.xml'
        }
    }

}
