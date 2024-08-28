#!/usr/bin/env groovy

def defaultBobImage = 'armdocker.rnd.ericsson.se/proj-adp-cicd-drop/bob.2.0:1.7.0-98'
def bob = new BobCommand()
    .bobImage(defaultBobImage)
    .envVars([
        HELM_REPO_TOKEN:'${HELM_REPO_TOKEN}',
        HOME:'/home/cbrsciadm',
        RELEASE:'${RELEASE}',
        USER:'${USER}',
		
    ])
    .needDockerSocket(true)
    .toString()
	

	def LOCKABLE_RESOURCE_LABEL = "kaas"

pipeline {
    agent {
		node {
			label "GE7_Docker"
		}
    }

    options {
        timestamps() 
        timeout(time: 35, unit: 'MINUTES')
    }

    environment {
        RELEASE = "false"
		
    }

    stages {
        stage('Clean') {
            steps {
                archiveArtifacts allowEmptyArchive: true, artifacts: 'ruleset2.0.yaml, precodereview.Jenkinsfile'
                sh "${bob} clean"
            }
        }

        stage('Init') {
            steps {
                sh "${bob} init-precodereview"
                script {
                    authorName = sh(returnStdout: true, script: 'git show -s --pretty=%an')
                    currentBuild.displayName = currentBuild.displayName + ' / ' + authorName
					stash includes: "*", name: "ruleset2.0.yaml", allowEmpty: true
                }
            }
        }

        stage('Lint') {
            steps {
                        sh "${bob} lint:helm"
                        sh "${bob} lint:helm-chart-check"
					}
            post {
                always {
                    archiveArtifacts allowEmptyArchive: true, artifacts: 'Design_Rules/design-rule-check-report.*'
                }
            }
        }

        stage('Image') {
            steps {
                sh "${bob} image"
                sh "${bob} image-dr-check "
            }
            post {
                always {
                    archiveArtifacts allowEmptyArchive: true, artifacts: 'Design_Rules/check-image/image-design-rule-check-report.*, Design_Rules/check-init-image/image-design-rule-check-report.*'
                }
            }
        }

        stage('Package') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'CBRSCIADM', variable: 'HELM_REPO_TOKEN')]) {
                        sh "${bob} package"
                    }
                }
            }
        }
}

    post {
        always {
			
			deleteDir()
        }
		
    }
}

// More about @Builder: http://mrhaki.blogspot.com/2014/05/groovy-goodness-use-builder-ast.html
import groovy.transform.builder.Builder
import groovy.transform.builder.SimpleStrategy

@Builder(builderStrategy = SimpleStrategy, prefix = '')
class BobCommand {

    def bobImage = 'bob.2.0:latest'
    def envVars = [:]

    def needDockerSocket = false

    String toString() {
        def env = envVars
                .collect({ entry -> "-e ${entry.key}=\"${entry.value}\"" })
                .join(' ')

        def cmd = """\
            |docker run
            |--init
            |--rm
            |--workdir \${PWD}
            |--user \$(id -u):\$(id -g)
            |-v \${PWD}:\${PWD}
            |-v /etc/group:/etc/group:ro
            |-v /etc/passwd:/etc/passwd:ro
            |-v \${HOME}:\${HOME}
            |${needDockerSocket ? '-v /var/run/docker.sock:/var/run/docker.sock' : ''}
            |${env}
            |\$(for group in \$(id -G); do printf ' --group-add %s' "\$group"; done)
            |--group-add \$(stat -c '%g' /var/run/docker.sock)
            |${bobImage}
            |"""
        return cmd
                .stripMargin()           // remove indentation
                .replace('\n', ' ')      // join lines
                .replaceAll(/[ ]+/, ' ') // replace multiple spaces by one
    }
}