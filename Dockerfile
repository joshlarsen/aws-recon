ARG RUBY_VERSION=2.6.6
FROM ruby:${RUBY_VERSION}-alpine

LABEL maintainer="Darkbit <info@darkbit.io>"

# Supply AWS Recon version at build time
ARG VERSION
ARG USER=recon
ARG GEM=aws_recon
ARG BUNDLER_VERSION=2.1.4

# Install new Bundler version
RUN rm /usr/local/lib/ruby/gems/*/specifications/default/bundler-*.gemspec && \
    gem uninstall bundler && \
    gem install bundler -v ${BUNDLER_VERSION}

# Install gem
RUN gem install ${GEM} -v ${VERSION}

# Create non-root user
RUN addgroup -S ${USER} && \
    adduser -S ${USER} \
    -G ${USER} \
    -s /bin/ash \
    -h /${USER}

# Copy binstub
COPY binstub/${GEM} /usr/local/bundle/bin/
RUN chmod +x /usr/local/bundle/bin/${GEM}

# Switch user
USER ${USER}
WORKDIR /${USER}

CMD ["ash"]
