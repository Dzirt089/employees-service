FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["./Directory.build.props", "./"]
COPY ["./Directory.build.targets", "./"]
COPY ["./src/CSharpCourse.EmployeesService.Domain/CSharpCourse.EmployeesService.Domain.csproj", "./CSharpCourse.EmployeesService.Domain/"]
COPY ["./src/CSharpCourse.EmployeesService.ApplicationServices/CSharpCourse.EmployeesService.ApplicationServices.csproj", "./CSharpCourse.EmployeesService.ApplicationServices/"]
COPY ["./src/CSharpCourse.EmployeesService.DataAccess.EntityFramework/CSharpCourse.EmployeesService.DataAccess.EntityFramework.csproj", "./CSharpCourse.EmployeesService.DataAccess.EntityFramework/"]
COPY ["./src/CSharpCourse.EmployeesService.DataAccess.Dapper/CSharpCourse.EmployeesService.DataAccess.Dapper.csproj", "./CSharpCourse.EmployeesService.DataAccess.Dapper/"]
COPY ["./src/CSharpCourse.EmployeesService.PresentationModels/CSharpCourse.EmployeesService.PresentationModels.csproj", "./CSharpCourse.EmployeesService.PresentationModels/"]
COPY ["./src/CSharpCourse.EmployeesService.Migrations/CSharpCourse.EmployeesService.Migrations.csproj", "./CSharpCourse.EmployeesService.Migrations/"]
COPY ["./src/CSharpCourse.EmployeesService.Hosting/CSharpCourse.EmployeesService.Hosting.csproj", "./CSharpCourse.EmployeesService.Hosting/"]
RUN dotnet restore "./CSharpCourse.EmployeesService.Hosting/CSharpCourse.EmployeesService.Hosting.csproj"

COPY "./Directory.build.props" .
COPY "./Directory.build.targets" .
COPY "./src" .
WORKDIR "/src"

RUN dotnet build "CSharpCourse.EmployeesService.Hosting/CSharpCourse.EmployeesService.Hosting.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "CSharpCourse.EmployeesService.Hosting/CSharpCourse.EmployeesService.Hosting.csproj" -c Release -o /app/publish
COPY "entrypoint.sh" "/app/publish/."

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
RUN chmod +x entrypoint.sh
CMD /bin/bash entrypoint.sh
