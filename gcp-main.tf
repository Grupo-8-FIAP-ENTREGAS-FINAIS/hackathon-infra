resource "google_sql_database" "database" {
  name     = "playlist"
  instance = google_sql_database_instance.playlist.name
}

# See versions at https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance#database_version
resource "google_sql_database_instance" "playlist" {
  name             = "playlist-instance"
  region           = "us-central1"
  database_version = "MYSQL_8_0"
  settings {
    tier = "db-f1-micro"
  }
   provisioner "local-exec" {
    command = "PGPASSWORD=123456 psql -f playlist.sql -p 3306 -U root playlist-instance"
  }
  root_password = "123456"
  deletion_protection  = "false"
}

resource "google_sql_user" "users" {
  name     = "playuser"
  instance = google_sql_database_instance.playlist.name
  password = "123456"
}

resource "google_artifact_registry_repository" "hackthon" {
  provider = google-beta

  location = "us-central1"
  repository_id = "hackthon-repo"
  description = "Imagens Docker"
  format = "DOCKER"
}