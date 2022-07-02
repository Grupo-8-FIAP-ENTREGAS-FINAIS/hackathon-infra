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
   #provisioner "local-exec" {
   # command = "mysql --host=${module.db.this_db_instance_address} --port=${var.dbport} --user=${var.dbusername} --password=${var.dbpassword} --database=${var.dbname} < ${file(${path.module}/init/db_structure.sql)}"
  #}
    provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install mysql -y",
      "export PASSWORD='openssl rand -base64 32'; echo \"Root password is : $PASSWORD\"",
      "echo \"ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$PASSWORD'\"  | sudo mysql -u root",
      "mysql -h 127.0.0.1 -P 3306 -u root -p$PASSWORD -e \"CREATE USER 'playuser'@'%' IDENTIFIED BY '123456';\"",
      "mysql -h 127.0.0.1 -P 3306 -u root -p$PASSWORD -e \"GRANT ALL PRIVILEGES ON *.* TO 'playuser'@'%' WITH GRANT OPTION;\"",
      "mysql -h 127.0.0.1 -P 3306 -u playuser -p123456 < playlist.sql"
    ]
  }

  root_password = "123456"
  deletion_protection  = "false"
}



resource "google_artifact_registry_repository" "hackthon" {
  provider = google-beta

  location = "us-central1"
  repository_id = "hackthon-repo"
  description = "Imagens Docker"
  format = "DOCKER"
}