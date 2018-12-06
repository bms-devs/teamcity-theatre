#Depending on the operating system of the host machines(s) that will build or run the containers, the image specified in the FROM statement may need to be changed.
#For more information, please see https://aka.ms/containercompat

FROM microsoft/dotnet:2.1-aspnetcore-runtime AS base
WORKDIR /app
EXPOSE 50084
EXPOSE 44342

FROM microsoft/dotnet:2.1-sdk AS sdk
# replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
RUN apt-get update
# nvm environment variables
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 6.15.1

# install nvm
# https://github.com/creationix/nvm#install-script
RUN curl --silent -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.2/install.sh | bash

# install node and npm
RUN source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

# add node and npm to path so the commands are available
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH
RUN npm install -g yarn

FROM sdk as build
WORKDIR /build
COPY . .
RUN dotnet restore "./src/TeamCityTheatre.sln"
WORKDIR /build/src/TeamCityTheatre.Web
RUN yarn install
RUN yarn run build:release
WORKDIR /build

FROM build AS publish
RUN dotnet publish "./src/TeamCityTheatre.Web/TeamCityTheatre.Web.csproj" --configuration Release --verbosity normal --output "/app"

FROM base AS final
WORKDIR /app
COPY --from=publish /app .

ENV TEAMCITY_HOST http://teamcity
ENV TEAMCITY_USER _
ENV TEAMCITY_PWD _

RUN mkdir /app/data
RUN chmod 777 /app/data
RUN echo "{}" > /app/data/configuration.json
RUN chmod 666 /app/data/configuration.json
VOLUME /app/data

COPY entrypoint.sh /app/

ENTRYPOINT ["/bin/bash", "entrypoint.sh"]