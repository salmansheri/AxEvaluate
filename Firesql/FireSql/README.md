```bash
dotnet publish --configuration Release --runtime linux-x64 --self-contained true /p:NativeLib=Shared /p:OutputType=Library
```