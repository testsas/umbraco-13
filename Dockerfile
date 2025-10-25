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

# Copy all source files
COPY MyUmbracoSite/. ./MyUmbracoSite/

# Build and publish
WORKDIR /src/MyUmbracoSite
RUN dotnet publish -c Release -o /app/publish

# =========================
# Stage 2: Runtime
# =========================
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app

# Copy published app from build stage
COPY --from=build /app/publish .

# Create required Umbraco folders
RUN mkdir -p wwwroot/media wwwroot/umbraco-backoffice App_Data

# Expose HTTP port
EXPOSE 5000

# Set environment variables (optional, adjust as needed)
ENV DOTNET_USE_POLLING_FILE_WATCHER=1
ENV DOTNET_RUNNING_IN_CONTAINER=true
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false

# Start the application
ENTRYPOINT ["dotnet", "MyUmbracoSite.dll"]

