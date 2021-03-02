# pgdump2Minio

![Docker Pulls](https://img.shields.io/docker/pulls/vpontus/pgdump2minio)

This image will help you to perform postgres backup, upload to minio storage and validate restore

## Configuration

Environment variables

Variable | Default value | Description
---|---|---
PGHOST|localhost| postgresql host
PGPORT|5432| postgresql port
PGDATABASE|test|database name to backup
PGUSER|test| postgres connection user
PGPASSWORD|test| postgres connection pasword
PGDUMP_OPTIONS| -Fc -b| pg_dump options
PGRESTORE_OPTIONS|| pg_restore options
VERIFY_BACKUP|skip| database verification flag. Use **verify** to enable DB verification.
VERIFY_TABLE_NAME|| if provided it will be checked for the existence
VERIFY_SCHEMA_NAME|public| The schema name for existence verification. Only used in conjunction with 'VERIFY_TABLE_NAME'
MINIO_URL|http://localhost:9000| Minio server url
MINIO_ACCESS_KEY|| Minio access key
MINIO_SECRET_KEY|| Minio secret key
S3_BUCKET||backup bucket name. **Warning** make sure bucket exist and provided user has object put permission


## Usage in command line
```shell

docker run --rm \
      --net=host \
      -e PGHOST=localhost \
      -e PGDATABASE=test_db \
      -e PGUSER=test \
      -e PGPASSWORD=test \
      -e VERIFY_BACKUP=verify \
      -e MINIO_URL=http://localhost:9000 \
      -e MINIO_ACCESS_KEY=minioadmin \
      -e MINIO_SECRET_KEY=minioadmin \
      -e S3_BUCKET=pgdump \
      vpontus/pgdump2minio
```

## Usage in docker-compose

```yaml
version: '3.7'

services:
  
  db:
    ...
  
  backup:
    image: vpontus/pgdump2minio:latest
    environment:
      PGHOST: db_host
      PGDATABASE: test_db
      PGUSER: test
      PGPASSWORD: test
      VERIFY_BACKUP: verify
      MINIO_URL: http://minio_host:9000
      MINIO_ACCESS_KEY: minioadmin
      MINIO_SECRET_KEY: minioadmin
      S3_BUCKET: pgdump
```

## License: MIT

MIT License

Copyright (c) 2021 Volodymyr Pontus

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
