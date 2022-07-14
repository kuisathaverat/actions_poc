NAME = 'test'
DSL = '''pipeline {
  agent any
  stages {
    stage('test') {
      steps {
        echo "hello world"
      }
    }
  }
}'''

pipelineJob(NAME) {
  definition {
    cps {
      script(DSL.stripIndent())
    }
  }
}