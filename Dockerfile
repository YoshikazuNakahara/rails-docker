# --- Builder Stage ---
    FROM ruby:3.2.2 AS builder

    # 必要なパッケージのインストール
    RUN apt-get update -qq && \
        apt-get install -y --no-install-recommends \
        build-essential \
        nodejs \
        yarn \
        libpq-dev
    
    # 作業ディレクトリの設定
    WORKDIR /app
    
    # Gemfile と Gemfile.lock をコピーして bundle install
    COPY Gemfile Gemfile.lock ./
    RUN bundle install --jobs=$(nproc) --retry=3
    
    # アプリケーションのコードをコピー
    COPY . .
    
    # アセットのプリコンパイル
    RUN RAILS_ENV=production SECRET_KEY_BASE=dummy bundle exec rails assets:precompile
    
    
    # --- Production Stage ---
    FROM ruby:3.2.2-slim AS production
    
    # 本番環境用のパッケージをインストール (実行に必要なものだけ)
    RUN apt-get update -qq && \
        apt-get install -y --no-install-recommends \
        libpq-dev \
        tzdata
    
    # 作業ディレクトリの設定
    WORKDIR /app
    
    # Builder ステージから成果物をコピー
    COPY --from=builder /usr/local/bundle /usr/local/bundle
    COPY --from=builder /app /app
    
    # 環境変数の設定
    ENV RAILS_ENV=production \
        RAILS_SERVE_STATIC_FILES=true \
        RAILS_LOG_TO_STDOUT=true
    
    # ポートの公開
    EXPOSE 3000
    
    # Rails サーバーを起動
    CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]