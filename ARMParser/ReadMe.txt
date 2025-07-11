✅ Updated .csproj for Linux Deployment
xml
Copy
Edit
<Project Sdk="Microsoft.NET.Sdk.Web">

  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <PlatformTarget>AnyCPU</PlatformTarget>
    <Platforms>AnyCPU</Platforms>
    
    <!-- Add this to target Linux -->
    <RuntimeIdentifier>linux-x64</RuntimeIdentifier>
    <!-- Optional: Self-contained build (false = needs .NET runtime installed) -->
    <SelfContained>false</SelfContained>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Swashbuckle.AspNetCore" Version="6.6.2" />
  </ItemGroup>

</Project>
🛠️ To Publish for Linux:

====================================================

To publish for Linux, you need to specify the target runtime like this:

bash
Copy
Edit
dotnet publish -c Release -r linux-x64 --self-contained false -o ./publish
🔧 Explanation:
-r linux-x64: Target runtime (Linux 64-bit)

--self-contained false: Use .NET runtime installed on the server (can be true for a fully portable version)

-o ./publish: Output folder

====================================================

Want a self-contained Linux build?
Run this instead:

bash
Copy
Edit
dotnet publish -c Release -r linux-x64 --self-contained true -o ./publish
This will generate everything needed even if .NET is not installed on the server.



# Run this command if dll not found error occurs 

```bash
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(pwd)/bin/Debug/net8.0/linux-x64
```