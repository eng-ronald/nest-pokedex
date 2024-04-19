# Install dependencies only when needed
FROM node:18-alpine3.15 AS deps
# Check https://github.com/nodejs/docker-node/tree/b4117f9333da4138b03a546ec926ef50a31506c3#nodealpine to understand why libc6-compat might be needed.
RUN apk add --no-cache libc6-compat
WORKDIR /app
COPY . .
RUN yarn install --frozen-lockfile

# Build the app with cache dependencies
FROM node:18-alpine3.15 AS builder
WORKDIR /app
COPY . .
RUN yarn build

# Production image, copy all the files and run next
FROM node:18-alpine3.15 AS runner
WORKDIR /usr/src/app

# Copy package.json and yarn.lock from deps stage
COPY --from=deps /app/package.json /app/yarn.lock ./

# Install production dependencies
RUN yarn install --prod

# Copy built files from builder stage
COPY --from=builder /app/dist ./dist

# Command to run the application
CMD ["node", "dist/main"]
