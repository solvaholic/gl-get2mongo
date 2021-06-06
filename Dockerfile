FROM ruby:buster

COPY ./api_shim.rb /code/api_shim.rb

RUN useradd -c "" -m -p "" -s /bin/bash ruby
USER ruby
RUN gem install --user-install sinatra webrick mongo

EXPOSE 4567
ENTRYPOINT [ "/usr/local/bin/ruby" ]
CMD [ "/code/api_shim.rb" ]
