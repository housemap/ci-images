FROM housemap/ci-images:minimal

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

ENTRYPOINT ["dockerd-entrypoint.sh"]