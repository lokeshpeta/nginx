FROM microsoft/nanoserver:latest
ENV VERSION 1.15.0-dev

SHELL ["powershell", "-command"]
RUN Invoke-WebRequest -Uri https://www.nginx.kr/nginx/win64/nginx-$ENV:VERSION-win64.zip -OutFile c:\nginx-$ENV:VERSION-win64.zip; \
	Expand-Archive -Path C:\nginx-$ENV:VERSION-win64.zip -DestinationPath C:\ -Force; \
	Remove-Item -Path c:\nginx-$ENV:VERSION-win64.zip -Confirm:$False; \
	Rename-Item -Path nginx-$ENV:VERSION-win64 -NewName nginx

# Make sure that Docker always uses default DNS servers which hosted by Dockerd.exe
RUN Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters' -Name ServerPriorityTimeLimit -Value 0 -Type DWord; \
	Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters' -Name ScreenDefaultServers -Value 0 -Type DWord; \
	Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters' -Name ScreenUnreachableServers -Value 0 -Type DWord
	
# Shorten DNS cache times
RUN Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters' -Name MaxCacheTtl -Value 30 -Type DWord; \
	Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters' -Name MaxNegativeCacheTtl -Value 30 -Type DWord

WORKDIR /nginx

#COPY nginx.lps.conf ./conf/nginx.conf
COPY nginx.bgc.conf ./conf/nginx.conf

EXPOSE 80
CMD ["nginx", "-g", "\"daemon off;\""]