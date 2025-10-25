# =========================
# Stage 1: Build
# =========================
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy solution and project files
COPY *.sln ./
COPY MyUmbracoSite/*.csproj ./MyUmbracoSite/

# Restore dependencies
RUN dotnet restore

# Copy all source files (avoid unnecessary files with a .dockerignore)
COPY MyUmbracoSite/. ./MyUmbracoSite/

# Build and publish the application
WORKDIR /src/MyUmbracoSite
RUN dotnet publish -c Release -o /app/publish

# =========================
# Stage 2: Runtime
# =========================
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime

# Set the working directory for runtime
WORKDIR /app

# Copy the published app from the build stage
COPY --from=build /app/publish ./

# Create required Umbraco folders for media and other assets
RUN mkdir -p wwwroot/media wwwroot/umbraco-backoffice App_Data

# Expose the port Umbraco listens on (typically 5000)
EXPOSE 5000

# Set environment variables (adjust to your needs)
ENV DOTNET_USE_POLLING_FILE_WATCHER=1 \
    DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false

# Start the application
ENTRYPOINT ["dotnet", "MyUmbracoSite.dll"]


