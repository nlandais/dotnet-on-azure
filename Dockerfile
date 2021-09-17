# Set the base image as the .NET 5.0 SDK (this includes the runtime)
FROM mcr.microsoft.com/dotnet/sdk:5.0 as build-env

# Copy everything and publish the release (publish implicitly restores and builds)
COPY . ./src
ARG SRC=/src
WORKDIR ${SRC}
RUN dotnet build ./dotnet-on-azure.csproj --configuration Release
RUN dotnet publish ./dotnet-on-azure.csproj -c Release -o ./myapp

# Label the container
LABEL maintainer="Nicolas Landais <nlandais@flexion.us>"
LABEL repository="https://github.com/nlandais/dotnet-on-azure"

# Label as GitHub action
LABEL com.github.actions.name="Build "
# Limit to 160 characters
LABEL com.github.actions.description="This is a work in progress .NET Core Console App to ease cross posting from Hugo to alternate formats."
# See branding:
# https://docs.github.com/actions/creating-actions/metadata-syntax-for-github-actions#branding
LABEL com.github.actions.icon="activity"
LABEL com.github.actions.color="orange"

# Relayer the .NET SDK, anew with the build output
FROM mcr.microsoft.com/dotnet/runtime:5.0
ARG SRC=/src
COPY --from=build-env .${SRC}/myapp .
ENTRYPOINT [ "dotnet", "/dotnet-on-azure.dll" ]
