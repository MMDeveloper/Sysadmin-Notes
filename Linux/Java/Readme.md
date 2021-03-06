Installing Oracle's Java on a linux machine is pretty easy. First thing you need to do is go to https://www.java.com/en/download/manual.jsp?locale=en and download the appropriate tar.gz file.
For this document, I'll be downloading the 'Linux x64' tar.gz file named jre-8u40-linux-x64.tar.gz

I typically will put this in /usr/local/java
```
mkdir -p /usr/local/java
mv ~/Downloads/jre-8u40-linux-x64.tar.gz /usr/local/java/
cd /usr/local/java/
```

Now we'll expand the download
```
gunzip jre-8u40-linux-x64.tar.gz
tar -xvf jre-8u40-linux-x64.tar
rm jre-8u40-linux-x64.tar
```

Now we have a folder called 'jre1.8.0_40'. We will create a symbolic link to that folder called 'jre'
```
ln -s jre1.8.0_40/ jre
```

Now we just tell the OS that java resides in /usr/local/java/jre. To upgrade Java, we just repeat the steps previous to the creation of the symbolic link. Instead, we'll delete the existing symbolic link and create a new one pointing to the newer java folder, viola, java upgraded.

buntu variants use the 'update-alternatives' system to tell the OS where java resides
```
sudo update-alternatives --install "/usr/bin/java" "java" "/usr/local/java/jre/bin/java" 1
sudo update-alternatives --install "/usr/bin/javaws" "javaws" "/usr/local/java/jre/bin/javaws" 1
sudo update-alternatives --set java /usr/local/java/jre/bin/java
sudo update-alternatives --set javaws /usr/local/java/jre/bin/javaws
sudo update-alternatives --config java
```

Other distros will use different methods to initially tell them where Oracle's Java resides. You should now be able to verify correct installation by issuing
```
java -version
```

This was my output
```
java version "1.8.0_40"
Java(TM) SE Runtime Environment (build 1.8.0_40-b26)
Java HotSpot(TM) 64-Bit Server VM (build 25.40-b25, mixed mode)
```
