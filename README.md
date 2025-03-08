# README

アプリケーションのセットアップについて記述します

# Rails Dockerプロジェクト

## 前提条件
- Docker
- Docker Compose

## セットアップ手順

1. リポジトリをクローンする
```bash
git clone https://github.com/YoshikazuNakahara/rails-docker.git
cd rails-docker
```

2. コンテナをビルドして起動する
```bash
docker-compose build
docker-compose up
```

3. データベースをセットアップする
```bash
docker-compose run web rails db:create
docker-compose run web rails db:migrate
```

## アプリケーションへのアクセス
- ウェブアプリケーション: http://localhost:3000
- データベース: localhost:5432

## アプリケーションの停止
```bash
docker-compose down
```

## 開発
- すべてのRailsコマンドは`docker-compose run web`を介して実行する必要があります。
- 例: `docker-compose run web rails generate model User`
