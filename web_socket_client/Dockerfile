#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/runtime:7.0 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY ["web_socket_client/web_socket_client.csproj", "web_socket_client/"]
RUN dotnet restore "web_socket_client/web_socket_client.csproj"
COPY . .
WORKDIR "/src/web_socket_client"
RUN dotnet build "web_socket_client.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "web_socket_client.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "web_socket_client.dll"]