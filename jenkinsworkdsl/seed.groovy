pipelineJob('pipelinedsldemo'){
    definition {
        cps {
            script(readFileFromWorkspace('./pipeline_scripts/demojenkinsfile.groovy'))
            sandbox()
        }
    }
}