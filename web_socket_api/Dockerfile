#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY ["web_socket_api/web_socket_api.csproj", "web_socket_api/"]
RUN dotnet restore "web_socket_api/web_socket_api.csproj"
COPY . .
WORKDIR "/src/web_socket_api"
RUN dotnet build "web_socket_api.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "web_socket_api.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "web_socket_api.dll"]