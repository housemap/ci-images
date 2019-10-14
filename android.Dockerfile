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
    && wget –-quiet "https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_MANAGER_VER}.zip" -O /tmp/android-sdkmanager.zip \
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

ENTRYPOINT ["dockerd-entrypoint.sh"]