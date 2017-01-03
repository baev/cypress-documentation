_ = require("lodash")

isCodeship = ->
  process.env.CI_NAME and process.env.CI_NAME is "codeship"

isGitlab = ->
  process.env.GITLAB_CI or process.env.CI_SERVER_NAME and process.env.CI_SERVER_NAME is "GitLab CI"

isWercker = ->
  process.env.WERCKER or process.env.WERCKER_MAIN_PIPELINE_STARTED

providers = {
  "appveyor":       "APPVEYOR"
  "bamboo":         "bamboo_planKey"
  "buildkite":      "BUILDKITE"
  "circle":         "CIRCLECI"
  "codeship":       isCodeship
  "drone":          "DRONE"
  "gitlab":         isGitlab
  "hudson":         "HUDSON_URL"
  "jenkins":        "JENKINS_URL"
  "semaphore":      "SEMAPHORE"
  "shippable":      "SHIPPABLE"
  "snap":           "SNAP_CI"
  "teamcity":       "TEAMCITY_VERSION"
  "teamfoundation": "TF_BUILD"
  "travis":          "TRAVIS"
  "wercker":         isWercker
}

nullDetails = -> {
  ciUrl: null
  buildNum: null
}

details = {
  "appveyor": -> {
    ciUrl: "https://ci.appveyor.com/project/#{process.env.APPVEYOR_ACCOUNT_NAME}/#{process.env.APPVEYOR_PROJECT_SLUG}/build/#{process.env.APPVEYOR_BUILD_VERSION}"
    buildNum: process.env.APPVEYOR_BUILD_NUMBER
  }
  "bamboo": nullDetails
  "buildkite": nullDetails
  "circle": -> {
    ciUrl: process.env.CIRCLE_BUILD_URL
    buildNum: process.env.CIRCLE_BUILD_NUM
  }
  "codeship": -> {
    ciUrl: process.env.CI_BUILD_URL
    buildNum: process.env.CI_BUILD_NUMBER
  }
  "drone": nullDetails
  "gitlab": -> {
    ciUrl: "#{process.env.CI_PROJECT_URL}/builds/#{process.env.CI_BUILD_ID}"
    buildNum: process.env.CI_BUILD_ID
  }
  "hudson": nullDetails
  "jenkins": -> {
    ciUrl: process.env.BUILD_URL
    buildNum: process.env.BUILD_NUMBER
  }
  "semaphore": nullDetails
  "shippable": nullDetails
  "snap": nullDetails
  "teamcity": nullDetails
  "teamfoundation": nullDetails
  "travis": -> {
    ciUrl: "https://travis-ci.org/#{process.env.TRAVIS_REPO_SLUG}/builds/#{process.env.TRAVIS_BUILD_ID}"
    buildNum: process.env.TRAVIS_BUILD_NUMBER
  }
  "wercker": nullDetails

  "unknown": nullDetails
}

getProviderName = ->
  ## return the key of the first provider
  ## which is truthy
  name = _.findKey providers, (value, key) ->
    switch
      when _.isString(value)
        process.env[value]
      when _.isFunction(value)
        value()

  name or "unknown"

module.exports = {
  name: ->
    getProviderName()

  details: ->
    details[getProviderName()]()
}
