#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:5.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /src
COPY ["DockerSupport.csproj", "."]
RUN dotnet restore "./DockerSupport.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "DockerSupport.csproj" -c Release -o /app/build

FROM build AS publish
#RUN dotnet publish "DockerSupport.csproj" -c Release -o /app/publish
#RUN  dotnet publish -c Release --self-contained --runtime linux-x64 -o out
RUN dotnet publish "./src/DockerSupport.csproj" --self-contained --runtime linux-musl-x64 --configuration Release --output /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "DockerSupport.dll"]