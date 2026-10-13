<script setup lang="ts">
import { findArticle } from '~/data/articles'

const article = findArticle('demarrer')!

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
    <!-- Contenu brut : le texte en français vit ici, balises
         incluses. Le shell garantit un design identique à
         l'édition anglaise. -->
    <p>
      Vous venez de scaffolder <strong>{{APP_TITLE}}</strong>. Dans dix minutes,
      la plateforme entière tourne en local — API, webapp et ce site — avec un
      chemin clair vers votre première fonctionnalité.
    </p>

    <h2>Tout démarrer</h2>
    <p>
      Lancez <strong>make services</strong> une fois pour booter Postgres, Redis
      et MinIO, puis <strong>make dev</strong>. La webapp répond sur
      <em>app.{{APP_NAME}}.localhost:3000</em>, l'API sur le port 8000, et chaque
      service diffuse ses logs colorés.
    </p>

    <h2>Votre première fonctionnalité</h2>
    <p>
      Les fonctionnalités sont des mots simples. Suivez le
      <a href="https://{{DOMAIN}}">#playbook</a> : ajoutez le cas d'enum,
      accordez les actions dans la matrice, générez le modèle, un contrôleur
      invokable par verbe — la barre latérale et les gates s'allument seuls.
    </p>

    <blockquote>
      Les permissions sont du code. Si vous ajoutez une table de rôles, arrêtez.
    </blockquote>

    <h2>Livrez</h2>
    <p>
      Poussez un tag : les workflows de publish construisent chaque image, le
      déploiement roule la stack Swarm, Discord reçoit un ping. C'est tout le
      train de release.
    </p>
  </ArticleShell>
</template>
