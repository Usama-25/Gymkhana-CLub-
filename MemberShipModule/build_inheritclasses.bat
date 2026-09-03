@echo off
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe /target:library /out:bin\inheritclasses.dll /r:System.dll /r:System.Data.dll /r:System.Configuration.dll /r:System.Web.dll /r:System.Xml.dll inheritclasses\*.cs
echo Build Complete.
pause
