resource "docker_image" "php-cli" {
  name = "php-application"
  build {
    context = ".."
  }
}

resource "docker_image" "openresty-image" {
  name = "openresty-reverse-proxy"
  build {
    context = "../nginx/"
  }
}


resource "docker_network" "intenal_net" {
  name = "app_net"
}


resource "docker_container" "openresty" {
  image = docker_image.openresty-image.image_id
  name  = "openresty-rev-proxy"
  ports {
    internal = 80
    external = 8090
  }
  networks_advanced {
    name = docker_network.intenal_net.id
  }

}
resource "docker_container" "app_container" {
  count = var.nbr_app_containers
  image = docker_image.php-cli.image_id
  name  = "app_container_${count.index + 1}"
  networks_advanced {
    name = docker_network.intenal_net.id
  }
}

