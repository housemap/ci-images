FROM housemap/ci-images:java

#****************      ANDROID     ****************************************************
# Copy install tools

ENV ANDROID_HOME="/usr/local/android-sdk-linux" \
    ANDROID_SDK_MANAGER_VER="4333796" \
    ANDROID_SDK_BUILD_TOOLS="build-tools;29.0.2" \
    ANDROID_SDK_PLATFORM_TOOLS="platforms;android-29" \
    ANDROID_SDK_BUILD_TOOLS_28="build-tools;28.0.3" \
    ANDROID_SDK_PLATFORM_TOOLS_28="platforms;android-28" \
    ANDROID_SDK_EXTRAS="extras;android;m2repository extras;google;m2repository extras;google;google_play_services" \
    ANDROID_SDK_MANAGER_SHA256="92ffee5a1d98d856634e8b71132e8a95d96c83a63fde1099be3d86df3106def9"

ENV PATH="${PATH}:/opt/tools:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools"

RUN set -ex \
    # Install Android SDK manager
    && wget --quiet "https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_MANAGER_VER}.zip" -O /tmp/android-sdkmanager.zip \
    && echo "${ANDROID_SDK_MANAGER_SHA256} /tmp/android-sdkmanager.zip" | sha256sum -c - \
    && mkdir -p ${ANDROID_HOME} \
    && unzip --qq /tmp/android-sdkmanager.zip -d ${ANDROID_HOME} \
    && chown -R root.root ${ANDROID_HOME} \
    && ln -s ${ANDROID_HOME}/tools/android /usr/bin/android \
    # Install Android
    && yes | env JAVA_HOME=$JAVA_8_HOME JRE_HOME=$JRE_8_HOME JDK_HOME=$JDK_8_HOME sdkmanager platform-tools ${ANDROID_SDK_BUILD_TOOLS} ${ANDROID_SDK_PLATFORM_TOOLS} ${ANDROID_SDK_EXTRAS} ${ANDROID_SDK_NDK_TOOLS} \
    && yes | env JAVA_HOME=$JAVA_8_HOME JRE_HOME=$JRE_8_HOME JDK_HOME=$JDK_8_HOME sdkmanager platform-tools ${ANDROID_SDK_BUILD_TOOLS_28} ${ANDROID_SDK_PLATFORM_TOOLS_28} \
    && yes | env JAVA_HOME=$JAVA_8_HOME JRE_HOME=$JRE_8_HOME JDK_HOME=$JDK_8_HOME sdkmanager --licenses \
    # Cleanup
    && rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && apt-get clean
#****************     END ANDROID     ****************************************************

#****************      NODEJS     ****************************************************

 ENV N_SRC_DIR="$SRC_DIR/n"

 RUN git clone https://github.com/tj/n $N_SRC_DIR \
     && cd $N_SRC_DIR && make install \
     && n $NODE_8_VERSION && npm install --save-dev -g grunt && npm install --save-dev -g grunt-cli && npm install --save-dev -g webpack \
     && n $NODE_VERSION && npm install --save-dev -g grunt && npm install --save-dev -g grunt-cli && npm install --save-dev -g webpack \
     && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
     && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
     && apt-get update && apt-get install -y --no-install-recommends yarn \
     && cd / && rm -rf $N_SRC_DIR;

#****************      END NODEJS     ****************************************************

#**************** RUBY *********************************************************
ENV RBENV_SRC_DIR="/usr/local/rbenv"

ENV PATH="/root/.rbenv/shims:$RBENV_SRC_DIR/bin:$RBENV_SRC_DIR/shims:$PATH" \
    RUBY_BUILD_SRC_DIR="$RBENV_SRC_DIR/plugins/ruby-build"

RUN set -ex \
    && git clone https://github.com/rbenv/rbenv.git $RBENV_SRC_DIR \
    && mkdir -p $RBENV_SRC_DIR/plugins \
    && git clone https://github.com/rbenv/ruby-build.git $RUBY_BUILD_SRC_DIR \
    && sh $RUBY_BUILD_SRC_DIR/install.sh \
    && rbenv install $RUBY_VERSION && rbenv global $RUBY_VERSION

#**************** END RUBY *****************************************************

RUN gem install bundler
RUN sudo curl -sL firebase.tools | bash

ENTRYPOINT ["dockerd-entrypoint.sh"]