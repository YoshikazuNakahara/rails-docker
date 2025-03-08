# --- User Creation Stage ---
FROM ruby:3.2.2-slim-bullseye AS user-stage

ENV TZ=Asia/Tokyo

ARG USER_NAME=rails
ARG GROUP_NAME=rails
ARG USER_ID=1000
ARG GROUP_ID=1000

RUN groupadd -r ${GROUP_NAME} --gid=${GROUP_ID} && \
    useradd -r -g ${GROUP_NAME} --uid=${USER_ID} -m -s /bin/bash ${USER_NAME}

# 環境変数を設定
ENV USER=${USER_NAME}
ENV HOME=/home/${USER_NAME}

# --- Builder Stage ---
FROM user-stage AS builder
ARG USER_ID
ARG GROUP_ID

# 必要なパッケージのインストール
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    build-essential \
    nodejs \
    yarn \
    libpq-dev \
    tzdata && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 作業ディレクトリの設定
WORKDIR /app

# Gemfile と Gemfile.lock をコピーして bundle install
# 依存関係のインストールをキャッシュするために、最初にGemfileとGemfile.lockをコピー
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs=$(nproc) --retry=3

# アプリケーションコードのコピーと所有権の設定
COPY --chown=${USER_ID}:${GROUP_ID} . .

# アセットのプリコンパイル
RUN RAILS_ENV=production SECRET_KEY_BASE=dummy bundle exec rails assets:precompile

# --- Production Stage ---
FROM user-stage AS production
ARG USER_ID
ARG GROUP_ID

# 本番環境用のパッケージをインストール (実行に必要なものだけ)
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    libpq-dev \
    tzdata && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 作業ディレクトリの設定
WORKDIR /app

# Builder ステージから成果物をコピー
COPY --chown=${USER_ID}:${GROUP_ID} --from=builder /usr/local/bundle /usr/local/bundle
COPY --chown=${USER_ID}:${GROUP_ID} --from=builder /app /app

# 非rootユーザーに切り替え
USER ${USER_ID}
    
# 環境変数の設定
ENV RAILS_ENV=production \
    RAILS_SERVE_STATIC_FILES=true \
    RAILS_LOG_TO_STDOUT=true

# ポートの公開
EXPOSE 3000

# Rails サーバーを起動
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]