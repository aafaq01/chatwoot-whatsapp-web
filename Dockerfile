FROM node:18-slim

# Install latest chrome dev package and fonts to support major charsets
RUN apt-get update \
    && apt-get install -y wget gnupg \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-stable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf libxss1 \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Set up work directory and user
WORKDIR /home/pptruser

RUN groupadd -r pptruser && useradd -r -g pptruser -G audio,video pptruser \
    && mkdir -p /home/pptruser/Downloads \
    && chown -R pptruser:pptruser /home/pptruser \
    && chown -R pptruser:pptruser /usr/local

# Copy package.json and package-lock.json
COPY package.json package-lock.json ./

# Install npm packages as root
RUN npm install -g puppeteer \
    && npm install \
    && chown -R pptruser:pptruser /home/pptruser/node_modules

# Switch to non-root user
USER pptruser

# Expose port and set entry point
EXPOSE 8080

ENTRYPOINT ["sh", "-c", "npm run start"]
