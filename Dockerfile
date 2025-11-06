FROM ruby:3.1.2-slim

# Instala dependências
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential libpq-dev nodejs yarn git curl && \
    rm -rf /var/lib/apt/lists/*

# Define o diretório da app
WORKDIR /app

# Copia apenas Gemfile para instalar gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copia o restante da aplicação
COPY . .

# Porta do Rails
EXPOSE 3000

# Entrypoint padrão
CMD ["bash"]
