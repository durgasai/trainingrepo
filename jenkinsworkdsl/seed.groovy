pipelineJob('pipelinedsldemo'){
    definition {
        cps {
            script(readFileFromWorkspace('jenkinsworkdsl/pipeline_scripts/demojenkinsfile.groovy'))
            sandbox()
        }
    }
}
