group "default" {
  targets = ["gitget"]
}

target "gitget" {
  inherits = ["docker-metadata-action-gitget"]
  dockerfile = "Dockerfile"
  target = "gitget"
}

# Targets to allow injecting customizations from Github Actions.

target "docker-metadata-action-gitget" {}
