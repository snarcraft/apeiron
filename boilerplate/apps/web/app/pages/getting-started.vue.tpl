<script setup lang="ts">
import { findArticle } from '~/data/articles'

const article = findArticle('getting-started')!

useSeoMeta({
  title: article.title,
  description: article.description,
  ogTitle: article.title,
  ogDescription: article.description,
  ogType: 'article',
  articlePublishedTime: article.date
})
</script>

<template>
  <ArticleShell
    :title="article.title"
    :description="article.description"
    :date="article.date"
    :lang="article.lang"
    :translations="article.translations"
  >
    <!-- Raw content: any markup embeds directly. The shell owns
         the design — keep editions visually identical. -->
    <p>
      You have just scaffolded <strong>{{APP_TITLE}}</strong>. Ten minutes from
      now you will have the whole platform running locally — API, webapp and
      this website — and a clear path to your first feature.
    </p>

    <h2>Start everything</h2>
    <p>
      Run <strong>make services</strong> once to boot Postgres, Redis and MinIO,
      then <strong>make dev</strong>. The webapp answers on
      <em>app.{{APP_NAME}}.localhost:3000</em>, the API on port 8000, and every
      service streams its own color-coded log.
    </p>

    <h2>Your first feature</h2>
    <p>
      Features are single words. Follow the
      <a href="https://{{DOMAIN}}">#playbook</a>: add the enum case, grant the
      actions in the matrix, generate the model, one invokable controller per
      verb — the sidebar and the gates light up automatically.
    </p>

    <blockquote>
      Permissions are code. If you are adding a roles table, stop.
    </blockquote>

    <h2>Ship it</h2>
    <p>
      Push a tag: the publish workflows build every image, deploy rolls the
      Swarm stack, Discord gets a ping. That is the whole release train.
    </p>
  </ArticleShell>
</template>
