FROM housemap/ci-images:minimal

#****************      JAVA     ****************************************************

ENV JAVA_11_HOME="/opt/jvm/openjdk-11" \
    JDK_11_HOME="/opt/jvm/openjdk-11" \
    JRE_11_HOME="/opt/jvm/openjdk-11" \
    JAVA_8_HOME="/usr/lib/jvm/java-8-openjdk-amd64" \
    JDK_8_HOME="/usr/lib/jvm/java-8-openjdk-amd64" \
    JRE_8_HOME="/usr/lib/jvm/java-8-openjdk-amd64/jre" \
    ANT_VERSION=1.10.6 \
    MAVEN_HOME="/opt/maven" \
    MAVEN_VERSION=3.6.1 \
    MAVEN_CONFIG="/root/.m2" \
    INSTALLED_GRADLE_VERSIONS="4.10.3 5.4.1" \
    GRADLE_VERSION=5.4.1 \
    SBT_VERSION=1.2.8 \
    JDK_VERSION=11.0.2 \
    JDK_VERSION_TAG=9 \
    GRADLE_PATH="$SRC_DIR/gradle" \
    JDK_DOWNLOAD_SHA256="99be79935354f5c0df1ad293620ea36d13f48ec3ea870c838f20c504c9668b57" \
    ANT_DOWNLOAD_SHA512="c1a9694c3018e248000ff6f46d48af85f537ef3935e0d5256543c58a240084c0aff5289fd9e94cbc40d5442f3cc43592398047f2548fded40d9882be2b40750d" \
    MAVEN_DOWNLOAD_SHA512="b4880fb7a3d81edd190a029440cdf17f308621af68475a4fe976296e71ff4a4b546dd6d8a58aaafba334d309cc11e638c52808a4b0e818fc0fd544226d952544" \
    GRADLE_DOWNLOADS_SHA256="7bdbad1e4f54f13c8a78abc00c26d44dd8709d4aedb704d913fb1bb78ac025dc 5.4.1\n336b6898b491f6334502d8074a6b8c2d73ed83b92123106bd4bf837f04111043 4.10.3"

ENV JDK_DOWNLOAD_TAR="openjdk-${JDK_VERSION}_linux-x64_bin.tar.gz" \
    JAVA_HOME="$JAVA_11_HOME" \
    JDK_HOME="$JDK_11_HOME" \
    JRE_HOME="$JRE_11_HOME"

RUN set -ex \
    && apt-get update \
    && apt-get install -y software-properties-common \
    # Install OpenJDK 8
    && add-apt-repository -y ppa:openjdk-r/ppa \
    && apt-get update \
    && apt-get install -y openjdk-8-jdk \
    && apt-get install -y --no-install-recommends ca-certificates-java \
    # Ensure Java cacerts symlink points to valid location
    && update-ca-certificates -f \
    && dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --force-yes libc6-i386 \
       lib32stdc++6 lib32gcc1 lib32ncurses5 \
       lib32z1 libqt5widgets5 \
    # Install OpenJDK 11
    # Note: We will use update-alternatives to make sure JDK11 has higher priority for all the tools
    && mkdir -p $JAVA_HOME \
    && curl -LSso /var/tmp/$JDK_DOWNLOAD_TAR https://download.java.net/java/GA/jdk$JAVA_VERSION/$JDK_VERSION_TAG/GPL/$JDK_DOWNLOAD_TAR \
    && echo "$JDK_DOWNLOAD_SHA256 /var/tmp/$JDK_DOWNLOAD_TAR" | sha256sum -c - \
    && tar xzf /var/tmp/$JDK_DOWNLOAD_TAR -C $JAVA_HOME --strip-components=1 \
    && for tool_path in $JAVA_HOME/bin/*; do \
          tool=`basename $tool_path`; \
          update-alternatives --install /usr/bin/$tool $tool $tool_path 10000; \
          update-alternatives --set $tool $tool_path; \
        done \
     && rm $JAVA_HOME/lib/security/cacerts && ln -s /etc/ssl/certs/java/cacerts $JAVA_HOME/lib/security/cacerts \
    # Install Ant
    && curl -LSso /var/tmp/apache-ant-$ANT_VERSION-bin.tar.gz https://archive.apache.org/dist/ant/binaries/apache-ant-$ANT_VERSION-bin.tar.gz  \
    && echo "$ANT_DOWNLOAD_SHA512 /var/tmp/apache-ant-$ANT_VERSION-bin.tar.gz" | sha512sum -c - \
    && tar xzf /var/tmp/apache-ant-$ANT_VERSION-bin.tar.gz -C /opt \
    && update-alternatives --install /usr/bin/ant ant /opt/apache-ant-$ANT_VERSION/bin/ant 10000 \
    # Install Maven
    && mkdir -p $MAVEN_HOME \
    && curl -LSso /var/tmp/apache-maven-$MAVEN_VERSION-bin.tar.gz https://apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz \
    && echo "$MAVEN_DOWNLOAD_SHA512 /var/tmp/apache-maven-$MAVEN_VERSION-bin.tar.gz" | sha512sum -c - \
    && tar xzf /var/tmp/apache-maven-$MAVEN_VERSION-bin.tar.gz -C $MAVEN_HOME --strip-components=1 \
    && update-alternatives --install /usr/bin/mvn mvn /opt/maven/bin/mvn 10000 \
    && mkdir -p $MAVEN_CONFIG \
    # Install Gradle
    && mkdir -p $GRADLE_PATH \
    && for version in $INSTALLED_GRADLE_VERSIONS; do { \
       wget "https://services.gradle.org/distributions/gradle-$version-bin.zip" -O "$GRADLE_PATH/gradle-$version-bin.zip" \
       && unzip --qq "$GRADLE_PATH/gradle-$version-bin.zip" -d /usr/local \
       && echo "$GRADLE_DOWNLOADS_SHA256" | grep "$version" | sed "s|$version|$GRADLE_PATH/gradle-$version-bin.zip|" | sha256sum -c - \
       && mkdir "/tmp/gradle-$version" \
       && "/usr/local/gradle-$version/bin/gradle" -p "/tmp/gradle-$version" wrapper \
       && perl -pi -e "s/gradle-$version-bin.zip/gradle-$version-bin.zip/" "/tmp/gradle-$version/gradle/wrapper/gradle-wrapper.properties" \
       && "/tmp/gradle-$version/gradlew" -p "/tmp/gradle-$version" init \
       && rm -rf "/tmp/gradle-$version" \
       && if [ "$version" != "$GRADLE_VERSION" ]; then rm -rf "/usr/local/gradle-$version"; fi; \
     }; done \
    # Install default GRADLE_VERSION to path
      && ln -s /usr/local/gradle-$GRADLE_VERSION/bin/gradle /usr/bin/gradle \
      && rm -rf $GRADLE_PATH \
    # Install SBT
    && echo "deb https://dl.bintray.com/sbt/debian /" | tee -a /etc/apt/sources.list.d/sbt.list \
    && apt-get install -y --no-install-recommends apt-transport-https \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823 \
    && apt-get update \
    && apt-get install -y --no-install-recommends sbt=$SBT_VERSION \
    # Cleanup
    && rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && apt-get clean
#****************     END JAVA     ****************************************************

ENTRYPOINT ["dockerd-entrypoint.sh"]